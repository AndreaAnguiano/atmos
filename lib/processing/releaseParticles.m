function  [last_ID,Particles,PartsPerTS] = releaseParticles(day_abs,ts,spillTiming,spillLocation,DailyParticles,first_time,...
PartsPerTS,Particles,last_ID,ModelConfig,LagrTimeStep)
%Function for release of particles each ts
%   Detailed explanation goes here
 if first_time
  firstSpillDay_Idx = find(DailyParticles.SerialDates == spillTiming.startDay_serial);
  finalSpillDay_Idx = find(DailyParticles.SerialDates == spillTiming.lastSpillDay_serial);
  if isempty(DailyParticles.Net)
      PartsPerTS.Daily = 0;
  else
      PartsPerTS.Daily = DailyParticles.Net;
  end 
  
  Particles.Lat           = nan(spillLocation.n_Heights,PartsPerTS.Daily);
  Particles.Lon           = nan(spillLocation.n_Heights,PartsPerTS.Daily);
  Particles.Status        = nan(spillLocation.n_Heights,PartsPerTS.Daily);
  Particles.Height        = ones(spillLocation.n_Heights,PartsPerTS.Daily);
  Particles.Age_days      = nan(spillLocation.n_Heights,PartsPerTS.Daily);
  
 end
NewLats     = nan(spillLocation.n_Heights, PartsPerTS.Daily);
NewLons     = nan(spillLocation.n_Heights, PartsPerTS.Daily);
NewStatus   = ones(spillLocation.n_Heights, PartsPerTS.Daily);
NewAges   = ones(spillLocation.n_Heights, PartsPerTS.Daily);


for height_cicle = 1 : spillLocation.n_Heights
    for Part_indx = 1:PartsPerTS.Daily
        NewLats(height_cicle, Part_indx) = spillLocation.Lat + randn(1) .*...
        spillLocation.Radius_degLat(height_cicle);
        NewLons(height_cicle, Part_indx) = spillLocation.Lon + randn(1) .*...
        spillLocation.Radius_degLon(height_cicle);
        NewHeights(height_cicle, Part_indx) = height_cicle;
end
Particles.Status  = NewStatus;
Particles.Lat   = NewLats;
Particles.Lon   = NewLons;
Particles.Height = NewHeights;
Particles.Ages = NewAges;
end

