
localPaths = '/home/andrea/matlabcode/atmos/local_paths_atm.m';
run(localPaths);
dataPath = '/home/andrea/matlabcode/outputsAtm/scenarios/data/';
hour = 18;
position = 1;
month = 1;
years = [2010,2011,2012,2013,2014,2015];
boundaries = [18 -98 31 -80];
outputFolder= strcat('/home/andrea/matlabcode/outputsAtm/scenarios/byear','/',num2str(month,'%02.f'),'/','P',num2str(position),'/',num2str(hour,'%02.f'),'/');
palette = [1	1	1
0.901960790157318	1	0.882352948188782
0.784313738346100	1	0.745098054409027
0.705882370471954	0.980392158031464	0.666666686534882
0.588235318660736	0.960784316062927	0.549019634723663
0	0.501960813999176	0
1	0.909803926944733	0.470588237047195
1	0.752941191196442	0.235294118523598
1	0.627451002597809	0
1	0.376470595598221	0
1	0.196078434586525	0
0.862745106220245	0.862745106220245	1
0.752941191196442	0.705882370471954	1
0.627451002597809	0.549019634723663	1
0.501960813999176	0.439215689897537	0.921568632125855
0	0	1];
saving_quality = '-r100';
cont = 1;
heights = [ 1500, 1000, 500, 100, 10];
mergeEnsemblesByYear(dataPath, hour, position, month,years, boundaries, outputFolder, palette, saving_quality, cont, heights)