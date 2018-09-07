function [Map_fig3D,Map_fig2D,ensemble_grid] = map_particles(...
  outputFolder,ts,first_time,final_time,spillLocation,Particles,vis_maps,...
  saving,ensemble_grid,Map_fig3D,Map_fig2D,dateHour_str,Params)
%---- Plot the base map if it is the first day and the firs time step ----%
if first_time
  set(0,'DefaultFigureVisible',vis_maps.visible);
  % Get the bathymetry
  [lon_bathy,lat_bathy,depth_bathy] = get_bathymetry(vis_maps);
  % Plot 3D base map
  if vis_maps.threeDim
    Map_fig3D = figure('visible', 'off');
    surf(lon_bathy,lat_bathy,depth_bathy);shading flat
    axis(vis_maps.boundaries)
    view(vis_maps.threeDim_angles)
    min_bathy = min(min(min(depth_bathy)));
    min_lim_bathy = max([vis_maps.boundaries(5);min_bathy]);
    caxis([min_lim_bathy, vis_maps.boundaries(6)])
    set(gca,'ZTickLabel',[]);
    box('on')
    set(gca,'BoxStyle','full')
    YTL = get(gca,'YTickLabel');
    for element = 1:numel(YTL)
      YTL{element} = [YTL{element},' °N'];
    end
    set(gca,'YTickLabel',YTL)
    XTL = get(gca,'XTickLabel');
    for element = 1:numel(XTL)
      XTL{element} = [XTL{element}(2:end),' °O'];
    end
    set(gca,'XTickLabel',XTL)
    hold on
    contour3(lon_bathy,lat_bathy,depth_bathy,vis_maps.isobaths,'k','linewidth',2)
    colormap(vis_maps.cmap)
    set(Map_fig3D,'color','w','resize','off')
    set(gca,'FontSize',vis_maps.fontSize)
    set(Map_fig3D,'units','centimeters','Position',vis_maps.figPosition)
    set(gca,'units','centimeters','Position',vis_maps.axesPosition)
  end
  % Plot 2D base maps
  if vis_maps.twoDim
    Map_fig2D = figure('visible', 'off');
    pcolor(lon_bathy,lat_bathy,depth_bathy);shading flat
    axis(vis_maps.boundaries(1:4))
    view([0,90])
    TicksX = [-98 -96 -94 -92 -90 -88 -86 -84 -82 -80];
    TicksY = [16 18 20 22 24 26 28 30];
    TicksYStr = ['16N';'18N';'20N';'22N';'24N';'26N';...
            '28N';'30N'];
    TicksXStr = ['98W';'96W';'94W';'92W';'90W';...
            '88W';'86W';'84W';'82W';'80W';'78W'];
    set(gca,'YTick', TicksY,'YTickLabel',TicksYStr,...
            'XTick',TicksX,'XTickLabel',TicksXStr,...
            'FontSize',12,'FontWeight','bold','Ycolor','k','Xcolor','k','FontName','Arial')
    
    hold on
    contour(lon_bathy,lat_bathy,depth_bathy,vis_maps.isobaths,'k','linewidth',2)
    colormap(vis_maps.cmap);
    min_lim_bathy = min(min(min(depth_bathy)));
    caxis([min_lim_bathy, vis_maps.boundaries(6)])
    
    set(Map_fig2D,'color','w','resize','off')
    set(gca,'FontSize',vis_maps.fontSize)
    set(Map_fig2D,'units','centimeters','Position',vis_maps.figPosition)
    % Used by ensemble maps
    ensemble_grid.lat = vis_maps.boundaries(4):-km2deg(5):vis_maps.boundaries(3);
    ensemble_grid.lon = vis_maps.boundaries(1):km2deg(5):vis_maps.boundaries(2);
    ensemble_grid.count = nan(numel(ensemble_grid.lat),numel(ensemble_grid.lon),...
      spillLocation.n_Heights);
  end
end
%------------------------ Plot particles position ------------------------%
% 3D plot
if vis_maps.threeDim
  set(0,'currentfigure',Map_fig3D);
  h_del = findobj(Map_fig3D,'type','line');
  delete(h_del)
  % Title
  img_name = ['(3D) ',dateHour_str];
  title(img_name)
  for depth_cicle = 1 : spillLocation.n_Depth
    depth_ind = find(Particles.Depth == spillLocation.Heights(depth_cicle));
    plot3(Particles.Lon(depth_ind),Particles.Lat(depth_ind),...
      -Particles.Depth(depth_ind),'.','color',...
      vis_maps.colors_ByDepth(depth_cicle),'MarkerSize',vis_maps.markerSize)
  
  % Plot spill location
  plot3(zeros(1,spillLocation.n_Heights)+spillLocation.Lon,...
    zeros(1,spillLocation.n_Heights)+spillLocation.Lat,-spillLocation.Heights,...
    's','color',vis_maps.colors_SpillLocation,'MarkerSize',vis_maps.markerSize)
  % Visualize
  if strcmp(vis_maps.visible,'on') && ...
      (rem(ts,vis_maps.visible_step_ts) == 0 || first_time)
    pause(0.5)
  end
  % Save image
  if saving.MapsImage_on && (rem(ts,saving.MapsImage_step_ts) == 0)
    img_name = strrep(img_name,' ','_');
    img_name = regexprep(img_name,'[()]','');
    export_fig(Map_fig3D,[outputFolder.MapsImage,img_name],'-png','-nocrop',...
      saving.MapsImage_quality)
  end
 end 
