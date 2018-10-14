close all; clear; clc; format compact; clc
% Local Paths filename 
ModelConfig.LocalPaths = 'local_paths_atm.m';

% Output directorie 
ModelConfig.OutputDir = '/home/andrea/matlabcode/outputsAtm/prueba12/';

% Spill timing (yyyy,mm,dd)
spillTiming.startDay_date     = [2010,12,31]; % [2010,04,22]
spillTiming.lastSpillDay_date = [2011,01,04]; % [2010,07,14]
spillTiming.endSimDay_date    = [2011,01,04]; % [2010,07,30]

% Spill location 
spillLocation.Lat      = 	25.97096444; %  28.738
spillLocation.Lon      = -95.0162288; % -88.366
spillLocation.Heights  = [ 1500, 1000, 500, 100, 10];
spillLocation.Radius_m = [ 250, 500, 500, 1000, 1000]; % 2 STD for random initialization of particles
spillLocation.n_Heights   = length(spillLocation.Heights);
spillLocation.Point = 1;
% Model domain
ModelConfig.domainLimits = [-98,-80, 18, 31]; % [-88.6, -88.2, 28.71, 28.765]

% Runge-Kutta method: 2 | 4
ModelConfig.RungeKutta = 4;

% Number of particles representing one barrel
ModelConfig.particlesPerBarrel  = 100;

%Turbulent-diffusion parameter per height 
ModelConfig.TurbDiff_b          = 0.39; 
%-Wind files (time step in hours) 
WindFile.timeStep_hrs  = 3;
WindFile.timeStep_hrs_U10 = 1;
% Lagrangian time step (h)
LagrTimeStep.InHrs = 1;
%-------------- Visualization (mapping particles positions) --------------%
% 'on' | 'off'. Set 'on' for visualizing maps as the model runs
vis_maps.visible         = 'on';
vis_maps.visible_step_hr = nan; % nan
% Bathymetry file name. 'BAT_FUS_GLOBAL_PIXEDIT_V4.mat' | 'gebco_1min_-98_18_-78_31.nc'
vis_maps.bathymetry      = 'BATI100_s10_fixLC.mat';
% Visualization Type (2D and/or 3D)
vis_maps.twoDim          = true;
vis_maps.threeDim        = false;
vis_maps.threeDim_angles = [-6, 55];% [0, 90] [-6, 55]
% Visualization region [minLon, maxLon, minLat, maxLat, minDepth, maxDepth]
vis_maps.boundaries      = [-98, -80, 18, 31, -2500, 0];
% Isobaths to plot
vis_maps.isobaths        = [-0, -0.000001];
% Colormap to use
vis_maps.cmap            = [1 1 1]; % e.g.: [1 1 1], 'copper', 'gray', 'jet',...
vis_maps.fontSize        = 12;
vis_maps.markerSize      = 5;
vis_maps.axesPosition    = [2,2,10,8];
vis_maps.figPosition     = [2,2,2*vis_maps.axesPosition(1)+vis_maps.axesPosition(3)+2.5,...
  2*vis_maps.axesPosition(2)+vis_maps.axesPosition(4)-.5];
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
  [0.4940    0.1840    0.5560]};   % purple
%---------------------------- Saving options -----------------------------%
% Data
saving.Data_on                   = 0;
saving.Data_step_hr              = 0;
% maps_images
saving.MapsImage_on              = 0;
saving.MapsImage_quality         = '-r100'; % Resolution in dpi
saving.MapsImage_step_hr         = 0;
saving.Ensembles_on              = 0;
saving.Ensembles_ts              = [4,8,12,18];
individualSpill= true;


% Add local paths 
run(ModelConfig.LocalPaths);
% Call model routine 
tic
atmosModel(spillTiming,spillLocation,ModelConfig,WindFile,LagrTimeStep, vis_maps, saving,individualSpill);
toc