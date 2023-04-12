% initialize
B = Slug_pen_small('haha.xlsx');

%% add a new location
Longitude=[-136.35];
Latitude=[52.5];
Pen= {'test.txt'};
BW = {'testcal.txt'};
Station = {'snail_shell'};
Pen_num = [3];
Cruise = {'hoib'};
Depth = [3000];
Tilt = [0];
Logger_ID = {'logga_1'};
Probe_ID = {'probe_1'};
Datum = [3000];
B = B.add_pen(Longitude,Latitude,Pen,BW,Station,Pen_num,Cruise,Depth,Tilt,Logger_ID,Probe_ID,Datum);

%% clear first row of table
B.infotable(1,:)=[];

%% add a new location
Longitude=[-138.25];
Latitude=[56.3];
Pen= {'HF-751-02.txt'};
BW = {'HF-751-02cal.txt'};
Station = {'snail_shell'};
Pen_num = [1];
Cruise = {'hoib'};
Depth = [3000];
Tilt = [0];
Logger_ID = {'logga_1'};
Probe_ID = {'probe_1'};
Datum = [3000];
B = B.add_pen(Longitude,Latitude,Pen,BW,Station,Pen_num,Cruise,Depth,Tilt,Logger_ID,Probe_ID,Datum);

%% get index for first station
B = B.find_index('snail_shell',1);
B = B.pick_pen;
B = B.pick_bw;

% make qc plot
B.make_qc_plot;
B.write_penfile

%% get index for next station
B = B.find_index('snail_shell',3);
B = B.pick_pen;
B = B.pick_bw;

% make qc plot
B.make_qc_plot;
B.write_penfile

%% save
B.write_infotable;