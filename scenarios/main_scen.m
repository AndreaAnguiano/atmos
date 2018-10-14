function ensemble = main_scen(startDate, endDate, dataPath,codePath,outputPath, saveFigTimeStep, modelTimeStep, domainLimits, RungeKutta, particlesPerBarrel, TurbDiff, heights, coords, windFileTS, vis_maps, saving, individualSpill, years, month)

%------ spill timing -----------
spillTiming.startDay_date     = startDate; % [2010,04,22]
spillTiming.endSimDay_date = endDate; % [2010,07,14]
spillTiming.lastSpillDay_date = endDate;
spillTiming.startDay_serial = datenum(startDate);
spillTiming.endDay_serial   = datenum(endDate);
spillTiming.simulationDays  = 1 + spillTiming.endDay_serial - spillTiming.startDay_serial;
spillTiming.simulationHours  = saveFigTimeStep;
spillTiming.n_simulationHours  = length(spillTiming.simulationHours);
spillTiming.timeStep = 24/modelTimeStep; 
%-------spillLocation ---------
spillLocation.n_positions = length(coords);
spillLocation.n_Heights = length(heights);
spillLocation.Heights = heights;
spillLocation.positions = coords;
spillLocation.Radius_m = [ 250, 500, 500, 1000, 1000]; % 2 STD for random initialization of particles

%-------- model configuration ------
ModelConfig.dataPath = dataPath;
ModelConfig.RungeKutta = RungeKutta;
ModelConfig.particlesPerBarrel = particlesPerBarrel;
ModelConfig.TurbDiff_b = TurbDiff;
ModelConfig.saveFigTimeStep = saveFigTimeStep;
ModelConfig.domainLimits = domainLimits;
ModelConfig.OutputDir = outputPath;
ModelConfig.years = years;
ModelConfig.n_years = length(ModelConfig.years);

%---------paths------------------
addpath(genpath(codePath));
addpath(genpath(dataPath));

ensemble = 0;
LagrTimeStep.InHrs = modelTimeStep;
WindFile.timeStep_hrs = windFileTS;
datetemp = datenum(spillTiming.startDay_date);

    for year = 1:ModelConfig.n_years
        strtemp = 1;
        while datetemp < datenum([ModelConfig.years(year),month+1,01])
            vecdate = datevec(datetemp);
            spillTiming.startDay_date = [vecdate(1),vecdate(2),vecdate(3)];
            spillTiming.lastSpillDay_date = [vecdate(1),vecdate(2),vecdate(3)+2];
            spillTiming.endSimDay_date = spillTiming.lastSpillDay_date;
            spillLocation.Lat = spillLocation.positions(1,2);
            spillLocation.Lon = -spillLocation.positions(1);
            spillLocation.Point = 1;
            atmosModel(spillTiming,spillLocation,ModelConfig,WindFile,LagrTimeStep, vis_maps, saving, individualSpill,strtemp)
            spillLocation.Lat = spillLocation.positions(2,2);
            spillLocation.Lon = -spillLocation.positions(2);
            spillLocation.Point = 2;
            atmosModel(spillTiming,spillLocation,ModelConfig,WindFile,LagrTimeStep, vis_maps, saving, individualSpill,strtemp)
            spillLocation.Lat = spillLocation.positions(3,2);
            spillLocation.Lon = -spillLocation.positions(3);
            spillLocation.Point = 3;
            atmosModel(spillTiming,spillLocation,ModelConfig,WindFile,LagrTimeStep, vis_maps, saving, individualSpill,strtemp)
            spillLocation.Lat = spillLocation.positions(4,2);
            spillLocation.Lon = -spillLocation.positions(4);
            spillLocation.Point = 4;
            atmosModel(spillTiming,spillLocation,ModelConfig,WindFile,LagrTimeStep, vis_maps, saving, individualSpill,strtemp)
            spillLocation.Lat = spillLocation.positions(5,2);
            spillLocation.Lon = -spillLocation.positions(5);
            spillLocation.Point = 5;
            atmosModel(spillTiming,spillLocation,ModelConfig,WindFile,LagrTimeStep, vis_maps, saving, individualSpill,strtemp)
            spillLocation.Lat = spillLocation.positions(6,2);
            spillLocation.Lon = -spillLocation.positions(6);
            spillLocation.Point = 6;
            atmosModel(spillTiming,spillLocation,ModelConfig,WindFile,LagrTimeStep, vis_maps, saving, individualSpill,strtemp)
            strtemp = strtemp + 1;
            datetemp = datetemp +1;
        end 
        spillTiming.startDay_date = [spillTiming.startDay_date(1)+1,spillTiming.startDay_date(2),spillTiming.startDay_date(3)];
    end


end

