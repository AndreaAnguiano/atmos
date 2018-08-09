close all; clear; clc; format compact; clc
% Local Paths filename 
ModelConfig.LocalPaths = 'local_paths_atm.m';

% Output directorie 
ModelConfig.OutputDir = '/home/andrea/matlab/outputsAtm/';

% Spill timing (yyyy,mm,dd)
spillTiming.startDay_date     = [2010,01,01]; % [2010,04,22]
spillTiming.lastSpillDay_date = [2010,01,05]; % [2010,07,14]
spillTiming.endSimDay_date    = [2010,01,04]; % [2010,07,30]

% Spill location 
spillLocation.Lat      =  28.738; %  28.738
spillLocation.Lon      = -88.366; % -88.366
spillLocation.Heights_m   = [ 1500, 1000, 500, 100, 10];
spillLocation.Radius_m = [ 250, 500, 750, 1000, 1250]; % 2 STD for random initialization of particles

% Model domain
ModelConfig.domainLimits = [-92,-80, 25, 31]; % [-88.6, -88.2, 28.71, 28.765]

% Runge-Kutta method: 2 | 4
ModelConfig.RungeKutta = 4;

% Number of particles representing one barrel
ModelConfig.particlesPerBarrel  = 100;

%Turbulent-diffusion parameter per height 
ModelConfig.TurbDiff_b          = 2;

%-Wind files (time step in hours) 
WindFile.timeStep_hrs  = 3;

% Lagrangian time step (h)
LagrTimeStep.InHrs = 1;

% Add local paths 
run(ModelConfig.LocalPaths);
% Call model routine 
tic
atmosModel(spillTiming,spillLocation,ModelConfig,WindFile,LagrTimeStep);
