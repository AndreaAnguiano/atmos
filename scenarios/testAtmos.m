
%function ensemble = main_atmos(startDate, endDate, dataPath,codePath, saveFigTimeStep, modelTimeStep, domainLimits, RungeKutta, particlesPerBarrel, TurbDiff, heights, coords)
%{
spillTiming.startDay_serial = datenum(startDate);
spillTiming.endDay_serial   = datenum(endDate);
spillTiming.simulationDays  = 1 + spillTiming.endDay_serial - spillTiming.startDay_serial;
spillTiming.timeStep = 24/modelTimeStep; 
%-------spillLocation ---------
spillLocation.n_positions = length(coords);
spillLocation.n_heights = length(heights);
spillLocation.heigths = heights;
spillLocation.positions = coords;
%-------- model configuration ------
ModelConfig.dataPath = dataPath;
ModelConfig.RK = RungeKutta;
ModelConfig.particlesPerBarrel = particlesPerBarrel;
ModelConfig.TurbDiff = TurbDiff;
%}

startDate     = [2010,01,01]; % [2010,04,22]
endDate = [2010,01,01]; %
years = [2010]
dataPath = '/home/andrea/Data/Datos_reanalisis/';
codePath = '/home/andrea/matlabcode/atmos/';
outputPath = '/home/andrea/matlabcode/outputsAtm/newtest/test8/';
saveFigTimeStep =  [4,8,12,18,24,48];
modelTimeStep = 1;
domainLimits =  [-98,-80, 18, 31];
RungeKutta = 4;
particlesPerBarrel = 100;
TurbDiff = 0.399;
heights = [ 1500, 1000, 500, 100, 10];
coords = [
    95.01622889	25.97096444
95.25811667	25.36115583
96.56495556	24.75155556
96.82528583	23.51224639
96.71577028	20.97098889
94.76735833	20.04058889
 ];
windFileTS = 3;
vis_maps.visible         = 'on';
vis_maps.visible_step_hr = nan; % nan
% Bathymetry file name. 'BAT_FUS_GLOBAL_PIXEDIT_V4.mat' | 'gebco_1min_-98_18_-78_31.nc'
vis_maps.bathymetry      = 'BATI100_s10_fixLC.mat';
% Isobaths to plot
vis_maps.isobaths        = [-0, -0.000001];

% Create the colors for the oil
vis_maps.colors_SpillLocation = 'w';
vis_maps.colors_InLand        = 'w';
vis_maps.colors_ByDepth       = ['g';'r';'b';'c';'y'];
vis_maps.colors_ByComponent   = {...
      'r';...                          % red
  [0.9290    0.6940    0.1250];... % orange
  'y';...                          % yellow
  [0.4660    0.7740    0.1880];... % green
  'c';...                          % cyan
  'b';...                          % blue
  'm';...                          % magenta
  [0.4940    0.1840    0.5560]}; 

% Visualization Type (2D and/or 3D)
vis_maps.twoDim          = true;
vis_maps.threeDim        = false;
vis_maps.threeDim_angles = [-6, 55];% [0, 90] [-6, 55]
% Visualization region [minLon, maxLon, minLat, maxLat, minDepth, maxDepth]
vis_maps.boundaries      = [-98, -80, 18, 31, -2500, 0];
% Colormap to use
vis_maps.cmap            = [1 1 1]; % e.g.: [1 1 1], 'copper', 'gray', 'jet',...
vis_maps.fontSize        = 12;
vis_maps.markerSize      = 5;
vis_maps.axesPosition    = [2,2,10,8];
vis_maps.figPosition     = [2,2,2*vis_maps.axesPosition(1)+vis_maps.axesPosition(3)+2.5,2*vis_maps.axesPosition(2)+vis_maps.axesPosition(4)-.5];


% Data
saving.Data_on                   = 1;
saving.Data_step_hr              = [4,8,12,18,24,48];
% maps_images
saving.MapsImage_on              = 0;
saving.MapsImage_quality         = '-r100'; % Resolution in dpi
saving.MapsImage_step_hr         = 0;
saving.Ensembles_on              = 0;
saving.Ensembles_ts              = [4,8,12,18];
individualSpill= 0;

tic
main_scen(startDate, endDate, dataPath, codePath,outputPath, saveFigTimeStep, modelTimeStep, domainLimits, RungeKutta, particlesPerBarrel, TurbDiff, heights, coords, windFileTS, vis_maps, saving, individualSpill, years)
toc