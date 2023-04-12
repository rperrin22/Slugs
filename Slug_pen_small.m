classdef Slug_pen_small
    properties
        infotable
        info_filename
        pen_index

    end

    methods
        function obj = Slug_pen_small(pen_list_filename)

            % set filename for output
            obj.info_filename = pen_list_filename;

            % test to see if file exists, if it does - load, if not - create.
            if isfile(pen_list_filename)
                obj.infotable = readtable(pen_list_filename);
            else
                Longitude=[-999];
                Latitude=[-999];
                Pen= {'temp'};
                BW = {'temp'};
                Station = {'temp'};
                Pen_num = [0];
                Cruise = {'temp'};
                Depth = [0];
                Tilt = [0];
                Logger_ID = {'temp'};
                Probe_ID = {'temp'};
                Datum = [0];
                s_pen = [0];
                e_pen = [0];
                hp_pen = [0];
                s_eqm = [0];
                e_eqm = [0];
                s_bw = [0];
                e_bw = [0];
                bw_val = [0];
                obj.infotable = table(Longitude,Latitude,Pen,BW,Station,Pen_num,...
                    Cruise,Depth,Tilt,Logger_ID,Probe_ID,Datum,...
                    s_pen,e_pen,hp_pen,s_eqm,e_eqm,s_bw,e_bw,bw_val);
            end

            % initialize index
            obj.pen_index = [];

        end

        function write_infotable(obj)
            writetable(obj.infotable,obj.info_filename);
        end

        function obj = add_pen(obj,Longitude,Latitude,Pen,BW,Station,Pen_num,Cruise,Depth,Tilt,Logger_ID,Probe_ID,Datum)
            s_pen = 0;
            e_pen = 0;
            hp_pen = 0;
            s_eqm = 0;
            e_eqm = 0;
            s_bw = 0;
            e_bw = 0;
            bw_val = 0;
            TEMP = table(Longitude,Latitude,Pen,BW,Station,Pen_num,...
                    Cruise,Depth,Tilt,Logger_ID,Probe_ID,Datum,...
                    s_pen,e_pen,hp_pen,s_eqm,e_eqm,s_bw,e_bw,bw_val);

            obj.infotable = [obj.infotable; TEMP];
        end

        function obj = find_index(obj,stn,pen)

            obj.pen_index = find(strcmp(obj.infotable.Station,stn) & ...
                                        obj.infotable.Pen_num==pen);

            if isempty(obj.pen_index)
                fprintf('Station not found\n');
            else
                fprintf('Index %d\n',obj.pen_index);
            end

        end

        function obj = pick_pen(obj)
            if isempty(obj.pen_index)
                fprintf('Get pick index first\n');
            else
                
                % load data
                PEN = importdata(obj.infotable.Pen{obj.pen_index},' ',6);
        
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

                % put the normal title back on it before making qc plot
                title(obj.infotable.Pen(obj.pen_index));

                obj.infotable.s_pen(obj.pen_index) = nearest(x1);
                obj.infotable.e_pen(obj.pen_index) = nearest(x2);
                obj.infotable.hp_pen(obj.pen_index) = nearest(x3);
                obj.infotable.s_eqm(obj.pen_index) = nearest(x4);
                obj.infotable.e_eqm(obj.pen_index) = nearest(x5);

            end
        end

        function obj = pick_bw(obj)
            if isempty(obj.pen_index)
                fprintf('Get pick index first\n');
            else
                % load data
                CAL = importdata(obj.infotable.BW{obj.pen_index},' ',6);
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

                % put the normal title back on before printing qc plot
                title(obj.infotable.BW(obj.pen_index));
                obj.infotable.s_bw(obj.pen_index) = nearest(xb1);
                obj.infotable.e_bw(obj.pen_index) = nearest(xb2);
                obj.infotable.bw_val(obj.pen_index) = 0;

            end
        end

        function make_qc_plot(obj)
            if isempty(obj.pen_index)
                fprintf('Get pick index first\n');
            else
                PEN = importdata(obj.infotable.Pen{obj.pen_index},' ',6);
                CAL = importdata(obj.infotable.BW{obj.pen_index},' ',6);

                x1 = obj.infotable.s_pen(obj.pen_index);
                x2 = obj.infotable.e_pen(obj.pen_index);
                x3 = obj.infotable.hp_pen(obj.pen_index);
                x4 = obj.infotable.s_eqm(obj.pen_index);
                x5 = obj.infotable.e_eqm(obj.pen_index);

                xb1 = obj.infotable.s_bw(obj.pen_index);
                xb2 = obj.infotable.e_bw(obj.pen_index);

                figure('units','normalized','outerposition',[0 0 1 1]);
                subplot(121)
                hold on
                plot(PEN.data(:,1),PEN.data(:,2:end-1));
                grid on
                ylims = get(gca,'ylim');
                xlabel('Measurement number')
                ylabel('Temperature (^oC)')
                title(sprintf('Penetration %s %d',obj.infotable.Station{obj.pen_index},obj.infotable.Pen_num(obj.pen_index)),'interpreter','none');

                plot([x1,x1],ylims,'k:')
                ht1 = text(x1,ylims(1),'ps');
                set(ht1,'rotation',90);

                plot([x2,x2],ylims,'k:')
                ht2 = text(x2,ylims(1),'pe');
                set(ht2,'rotation',90);

                plot([x3,x3],ylims,'k:')
                ht3 = text(x3,ylims(1),'hp');
                set(ht3,'rotation',90);

                plot([x4,x4],ylims,'k:')
                ht4 = text(x4,ylims(1),'eqs');
                set(ht4,'rotation',90);

                plot([x5,x5],ylims,'k:')
                ht5 = text(x5,ylims(1),'eqe');
                set(ht5,'rotation',90);

                subplot(122)
                hold on
                plot(CAL.data(:,1),CAL.data(:,2:end-1));
                grid on
                ylims = get(gca,'ylim');
                xlabel('Measurement number')
                ylabel('Temperature (^oC)')
                title(sprintf('Bottom Water %s %d',obj.infotable.Station{obj.pen_index},obj.infotable.Pen_num(obj.pen_index)),'interpreter','none');

                plot([xb1,xb1],ylims,'k:')
                htb1 = text(xb1,ylims(1),'bws');
                set(htb1,'rotation',90);

                plot([xb2,xb2],ylims,'k:')
                htb2 = text(xb2,ylims(1),'bwe');
                set(htb2,'rotation',90);

                temp = char(obj.infotable.Pen(obj.pen_index));
                exportgraphics(gcf,sprintf('%s_qc.pdf',temp(1:end-4)),'ContentType','vector');

            end
        end


        function write_penfile(obj)
            if isempty(obj.pen_index)
                fprintf('Get pick index first\n');
            else
                PEN = importdata(char(obj.infotable.Pen(obj.pen_index)),' ',6);
                CAL = importdata(char(obj.infotable.BW(obj.pen_index)),' ',6);

                % Use root of raw data filename to create penetration filename.
                temp = obj.infotable.Pen{obj.pen_index};
                fnout = sprintf('%s.pen',temp(1:end-4));
                fprintf('Writing to %s...',fnout);

                % Calculate average bottom temperature for each probe during BW
                % calibration, and calculate the mean of BW temperature values to use for
                % reference.
                cal_ind=obj.infotable.s_bw(obj.pen_index):obj.infotable.e_bw(obj.pen_index);
                cal_ind=cal_ind';
                cal_sub=CAL.data(cal_ind,2:6);

                cal_calc=mean(cal_sub);
                tot_mean=mean(cal_calc);

                % Find the index of the measurement ID corresponding to the penetration
                % point. This helps with identifying key indices for raw data files that do
                % not start with an index of 1.
                is_pen = find(PEN.data(:,1)==obj.infotable.s_pen(obj.pen_index),1);
                ihp_pen = find(PEN.data(:,1)==obj.infotable.hp_pen(obj.pen_index),1);
                ie_pen = find(PEN.data(:,1)==obj.infotable.e_pen(obj.pen_index),1);

                % Penetration file will begin 5 measurements prior to insertion of probe.
                % End of penetration file will either be after dissipation of heat pulse,
                % or after dissipation of friction pulse, if no thermal conductivity
                if obj.infotable.e_pen(obj.pen_index)==0
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
                if obj.infotable.bw_val(obj.pen_index)==0
                    pen_sub(:,7)=tot_mean;
                else
                    ibw=find(PEN.data(:,1)==obj.infotable.bw_val(obj.pen_index),1);
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
                fprintf(fido,'%s %d ''%s'' %d\n',obj.infotable.Station{obj.pen_index},obj.infotable.Pen_num(obj.pen_index),obj.infotable.Cruise{obj.pen_index},obj.infotable.Datum(obj.pen_index));
                fprintf(fido,'%.6f %.6f %.2f  %.1f\n',obj.infotable.Latitude(obj.pen_index),obj.infotable.Longitude(obj.pen_index),obj.infotable.Depth(obj.pen_index),obj.infotable.Tilt(obj.pen_index));
                fprintf(fido,'%s %s %d\n',obj.infotable.Logger_ID{obj.pen_index},obj.infotable.Probe_ID{obj.pen_index},ip);
                fprintf(fido,'    %d\n',obj.infotable.s_pen(obj.pen_index));
                fprintf(fido,'    %d  %d  %d\n',obj.infotable.hp_pen(obj.pen_index),obj.infotable.s_eqm(obj.pen_index),obj.infotable.e_eqm(obj.pen_index));


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

                % write a tap file
                fnout_tap = sprintf('%s.tap',temp(1:end-4));
                fido_tap = fopen(fnout_tap,'wt');
                for count = obj.infotable.s_pen(obj.pen_index):obj.infotable.e_pen(obj.pen_index)
                    fprintf(fido_tap,' %d 0 0\n',count);
                end
                fclose(fido_tap);

                % let the user know that all is well
                fprintf('complete\n');

            end
        end

    end

end