function [velocities, WindFile ] = velocityFields_atm( first_time,SerialDay,ts,...
    LagrTimeStep,spillLocation,WindFile,ModelConfig )
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here
date_time = datetime(SerialDay,'ConvertFrom','datenum');
day_DoY = day(date_time,'dayofyear');
year_str = datestr(date_time,'yyyy');
month_MoY = month(date_time, 'monthofyear');
day_DoM = day(date_time, 'dayofmonth');
WindFile.Sufix = strcat('_00:00:00.',year_str);
%--------------------------Get wind VectorFields--------------------------%
  if first_time
    % Wind file names and varible names
    WindFile.Prefix3h = 'wrfout_c3h_d01_';
    WindFile.Prefix1h = 'wrfout_c1h_d01_';
    WindFile.Uname = 'U';
    WindFile.Vname = 'V';
    WindFile.Wname = 'W';
    WindFile.CoorPrefix = 'wrfout_c15d_d01_';
    WindFile.Pname = 'P';
    WindFile.PBname = 'PB';
    ModelConfig.cont = 1;
    % Define variables
    firstFileName3H = [WindFile.Prefix3h,year_str,'-',num2str(month_MoY, '%02d'),'-',num2str(day_DoM,'%02d'),WindFile.Sufix];
    coordFileName =  'wrfout_c15d_d01_2010-01-01_00:00:00.2010';
    
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
        [WindFile.U10lon, WindFile.U10lat] = meshgrid(U10lon,U10lat);
        readWindU10File = [WindFile.Prefix1h,year_str,'-',num2str(month_MoY, '%02d'),'-',num2str(day_DoM,'%02d'),WindFile.Sufix];
        
        WindFile.U10_T1 =  ncread(readWindU10File,'U10',[WindFile.U10Lon_min,WindFile.U10Lat_min,1],[WindFile.U10Lon_numel,WindFile.U10Lat_numel,1]);
        WindFile.U10_T2 =  ncread(readWindU10File,'U10',[WindFile.U10Lon_min,WindFile.U10Lat_min,2],[WindFile.U10Lon_numel,WindFile.U10Lat_numel,1]);
        WindFile.V10_T1 =  ncread(readWindU10File,'V10',[WindFile.U10Lon_min,WindFile.U10Lat_min,1],[WindFile.U10Lon_numel,WindFile.U10Lat_numel,1]);
        WindFile.V10_T2 =  ncread(readWindU10File,'V10',[WindFile.U10Lon_min,WindFile.U10Lat_min,2],[WindFile.U10Lon_numel,WindFile.U10Lat_numel,1]);
        WindFile.U10_T1 = permute(WindFile.U10_T1,[2 1 3]);
        WindFile.V10_T1 = permute(WindFile.V10_T1,[2 1 3]);
        WindFile.U10_T2 = permute(WindFile.U10_T2,[2 1 3]);
        WindFile.V10_T2 = permute(WindFile.V10_T2,[2 1 3]);
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
     
    % pressure levels for heigths = [1500, 1000, 500, 100]
    PlevelsIndx = [9, 7, 4, 1];
    WindFile.Plevels_min = min(PlevelsIndx);
    WindFile.Plevels_max = max(PlevelsIndx);
    WindFile.n_Plevels = numel(PlevelsIndx);
    
   %read wind for the current and next day
    readWindFile = [WindFile.Prefix3h,year_str,'-',num2str(month_MoY, '%02d'),'-',num2str(day_DoM,'%02d'),WindFile.Sufix];
    WindFile.U_T1 =  ncread(readWindFile,WindFile.Uname,[WindFile.ULon_min,WindFile.ULat_min,WindFile.Plevels_min,1],...
        [WindFile.Ulon_numel,WindFile.Ulat_numel,WindFile.n_Plevels,1]);
    WindFile.U_T2 =  ncread(readWindFile,WindFile.Uname,[WindFile.ULon_min,WindFile.ULat_min,WindFile.Plevels_min,2],...
        [WindFile.Ulon_numel,WindFile.Ulat_numel,WindFile.n_Plevels,1]);
    
    WindFile.V_T1 =  ncread(readWindFile,WindFile.Uname,[WindFile.VLon_min,WindFile.VLat_min,WindFile.Plevels_min,1],...
        [WindFile.Vlon_numel,WindFile.Vlat_numel,WindFile.n_Plevels,1]);
    WindFile.V_T2 =  ncread(readWindFile,WindFile.Uname,[WindFile.VLon_min,WindFile.VLat_min,WindFile.Plevels_min,2],...
        [WindFile.Vlon_numel,WindFile.Vlat_numel,WindFile.n_Plevels,1]);
    %
    WindFile.U_T1 = permute(WindFile.U_T1,[2 1 3]);
    WindFile.V_T1 = permute(WindFile.V_T1,[2 1 3]);
    WindFile.U_T2 = permute(WindFile.U_T2,[2 1 3]);
    WindFile.V_T2 = permute(WindFile.V_T2,[2 1 3]);
    %}
    
  else
    
    if ismember(10, spillLocation.Heights)
    
    WindFile.U10_T1 = WindFile.U10_T2;
    WindFile.V10_T1 = WindFile.V10_T2;
    if ts == 24
        if day_DoM+1 >= eomday(str2num(year_str),month_MoY)
            readWindFile = [WindFile.Prefix3h,year_str,'-',num2str(month_MoY+1, '%02d'),'-',num2str(1,'%02d'),WindFile.Sufix];
            if month_MoY+1 > 12
                readWindFile = [WindFile.Prefix3h,num2str(str2num(year_str)+1, '%02d'),'-',num2str(1, '%02d'),'-',num2str(1,'%02d'),strcat('_00:00:00.',num2str(str2num(year_str)+1, '%02d'))];
            end
            WindFile.U_T2 = ncread(readWindFile,WindFile.Uname,[WindFile.ULon_min,WindFile.ULat_min,WindFile.n_Plevels,1],...
          [WindFile.Ulon_numel,WindFile.Ulat_numel,WindFile.n_Plevels,1]);
            WindFile.V_T2 = ncread(readWindFile,WindFile.Vname,[WindFile.VLon_min,WindFile.VLat_min,WindFile.n_Plevels,1],...
          [WindFile.Vlon_numel,WindFile.Vlat_numel,WindFile.n_Plevels,1]);
            WindFile.U_T2 = permute(WindFile.U_T2,[2 1 3]);
            WindFile.V_T2 = permute(WindFile.V_T2,[2 1 3]);

        else
            readWindFile = [WindFile.Prefix1h,year_str,'-',num2str(month_MoY, '%02d'),'-',num2str(day_DoM+1,'%02d'),WindFile.Sufix];
            WindFile.U10_T2 = ncread(readWindFile,'U10',[WindFile.U10Lon_min,WindFile.U10Lat_min,1],[WindFile.U10Lon_numel,WindFile.U10Lat_numel,1]);
            WindFile.V10_T2 = ncread(readWindFile,'U10',[WindFile.U10Lon_min,WindFile.U10Lat_min,1],[WindFile.U10Lon_numel,WindFile.U10Lat_numel,1]);
            WindFile.U10_T2 = permute(WindFile.U10_T2,[2 1 3]);
            WindFile.V10_T2 = permute(WindFile.V10_T2,[2 1 3]);
        end
    else
        readWindU10File = [WindFile.Prefix1h,year_str,'-',num2str(month_MoY, '%02d'),'-',num2str(day_DoM,'%02d'),WindFile.Sufix];
        WindFile.U10_T2 =  ncread(readWindU10File,'U10',[WindFile.U10Lon_min,WindFile.U10Lat_min,ts],[WindFile.U10Lon_numel,WindFile.U10Lat_numel,1]);
        WindFile.V10_T2 =  ncread(readWindU10File,'V10',[WindFile.U10Lon_min,WindFile.U10Lat_min,ts],[WindFile.U10Lon_numel,WindFile.U10Lat_numel,1]);
        WindFile.U10_T2 = permute(WindFile.U10_T2,[2 1 3]);
        WindFile.V10_T2 = permute(WindFile.V10_T2,[2 1 3]);
    end
    end
      
      
    % Rename and read wind VectorFields from the next file
    if (ts-1) == 0 && ~first_time
        readWindFile = [WindFile.Prefix3h,year_str,'-',num2str(month_MoY, '%02d'),'-',num2str(day_DoM,'%02d'),WindFile.Sufix];
        WindFile.U_T1 =  ncread(readWindFile,WindFile.Uname,[WindFile.ULon_min,WindFile.ULat_min,WindFile.Plevels_min,1],...
        [WindFile.Ulon_numel,WindFile.Ulat_numel,WindFile.n_Plevels,1]);
        WindFile.U_T2 =  ncread(readWindFile,WindFile.Uname,[WindFile.ULon_min,WindFile.ULat_min,WindFile.Plevels_min,2],...
        [WindFile.Ulon_numel,WindFile.Ulat_numel,WindFile.n_Plevels,1]);
    
        WindFile.V_T1 =  ncread(readWindFile,WindFile.Uname,[WindFile.VLon_min,WindFile.VLat_min,WindFile.Plevels_min,1],...
        [WindFile.Vlon_numel,WindFile.Vlat_numel,WindFile.n_Plevels,1]);
        WindFile.V_T2 =  ncread(readWindFile,WindFile.Uname,[WindFile.VLon_min,WindFile.VLat_min,WindFile.Plevels_min,2],...
        [WindFile.Vlon_numel,WindFile.Vlat_numel,WindFile.n_Plevels,1]);
    %
        WindFile.U_T1 = permute(WindFile.U_T1,[2 1 3]);
        WindFile.V_T1 = permute(WindFile.V_T1,[2 1 3]);
        WindFile.U_T2 = permute(WindFile.U_T2,[2 1 3]);
        WindFile.V_T2 = permute(WindFile.V_T2,[2 1 3]);
        
    end 

  flag_one = floor((ts-2)*LagrTimeStep.BTW_windsTS);
  flag_two = floor((ts-1)*LagrTimeStep.BTW_windsTS);
  count = floor((ts-1)/WindFile.timeStep_hrs)+1;
    % Rename and read ocean VectorFields for the next WindFileTs
     %este renglon es para cambiar de día %readWindFile = [WindFile.Prefix3h,year_str,'-',num2str(month_MoY, '%02d'),'-',num2str(day_DoM+1,'%02d'),WindFile.Sufix];
   if flag_one ~= flag_two && flag_one >= 0
    readWindFile = [WindFile.Prefix3h,year_str,'-',num2str(month_MoY, '%02d'),'-',num2str(day_DoM,'%02d'),WindFile.Sufix];
    WindFile.U_T1 = WindFile.U_T2;
    WindFile.V_T1 = WindFile.V_T2;
    if count == 8
        if day_DoM+1 >= eomday(str2num(year_str),month_MoY)
            readWindFile = [WindFile.Prefix3h,year_str,'-',num2str(month_MoY+1, '%02d'),'-',num2str(1,'%02d'),WindFile.Sufix];
            if month_MoY+1 > 12
                readWindFile = [WindFile.Prefix3h,num2str(str2num(year_str)+1, '%02d'),'-',num2str(1, '%02d'),'-',num2str(1,'%02d'),strcat('_00:00:00.',num2str(str2num(year_str)+1, '%02d'))];
            end
            WindFile.U_T2 = ncread(readWindFile,WindFile.Uname,[WindFile.ULon_min,WindFile.ULat_min,WindFile.n_Plevels,1],...
          [WindFile.Ulon_numel,WindFile.Ulat_numel,WindFile.n_Plevels,1]);
            WindFile.V_T2 = ncread(readWindFile,WindFile.Vname,[WindFile.VLon_min,WindFile.VLat_min,WindFile.n_Plevels,1],...
          [WindFile.Vlon_numel,WindFile.Vlat_numel,WindFile.n_Plevels,1]);
            WindFile.U_T2 = permute(WindFile.U_T2,[2 1 3]);
            WindFile.V_T2 = permute(WindFile.V_T2,[2 1 3]);
        else
            readWindFile = [WindFile.Prefix3h,year_str,'-',num2str(month_MoY, '%02d'),'-',num2str(day_DoM+1,'%02d'),WindFile.Sufix];
            WindFile.U_T2 = ncread(readWindFile,WindFile.Uname,[WindFile.ULon_min,WindFile.ULat_min,WindFile.n_Plevels,1],...
          [WindFile.Ulon_numel,WindFile.Ulat_numel,WindFile.n_Plevels,1]);
            WindFile.V_T2 = ncread(readWindFile,WindFile.Vname,[WindFile.VLon_min,WindFile.VLat_min,WindFile.n_Plevels,1],...
          [WindFile.Vlon_numel,WindFile.Vlat_numel,WindFile.n_Plevels,1]);
            WindFile.U_T2 = permute(WindFile.U_T2,[2 1 3]);
            WindFile.V_T2 = permute(WindFile.V_T2,[2 1 3]);
        end
        
    else
        WindFile.U_T2 = ncread(readWindFile,WindFile.Uname,[WindFile.ULon_min,WindFile.ULat_min,WindFile.n_Plevels,count+1],...
          [WindFile.Ulon_numel,WindFile.Ulat_numel,WindFile.n_Plevels,1]);
        WindFile.V_T2 = ncread(readWindFile,WindFile.Vname,[WindFile.VLon_min,WindFile.VLat_min,WindFile.n_Plevels,count+1],...
          [WindFile.Vlon_numel,WindFile.Vlat_numel,WindFile.n_Plevels,1]);
            WindFile.U_T2 = permute(WindFile.U_T2,[2 1 3]);
            WindFile.V_T2 = permute(WindFile.V_T2,[2 1 3]);
    end
    

   end
  end

    %--------------Interp VectorFields (temporal interpolation)---------------%
time_dif = (ts-1) * LagrTimeStep.InHrs;

% Velocities for current time-step
wind_U_factor = (WindFile.U_T2 - WindFile.U_T1) ./ WindFile.timeStep_hrs;
wind_V_factor = (WindFile.V_T2 - WindFile.V_T1) ./ WindFile.timeStep_hrs;

velocities.U10ts1     = WindFile.U10_T1;
velocities.V10ts1     = WindFile.V10_T1;

velocities.Uts1     = WindFile.U_T1 + time_dif .* wind_U_factor;
velocities.Vts1     = WindFile.V_T1 + time_dif .* wind_V_factor;

 % Velocities for next time-step
TimeDiff_plus_TS = time_dif + LagrTimeStep.InHrs;


velocities.U10ts2 = WindFile.U10_T2;
velocities.V10ts2 = WindFile.V10_T2;
velocities.Uts2 = WindFile.U_T1 + TimeDiff_plus_TS .* wind_U_factor;
velocities.Vts2 = WindFile.V_T1 + TimeDiff_plus_TS .* wind_V_factor;
 

end
