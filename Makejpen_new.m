function Makejpen_new(inputfile,bw_inputfile,qc_plot_flag)
%% Description
% inputfile - raw data from small probe for penetration
% bw_inputfile - raw data from small probe for bw measurement
% qc_plot_flag - make pdf plots for QC purposes (0: no plot, 1: plot)
%
% Changelog:
%     - April 11, 2023 (R.Perrin): Adapted from Makejpen2
%

%% load files
PEN = importdata(inputfile,' ',6);
CAL = importdata(bw_inputfile,' ',6);

%% Interactive penetration plot and picking
% need to pick:
%     1. Penetration start
%     2. Penetration end
%     3. Heat pulse
%     4. Equillibrium start  - not sure yet what these are for
%     5. Equillibrium end  - not sure yet what these are for

% happy flag: 0-not happy with picks, 1-happy with picks
happy = 0;

while happy==0
    % make plot
    figure;
    hold on
    plot(PEN.data(:,1),PEN.data(:,2:end-1));
    grid on
    ylims = get(gca,'ylim');
    xlabel('Measurement number')
    ylabel('Temperature (^oC)')

    % get penetration start
    title('Pick penetration start!')
    [x1,~] = ginput(1);
    plot([x1,x1],ylims,'k:')
    ht1 = text(x1,ylims(1),'ps');
    set(ht1,'rotation',90);

    title('Pick penetration end!')
    [x2,~] = ginput(1);
    plot([x2,x2],ylims,'k:')
    ht2 = text(x2,ylims(1),'pe');
    set(ht2,'rotation',90);

    title('Pick heat pulse!')
    [x3,~] = ginput(1);
    plot([x3,x3],ylims,'k:')
    ht3 = text(x3,ylims(1),'hp');
    set(ht3,'rotation',90);

    title('Pick equillibrium start!')
    [x4,~] = ginput(1);
    plot([x4,x4],ylims,'k:')
    ht4 = text(x4,ylims(1),'es');
    set(ht4,'rotation',90);

    title('Pick equillibrium end!')
    [x5,~] = ginput(1);
    plot([x5,x5],ylims,'k:')
    ht5 = text(x5,ylims(1),'ee');
    set(ht5,'rotation',90);

    answer = questdlg('Happy with these picks?',...
        'Happiness tester',...
        'yes','no','no');
    switch answer
        case 'yes'
            happy=1;
        case 'no'
            happy=0;
    end
end

title(inputfile);
s_pen = nearest(x1);
e_pen = nearest(x2);
hp_pen = nearest(x3);

if qc_plot_flag==1
    exportgraphics(gcf,sprintf('%s_pen.pdf',inputfile(1:end-4)),'ContentType','vector');
end
close all

%% Interactive bw plot and picking
% need to pick:
%     1. bw start
%     2. bw end

happy = 0;

while happy==0
    % make plot
    figure;
    hold on
    plot(CAL.data(:,1),CAL.data(:,2:end-1));
    grid on
    ylims = get(gca,'ylim');
    xlabel('Measurement number')
    ylabel('Temperature (^oC)')

    % get penetration start
    title('Pick penetration start!')
    [xb1,~] = ginput(1);
    plot([xb1,xb1],ylims,'k:')
    htb1 = text(xb1,ylims(1),'bws');
    set(htb1,'rotation',90);

    title('Pick penetration end!')
    [xb2,~] = ginput(1);
    plot([xb2,xb2],ylims,'k:')
    htb2 = text(xb2,ylims(1),'bwe');
    set(htb2,'rotation',90);


    answer = questdlg('Happy with these picks?',...
        'Happiness tester',...
        'yes','no','no');
    switch answer
        case 'yes'
            happy=1;
        case 'no'
            happy=0;
    end
end

title(bw_inputfile);
s_cal = nearest(xb1);
e_cal = nearest(xb2);
bw_val = 0;  % set to average, change later

if qc_plot_flag==1
    exportgraphics(gcf,sprintf('%s_bw.pdf',bw_inputfile(1:end-4)),'ContentType','vector');
end
close all

