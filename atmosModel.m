function atmosModel(spillTiming,spillLocation,ModelConfig,WindFile,LagrTimeStep )
% Summary of this function goes here
%   Detailed explanation goes here

%Get daily spill quantities
% Distances are computed considering a mean Earth radius = 6371000 m (Gill)
DailyParticles = dailyParticles(ModelConfig.particlesPerBarrel, spillTiming);
Dcomp.meanEarthRadius = 6371000;
Dcomp.cst = 180/(Dcomp.meanEarthRadius*pi);

%Spill timing 
spillTiming.startDay_serial     = datenum(spillTiming.startDay_date);
spillTiming.lastSpillDay_serial = datenum(spillTiming.lastSpillDay_date);
spillTiming.endSimDay_serial    = datenum(spillTiming.endSimDay_date);
spillTiming.simulationDays      = 1 + spillTiming.endSimDay_serial - spillTiming.startDay_serial;
spillTiming.spillDays           = 1 + spillTiming.lastSpillDay_serial - spillTiming.startDay_serial;

%Spill location 
spillLocation.n_Heights     = numel(spillLocation.Heights_m);
spillLocation.Radius_degLat = mtr2deg(spillLocation.Radius_m, spillLocation.Lat, 'lat_deg', Dcomp);
spillLocation.Radius_degLon = mtr2deg(spillLocation.Radius_m, spillLocation.Lat, 'lon_deg', Dcomp);

% Used by releaseParticles
Particles  = [];
PartsPerTS = [];
last_ID    = 0;
%------------------------- Lagrangian time step --------------------------%
LagrTimeStep.InSec       = LagrTimeStep.InHrs*3600;
LagrTimeStep.InSec_half  = LagrTimeStep.InSec/2;
LagrTimeStep.InHrs_half  = LagrTimeStep.InHrs/2;
LagrTimeStep.InDays      = LagrTimeStep.InHrs/24;
LagrTimeStep.PerDay      = 24/LagrTimeStep.InHrs;
LagrTimeStep.TOTAL       = LagrTimeStep.PerDay*spillTiming.simulationDays;
LagrTimeStep.BTW_windsTS = LagrTimeStep.InHrs/WindFile.timeStep_hrs;

ModelConfig.TurbDiff_b./sqrt(LagrTimeStep.InHrs)

for SerialDay = spillTiming.startDay_serial:spillTiming.endSimDay_serial
  % Transform the SerialDay into a strig date
  day_str = datestr(SerialDay,'yyyy-mm-dd')
  disp([day_str,' ...'])
  day_Idx = find(DailyParticles.SerialDates == SerialDay);
  day_abs = SerialDay - (spillTiming.startDay_serial-1);
  % Cicle for Lagrangian time step
  for ts = 1:LagrTimeStep.PerDay
    first_time = SerialDay == spillTiming.startDay_serial && ts == 1;
    final_time = SerialDay == spillTiming.endSimDay_serial && ts == LagrTimeStep.PerDay;
    %¿ Get the current string date-hou
    hour_str = num2str((ts-1)*LagrTimeStep.InHrs);
    if numel(hour_str) == 1
      hour_str = strcat('0',hour_str);
    end
    dateHour_str = [day_str,' h ',hour_str];
    % Release new particles 
    if SerialDay <= spillTiming.lastSpillDay_serial && DailyParticles.Net > 0
      [last_ID,Particles,PartsPerTS] = releaseParticles(day_abs,ts,spillTiming,spillLocation,DailyParticles,first_time,...
        PartsPerTS,Particles,last_ID,ModelConfig,LagrTimeStep);
    end
    %Get velocity fields
    [velocities,WindFile] = velocityFields_atm(first_time,SerialDay,ts,LagrTimeStep,spillLocation,WindFile,ModelConfig);
   %-------------------------- Move particles ---------------------------%
    if ModelConfig.RungeKutta == 4
      Particles = movePartsRK4(velocities,WindFile,Particles,ModelConfig,...
        spillLocation,LagrTimeStep,Dcomp,ts);
    elseif ModelConfig.RungeKutta == 2
      Particles = movePartsRK2(velocities,Particles,ModelConfig,...
        spillLocation,LagrTimeStep,Dcomp,ts);
    else
      error('Unknown Runge-Kutta method')
    end
end 
end