end
% 2D plot
if vis_maps.twoDim
  set(0,'currentfigure',Map_fig2D);
  for depth_cicle = 1:spillLocation.n_Heights
    h_del = findobj(Map_fig2D,'type','line');
    delete(h_del)
    % Title
    currentHeight = spillLocation.Heights(depth_cicle);
    currentHeight_str = num2str(currentHeight);
    img_sufix = ['(',currentHeight_str,' m) '];
    img_name = [img_sufix,dateHour_str];
    title(img_name)
    % plot particles in water
    depthComp_ind = find(Particles.Height == currentHeight)';
    plot(Particles.Lon(depthComp_ind),Particles.Lat(depthComp_ind),'.','color',...
      'black','MarkerSize',vis_maps.markerSize)
    % Counting for ensemble maps
    for parts_cicle = depthComp_ind
      lat_idx = find(ensemble_grid.lat <= Particles.Lat(parts_cicle),1,'first');
      lon_idx = find(ensemble_grid.lon <= Particles.Lon(parts_cicle),1,'last');
        ensemble_grid.count(lat_idx,lon_idx,depth_cicle) = ...
          nansum([ensemble_grid.count(lat_idx,lon_idx,depth_cicle);1]);      
    end
 
        % Plot spill location
    plot(spillLocation.Lon,spillLocation.Lat,'s','color',vis_maps.colors_SpillLocation,...
      'MarkerSize',vis_maps.markerSize)
    % Visualize
    if strcmp(vis_maps.visible,'on') && ...
        (rem(ts,vis_maps.visible_step_ts) == 0 || first_time)
      pause(0.5)
    end
    % Save image
    if saving.MapsImage_on && ...
        (rem(ts,vis_maps.visible_step_ts) == 0 || first_time)
      img_name = strrep(img_name,' ','_');
      img_name = regexprep(img_name,'[()]','');
      export_fig(Map_fig2D,[outputFolder.MapsImage,img_name],...
        '-png','-nocrop',saving.MapsImage_quality)
    end
  end

if final_time && vis_maps.twoDim
  %---------------------------- Ensemble maps ----------------------------%
  % Plot base ensemble map
  ensembleMaps = figure('visible','off');
  [lon_bathy,lat_bathy,depth_bathy] = get_bathymetry(vis_maps);
  contour(lon_bathy,lat_bathy,depth_bathy,vis_maps.isobaths,'k','linewidth',2)
  axis(vis_maps.boundaries(1:4))
  TicksX = [-98 -96 -94 -92 -90 -88 -86 -84 -82 -80];
  TicksY = [16 18 20 22 24 26 28 30];
  TicksYStr = ['16N';'18N';'20N';'22N';'24N';'26N';...
            '28N';'30N'];
  TicksXStr = ['98W';'96W';'94W';'92W';'90W';...
            '88W';'86W';'84W';'82W';'80W';'78W'];
  set(gca,'YTick', TicksY,'YTickLabel',TicksYStr,...
            'XTick',TicksX,'XTickLabel',TicksXStr,...
            'FontSize',12,'FontWeight','bold','Ycolor','k','Xcolor','k','FontName','Arial')
  view([0,90])
  hcb = colorbar;
  ylabel(hcb,'Numero de posiciones')
  set(ensembleMaps,'color','w','resize','off')
  set(gca,'FontSize',vis_maps.fontSize)
  set(ensembleMaps,'units','centimeters','Position',vis_maps.figPosition)
  set(gca,'units','centimeters','Position',vis_maps.axesPosition)
  hold on
  for depth_cicle = 1:spillLocation.n_Heights
    max_val = max(max(max(ensemble_grid.count(:,:,depth_cicle,:),[],4)));
    caxis(log([1,max_val*.1]))
    img_name = [num2str(spillLocation.Heights(depth_cicle)),'m'];
    title(img_name)
    hpc = pcolor(ensemble_grid.lon,ensemble_grid.lat,...
        ensemble_grid.count(:,:,depth_cicle)); shading flat;
      uistack(hpc,'bottom')
      % Save image
      if saving.MapsImage_on
        img_name = strrep(img_name,' ','_');
        img_name = strrep(img_name,',','');
        export_fig(ensembleMaps,[outputFolder.MapsImage,img_name],...
          '-png','-nocrop',saving.MapsImage_quality)
      end
      
       
  end
 
 end
end