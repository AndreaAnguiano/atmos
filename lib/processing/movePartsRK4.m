% Routine for computing trajectories of virtual particles in velocity fields.
% A 4th order Runge-Kutta scheme is used.

function Particles = movePartsRK4(velocities,WindFile,Particles,ModelConfig,...
  spillLocation,LagrTimeStep,Dcomp,ts)
% Compute velocities for the current time_step plus half time_step
U_half = velocities.Uts1 + (velocities.Uts2-velocities.Uts1)/2;
V_half = velocities.Vts1 + (velocities.Vts2-velocities.Vts1)/2;
for HeightLayer = 1 : spillLocation.n_Heights
  % Get position1 of particles to move
  height_ind = find(Particles.Height == spillLocation.Heights(HeightLayer));
  position1lat = Particles.Lat(height_ind);
  position1lon = Particles.Lon(height_ind);
  
  % Interpolate U and V to position1
  Upart1 = interp2(WindFile.Ulon, WindFile.Ulat, velocities.Uts1(:,:,HeightLayer), position1lon, position1lat);
  Vpart1 = interp2(WindFile.Vlon, WindFile.Vlat, velocities.Vts1(:,:,HeightLayer), position1lon, position1lat);
  
  % Move particles from position1 to dt/2 * Vpart1
  position2lat = position1lat + (LagrTimeStep.InSec_half*Vpart1)*Dcomp.cst;
  position2lon = position1lon + ((LagrTimeStep.InSec_half*Upart1)*Dcomp.cst).*cosd(position1lat);
  
  % Check for particles outside the domain
  %{
    outDom_Idx = ...
    position2lon < ModelConfig.domainLimits(1) | position2lon > ModelConfig.domainLimits(2) |...
    position2lat < ModelConfig.domainLimits(3) | position2lat > ModelConfig.domainLimits(4);
  if any(outDom_Idx)
    Particles.Status(height_ind(outDom_Idx)) = 3;
    position2lat(outDom_Idx) = [];
    position2lon(outDom_Idx) = [];
    position1lat(outDom_Idx) = [];
    position1lon(outDom_Idx) = [];
    Upart1(outDom_Idx) = [];
    Vpart1(outDom_Idx) = [];
    height_ind(outDom_Idx) = [];
  end
  %}
  
  % Interpolate U and V to position2 using velocities at DT + DT/2 (U_half, V_half)
  Upart2 = interp2(WindFile.Ulon, WindFile.Ulat, U_half(:,:,HeightLayer), position2lon, position2lat);
  Vpart2 = interp2(WindFile.Vlon, WindFile.Vlat, V_half(:,:,HeightLayer), position2lon, position2lat);
  
  % Move particles from position1 to dt/2 * Vpart2
  position3lat = position1lat + (LagrTimeStep.InSec_half*Vpart2)*Dcomp.cst;
  position3lon = position1lon + ((LagrTimeStep.InSec_half*Upart2)*Dcomp.cst).*cosd(position1lat);
  
  % Check for particles outside the domain
  %{
    outDom_Idx =...
    position3lon < ModelConfig.domainLimits(1) | position3lon > ModelConfig.domainLimits(2) |...
    position3lat < ModelConfig.domainLimits(3) | position3lat > ModelConfig.domainLimits(4);
  if any(outDom_Idx)
    Particles.Status(height_ind(outDom_Idx)) = 3;
    position3lat(outDom_Idx) = [];
    position3lon(outDom_Idx) = [];
    position1lat(outDom_Idx) = [];
    position1lon(outDom_Idx) = [];
    Upart2(outDom_Idx) = [];
    Vpart2(outDom_Idx) = [];
    Upart1(outDom_Idx) = [];
    Vpart1(outDom_Idx) = [];
    height_ind(outDom_Idx) = [];
  end
  %}
  % Interpolate U and V to position3 using velocities at DT + DT/2 (U_half, V_half)
  Upart3 = interp2(WindFile.Ulon, WindFile.Ulat, U_half(:,:,HeightLayer), position3lon, position3lat);
  Vpart3 = interp2(WindFile.Ulon, WindFile.Ulat, V_half(:,:,HeightLayer), position3lon, position3lat);
  
  % Move particles from position1 to dt * Vpart3
  position4lat = position1lat + (LagrTimeStep.InSec*Vpart3)*Dcomp.cst;
  position4lon = position1lon + ((LagrTimeStep.InSec*Upart3)*Dcomp.cst).*cosd(position1lat);
  
  % Check for particles outside the domain
  outDom_Idx =...
    position4lon < ModelConfig.domainLimits(1) | position4lon > ModelConfig.domainLimits(2) |...
    position4lat < ModelConfig.domainLimits(3) | position4lat > ModelConfig.domainLimits(4);
  if any(outDom_Idx)
    Particles.Status(height_ind(outDom_Idx)) = 3;
    position4lat(outDom_Idx) = [];
    position4lon(outDom_Idx) = [];
    position1lat(outDom_Idx) = [];
    position1lon(outDom_Idx) = [];
    Upart1(outDom_Idx) = [];
    Vpart1(outDom_Idx) = [];
    Upart2(outDom_Idx) = [];
    Vpart2(outDom_Idx) = [];
    Upart3(outDom_Idx) = [];
    Vpart3(outDom_Idx) = [];
    height_ind(outDom_Idx) = [];
  end
  
  % Interpolate U and V to position4 using velocities at next DT (Uts2, Vts2)
  Upart4 = interp2(WindFile.Ulon, WindFile.Ulat, velocities.Uts2(:,:,HeightLayer), position4lon, position4lat);
  Vpart4 = interp2(WindFile.Ulon, WindFile.Ulat, velocities.Vts2(:,:,HeightLayer), position4lon, position4lat);
  
  % Compute the final velocity
  UpartF = (Upart1 + 2*Upart2 + 2*Upart3 + Upart4)/6;
  VpartF = (Vpart1 + 2*Vpart2 + 2*Vpart3 + Vpart4)/6;
  
  % Add turbulent-diffusion
  Uturb = UpartF .* (-ModelConfig.TurbDiff_b + (2*ModelConfig.TurbDiff_b) .* rand(length(UpartF),1));
  Vturb = VpartF .* (-ModelConfig.TurbDiff_b + (2*ModelConfig.TurbDiff_b) .* rand(length(VpartF),1));
  UpartF = UpartF + Uturb;
  VpartF = VpartF + Vturb;
  
  % Move particles from position1 to dt * VpartF
  newLatP = position1lat +  (LagrTimeStep.InSec*VpartF)*Dcomp.cst;
  newLonP = position1lon + ((LagrTimeStep.InSec*UpartF)*Dcomp.cst).*cosd(position1lat);
  
  %{
  Check for particles outside the domain
  outDom_Idx =...
    newLonP < ModelConfig.domainLimits(1) | newLonP > ModelConfig.domainLimits(2) |...
    newLatP < ModelConfig.domainLimits(3) | newLatP > ModelConfig.domainLimits(4);
  if any(outDom_Idx)
    Particles.Status(height_ind(outDom_Idx)) = 3;
    newLatP(outDom_Idx) = [];
    newLonP(outDom_Idx) = [];
    height_ind(outDom_Idx) = [];
  end
  
  % Find particles in water
  inWater = ~(isnan(newLatP) | isnan(newLonP));
  
  % Update positions of particles in water
  Particles.Lat(height_ind(inWater)) = newLatP(inWater);
  Particles.Lon(height_ind(inWater)) = newLonP(inWater);
  
  % Update the status of particles in land
  Particles.Status(height_ind(~inWater)) = 2;
end
% Update the age (in days) of particles in water
Particles.Age_days(Particles.Status == 1) = Particles.Age_days(Particles.Status == 1) + ts*LagrTimeStep.InDays;
  %}
end