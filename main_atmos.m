function ensemble = main_atmos(startDate, endDate, dataPath,codePath, saveFigTimeStep, modelTimeStep, domainLimits, RungeKutta, particlesPerBarrel, TurbDiff, heights, coords, windFileTS)

%------ spill timing -----------
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
ModelConfig.saveFigTimeStep = saveFigTimeStep;

%---------paths------------------
addpath(genpath(codePath));
addpath(dataPath);

ensemble = 0;

for serialDay = spillTiming.startDay_serial:spillTiming.endDay_serial
    spillTiming.dateStr = datestr(serialDay,'yyyy-mm-dd');
    for ts = 1:spillTiming.timeStep
        for position = 1:spillLocation.n_positions
            spillLocation.currPosition = position;
            atmosModel(spillTiming,spillLocation,ModelConfig,windFileTS,modelTimeStep)
        end

    end
end 

end

