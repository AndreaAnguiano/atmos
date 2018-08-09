
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
endDate = [2010,01,04]; %
dataPath = '/home/andrea/Datos/'
codePath = '/home/andrea/matlab/atmos/lib/'
saveFigTimeStep = 4;
modelTimeStep = 1;
domainLimits =  [-92,-80, 25, 31];
RungeKutta = 4;
particlesPerBarrel = 1/2;
TurbDiff = 2;
heights = [ 1500, 1000, 500, 100, 10];
coords = [95.01622889	25.97096444
95.25811667	25.36115583
96.56495556	24.75155556
96.82528583	23.51224639
96.71577028	20.97098889
94.76735833	20.04058889];
windFileTS = 3;

main_atmos(startDate, endDate, dataPath, codePath, saveFigTimeStep, modelTimeStep, domainLimits, RungeKutta, particlesPerBarrel, TurbDiff, heights, coords, windFileTS)