%% ask for some information about this penetration
prompt = {'Longitude:',...
    'Latitude:',...
    'Station Name:',...
    'Penetration Number:',...
    'Cruise Name:',...
    'Depth',...
    'Tilt',...
    'Logger ID',...
    'Probe ID',...
    'Datum'};
dlgtitle = 'Coordinates';
dims = [1 35];
definput = {'-999.000',...
    '-999.000',...
    'HFSTN',...
    '0',...
    'Bob',...
    '0',...
    '0',...
    '0',...
    '0',...
    '0'};
answer2 = inputdlg(prompt,dlgtitle,dims,definput);
Longitude = str2double(answer2{1});
Latitude = str2double(answer2{2});
STN_name = answer2{3};
PEN_num = str2double(answer2{4});
CR_name = answer2{5};
Depth = str2double(answer2{6});
Tilt = str2double(answer2{7});
Logger_ID = answer2{8};
Probe_ID = answer2{9};
Datum = str2double(answer2{10});

%% now make the .pen file
% Use root of raw data filename to create penetration filename.
fnout = sprintf('%s.pen',inputfile(1:end-4));
fprintf('Writing to %s...',fnout);

% Calculate average bottom temperature for each probe during BW
% calibration, and calculate the mean of BW temperature values to use for
% reference.
cal_ind=s_cal:e_cal;
cal_ind=cal_ind';
cal_sub=CAL.data(cal_ind,2:6);

cal_calc=mean(cal_sub);
tot_mean=mean(cal_calc);

% Find the index of the measurement ID corresponding to the penetration
% point. This helps with identifying key indices for raw data files that do
% not start with an index of 1.
is_pen = find(PEN.data(:,1)==s_pen,1);
ihp_pen = find(PEN.data(:,1)==hp_pen,1);
ie_pen = find(PEN.data(:,1)==e_pen,1);

% Penetration file will begin 5 measurements prior to insertion of probe.
% End of penetration file will either be after dissipation of heat pulse,
% or after dissipation of friction pulse, if no thermal conductivity
if e_pen==0
    pen_ind=is_pen-5:ihp_pen;
else
    pen_ind=is_pen-5:ie_pen;
end
pen_ind=pen_ind';

% Fill pen_sub array with subset of values to be placed in penetration
% file, then add a sixth column of temperature values, based on BW
% calibration or a measurement made just before penetration (determined by
% inspection of the raw data file), to be used for a psuedo-bottom water
% sensor during penetration.
pen_sub=PEN.data(pen_ind,1:7);
if bw_val==0
    pen_sub(:,7)=tot_mean;
else
    ibw=find(PEN.data(:,1)==bw_val,1);
    bwmean=mean(PEN.data(ibw,2:6));
    pen_sub(:,7)=bwmean;
end

% get number of sensors
ip = size(PEN.data,2) - 2;

% open output file
fido = fopen(fnout,'wt');

% First five lines of penetration file are structured to match PGC format
% Line 1 : StationName, PenetrationNumber, CruiseName
% Line 2 : Latitude, Longitude, Depth, Tilt
% Line 3 : Logger ID, Probe ID, Number of Sensors
% Line 4 : Penetration Record Start
% Line 5 : Heat Pulse Record Start, eqm start record, eqm end record
fprintf(fido,'%s %d ''%s'' %d\n',STN_name,PEN_num,CR_name,Datum);
fprintf(fido,'%.6f %.6f %.2f  %.1f\n',Latitude,Longitude,Depth,Tilt);
fprintf(fido,'%s %s %d\n',Logger_ID,Probe_ID,ip);
fprintf(fido,'    %d\n',s_pen);
fprintf(fido,'    %d  %d  %d\n',hp_pen,nearest(x4),nearest(x5));

% Insert vector of BW calibration data in penetration file
formcal=repmat('%8.3f ',1,ip+1);
formcal=[' ',formcal '\n'];
fprintf(fido,formcal,cal_calc(1:ip),tot_mean);

% Write rest of penetration file
formpen=repmat('%8.3f ',1,ip+1);
formpen=['  %d' formpen '\n'];
i=1;
while i<=size(pen_sub,1)
    fprintf(fido,formpen,pen_sub(i,1:ip+2));
    i=i+1;
end

% close output file
fclose(fido);

% let the user know that all is well
fprintf('complete\n');

