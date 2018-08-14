function [velocities, WindFile ] = velocityFields_atm( first_time,SerialDay,ts,...
    LagrTimeStep,spillLocation,WindFile,ModelConfig )
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here
date_time = datetime(SerialDay,'ConvertFrom','datenum');
day_DoY = day(date_time,'dayofyear');
year_str = datestr(date_time,'yyyy');
month_MoY = month(date_time, 'monthofyear');
day_DoM = day(date_time, 'dayofmonth');
%--------------------------Get wind VectorFields--------------------------%
  if first_time
    % Wind file names and varible names
    WindFile.Prefix3h = 'wrfout_c3h_d01_';
    WindFile.Prefix1h = 'wrfout_c1h_d01_';
    WindFile.Sufix = strcat('_00:00:00.',year_str, '.nc');
    WindFile.Uname = 'U';
    WindFile.Vname = 'V';
    WindFile.Wname = 'W';
    WindFile.CoorPrefix = 'wrfout_c15d_d01_';
    WindFile.Pname = 'P';
    WindFile.PBname = 'PB';
    
    % Define variables
    firstFileName3H = [WindFile.Prefix3h,year_str,'-',num2str(month_MoY, '%02d'),'-',num2str(day_DoM,'%02d'),WindFile.Sufix];
    coordFileName =  'wrfout_c15d_d01_2010-01-01_00_00_00.2010.nc';
    
    if ismember(10, spillLocation.Heights)
        firstFileName1H = [WindFile.Prefix1h,year_str,'-',num2str(month_MoY, '%02d'),'-',num2str(day_DoM,'%02d'),WindFile.Sufix];        
        U10lat = double(ncread(coordFileName,'XLAT'));
        U10lon = double(ncread(coordFileName,'XLONG'));
        WindFile.U10Lat_min = find(U10lat(1,:)' <= ModelConfig.domainLimits(3),1,'last');
        WindFile.U10Lat_max = find(U10lat(1,:)' >= ModelConfig.domainLimits(4),1,'first');
        WindFile.U10Lon_min = find(U10lon(:,1) <= ModelConfig.domainLimits(1),1,'last');
        WindFile.U10Lon_max = find(U10lon(:,1) >= ModelConfig.domainLimits(2),1,'first');
        U10lat = U10lat(1,WindFile.U10Lat_min:WindFile.U10Lat_max)';
        U10lon = U10lon(WindFile.U10Lon_min:WindFile.U10Lon_max,1);
        WindFile.U10Lat_numel = numel(U10lat);
        WindFile.U10Lon_numel = numel(U10lon);
        [WindFile.U10lat, WindFile.U10lon] = meshgrid(U10lon,U10lat);
    end
    
    Ulat = double(ncread(coordFileName, 'XLAT_U'));
    Vlat = double(ncread(coordFileName, 'XLAT_V'));
    Ulon =double(ncread(coordFileName, 'XLONG_U'));
    Vlon = double(ncread(coordFileName, 'XLONG_V'));
    
    WindFile.ULat_min = find(Ulat(1,:)' <= ModelConfig.domainLimits(3),1,'last');
    WindFile.ULat_max = find(Ulat(1,:)' >= ModelConfig.domainLimits(4),1,'first');
    
    WindFile.VLat_min = find(Vlat(1,:)' <= ModelConfig.domainLimits(3),1,'last');
    WindFile.VLat_max = find(Vlat(1,:)' >= ModelConfig.domainLimits(4),1,'first');
    
    WindFile.ULon_min = find(Ulon(:,1) <= ModelConfig.domainLimits(1),1,'last');
    WindFile.ULon_max = find(Ulon(:,1) >= ModelConfig.domainLimits(2),1,'first');
    
    WindFile.VLon_min = find(Vlon(:,1) <= ModelConfig.domainLimits(1),1,'last');
    WindFile.VLon_max = find(Vlon(:,1) >= ModelConfig.domainLimits(2),1,'first');
    
    Ulat = Ulat(1,WindFile.ULat_min:WindFile.ULat_max)';
    Vlat = Vlat(1,WindFile.VLat_min:WindFile.VLat_max)';
    
    Ulon = Ulon(WindFile.ULon_min:WindFile.ULon_max,1);
    Vlon = Vlon(WindFile.VLon_min:WindFile.VLon_max,1);
    
    WindFile.Ulat_numel = numel(Ulat);
    WindFile.Ulon_numel = numel(Ulon);

    WindFile.Vlat_numel = numel(Vlat);
    WindFile.Vlon_numel = numel(Vlon);
    
    [WindFile.Ulon, WindFile.Ulat] = meshgrid(Ulon,Ulat);
    [WindFile.Vlon, WindFile.Vlat] = meshgrid(Vlon,Vlat);
     
    % pressure levels for heigths = [1500, 1000, 500, 100, 10]
    PlevelsIndx = [9, 7, 4, 2, 1];
    WindFile.Plevels_min = min(PlevelsIndx);
    WindFile.Plevels_max = max(PlevelsIndx);
    WindFile.n_Plevels = numel(PlevelsIndx);
    
   %read wind for the current and next day
    readWindFileT1 = [WindFile.Prefix3h,year_str,'-',num2str(month_MoY, '%02d'),'-',num2str(day_DoM,'%02d'),WindFile.Sufix];
    readWindFileT2 = [WindFile.Prefix3h,year_str,'-',num2str(month_MoY, '%02d'),'-',num2str(day_DoM+1,'%02d'),WindFile.Sufix];
    
    WindFile.U_T1 =  ncread(readWindFileT1,WindFile.Uname,[WindFile.ULon_min,WindFile.ULat_min,...
    WindFile.Plevels_min,1],[WindFile.Ulon_numel,WindFile.Ulat_numel,WindFile.n_Plevels,1]);
    WindFile.U_T2 =  ncread(readWindFileT2,WindFile.Uname,[WindFile.ULon_min,WindFile.ULat_min,...
    WindFile.Plevels_min,1],[WindFile.Ulon_numel,WindFile.Ulat_numel,WindFile.n_Plevels,1]);
    
    WindFile.V_T1 =  ncread(readWindFileT1,WindFile.Vname,[WindFile.VLon_min,WindFile.VLat_min,...
    WindFile.Plevels_min,1],[WindFile.Vlon_numel,WindFile.Vlat_numel,WindFile.n_Plevels,1]);
    WindFile.V_T2 =  ncread(readWindFileT2,WindFile.Vname,[WindFile.VLon_min,WindFile.VLat_min,...
    WindFile.Plevels_min,1],[WindFile.Vlon_numel,WindFile.Vlat_numel,WindFile.n_Plevels,1]);
    
    WindFile.U_T1 = permute(WindFile.U_T1,[2 1 3]);
    WindFile.V_T1 = permute(WindFile.V_T1,[2 1 3]);
    WindFile.U_T2 = permute(WindFile.U_T2,[2 1 3]);
    WindFile.V_T2 = permute(WindFile.V_T2,[2 1 3]);
    
else
    % Rename and read wind VectorFields from the next file
  flag_one = floor((ts-2)*LagrTimeStep.BTW_windsTS);
  flag_two = floor((ts-1)*LagrTimeStep.BTW_windsTS);
  if flag_one ~= flag_two
    % Rename and read ocean VectorFields for the next day
    readOceanFile = [WindFile.Prefix3h,year_str,'-',num2str(month_MoY, '%02d'),'-',num2str(day_DoM+1,'%02d'),WindFile.Sufix];
    WindFile.U_T1 = WindFile.U_T2;
    WindFile.V_T1 = WindFile.V_T2;
    WindFile.U_T2 = ncread(readOceanFile,WindFile.Uname,...
      [WindFile.ULon_min,WindFile.ULat_min,WindFile.n_Plevels,1],...
      [WindFile.Ulon_numel,WindFile.Ulat_numel,WindFile.n_Plevels,1]);
    WindFile.V_T2 = ncread(readOceanFile,WindFile.Vname,...
      [WindFile.VLon_min,WindFile.VLat_min,WindFile.n_Plevels,1],...
      [WindFile.Vlon_numel,WindFile.Vlat_numel,WindFile.n_Plevels,1]);
    WindFile.U_T2 = permute(WindFile.U_T2,[2 1 3]);
    WindFile.V_T2 = permute(WindFile.V_T2,[2 1 3]);
  end
end 
    %--------------Interp VectorFields (temporal interpolation)---------------%
time_dif = (ts-1) * LagrTimeStep.InHrs;

% Velocities for current time-step
wind_U_factor = (WindFile.U_T2 - WindFile.U_T1) ./ WindFile.timeStep_hrs;
wind_V_factor = (WindFile.V_T2 - WindFile.V_T1) ./ WindFile.timeStep_hrs;
velocities.Uts1     = WindFile.U_T1 + time_dif .* wind_U_factor;
velocities.Vts1     = WindFile.V_T1 + time_dif .* wind_V_factor;
 % Velocities for next time-step
TimeDiff_plus_TS = time_dif + LagrTimeStep.InHrs;
velocities.Uts2 = WindFile.U_T1 + TimeDiff_plus_TS .* wind_U_factor;
velocities.Vts2 = WindFile.V_T1 + TimeDiff_plus_TS .* wind_V_factor;
 

end

