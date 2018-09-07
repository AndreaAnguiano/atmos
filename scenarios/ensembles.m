function ensembles(outputFolder,ts,first_time,final_time,spillLocation,Particles,vis_maps,...
  saving,ensemble_grid,Map_fig3D,Map_fig2D,dateHour_str,Params)
%ENSEMBLES Summary of this function goes here
%   Detailed explanation goes here
if first_time
    ensemble_grid.lat = vis_maps.boundaries(4):-km2deg(5):vis_maps.boundaries(3);
    ensemble_grid.lon = vis_maps.boundaries(1):km2deg(5):vis_maps.boundaries(2);
    ensemble_grid.count = nan(numel(ensemble_grid.lat),numel(ensemble_grid.lon),...
      spillLocation.n_Heights,length(saving.ts));
    ensemble_grid.Point = spillLocation.Point;
else
     for depth_cicle = 1:spillLocation.n_Heights
        for parts_cicle = depth_cicle
          lat_idx = find(ensemble_grid.lat <= Particles.Lat(parts_cicle),1,'first');
          lon_idx = find(ensemble_grid.lon <= Particles.Lon(parts_cicle),1,'last');
            ensemble_grid.count(lat_idx,lon_idx,depth_cicle) = ...
              nansum([ensemble_grid.count(lat_idx,lon_idx,depth_cicle);1]);
     
     for time_step =1:length(saving.ts)
        if ismember(time_step,saving.ts)
            for depth_cicle = 1:spillLocation.n_Heights
                 max_val = max(max(max(ensemble_grid.count(:,:,depth_cicle,time_step),[],4)));
                 caxis(log([1,max_val*.1]))
                 img_name = [dateHour_str(1:4), '_Position',currentPosition, ' ',num2str(spillLocation.Heights(depth_cicle)),'m'];
                 title(img_name)
                 hpc = pcolor(ensemble_grid.lon,ensemble_grid.lat,...
                 ensemble_grid.count(:,:,depth_cicle,time_step)); shading flat;
                 uistack(hpc,'bottom')
                 ens_name = [dateHour_str(1:4), '-Position',currentPosition, ' ']
            end
        end
     end
 end
 
% Plot base ensemble map
 
 end
 end

end

