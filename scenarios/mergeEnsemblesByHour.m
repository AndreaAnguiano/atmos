function mergeEnsemblesByHour(dataPath, hour, position, month,year, boundaries, outputFolder, palette, saving_quality, cont, Heights)
ensembleMaps = DrawGulfOfMexico2Datm(boundaries)
TicksX = [-98 -96 -94 -92 -90 -88 -86 -84 -82 -80];
TicksY = [16 18 20 22 24 26 28 30];
TicksYStr = ['16N';'18N';'20N';'22N';'24N';'26N';'28N';'30N'];
TicksXStr = ['98W';'96W';'94W';'92W';'90W';'88W';'86W';'84W';'82W';'80W';'78W'];
set(gca,'YTick', TicksY,'YTickLabel',TicksYStr,'XTick',TicksX,'XTickLabel',TicksXStr,'FontSize',12,'FontWeight','bold','Ycolor','k','Xcolor','k','FontName','Arial')     
set(gca,'units','centimeters','Position',[1,2,14,8])
cbarTicks =[0:.5:10];
cbarTicksLabels = cellstr(strsplit(num2str(cbarTicks)))
colorbar;
hold on
firstFile = strcat(num2str(year),'-',num2str(month,'%02.f'),'-',num2str(1,'%02.f'),'_h_',num2str(hour,'%02.f'),'_P',num2str(position),'_',num2str(cont),'.mat');
data= load(strcat(dataPath,firstFile));
rmNan = find(isnan(data.ensemble_grid.count));
data.ensemble_grid.count(rmNan)= 0;
data_final = data.ensemble_grid.count;
lat = data.ensemble_grid.lat;
lon = data.ensemble_grid.lon;
for iter = 2:29
    FileName = strcat(num2str(year),'-',num2str(month,'%02.f'),'-',num2str(iter,'%02.f'),'_h_',num2str(hour,'%02.f'),'_P',num2str(position),'_',num2str(iter-1),'.mat')
    allData = load(strcat(dataPath,FileName));
    rmNan = find(isnan(allData.ensemble_grid.count));
    allData.ensemble_grid.count(rmNan)= 0;
    data_final = data_final + allData.ensemble_grid.count; 
end

%
 for height_cicle = 1:length(Heights)
        max_val = max(max(max(data_final(:,:,height_cicle,:),[],4)))
        caxis(log([1,3000*0.1]))
        img_name = [num2str(Heights(height_cicle)),'m'];
        title(img_name);
        %title('Surface oil, 3^{rd} oil component');
        hpc = pcolor(lon,lat,data_final(:,:,height_cicle)); shading flat;
        uistack(hpc,'bottom');
        cm = colormap(palette);
        colorbar('Ticks',cbarTicks,'TickLabels',cbarTicksLabels);
        export_fig(ensembleMaps,[outputFolder,img_name],'-png','-nocrop',saving_quality)
    end

    figure(gcf)
 %}    
end