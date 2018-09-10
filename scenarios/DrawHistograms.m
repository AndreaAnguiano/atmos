function DrawHistograms(histogram, boundaries, Heights, outputFolder, palette, saving_quality,ts)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
ensembleMaps = DrawGulfOfMexico2Datm(boundaries)
TicksX = [-98 -96 -94 -92 -90 -88 -86 -84 -82 -80];
TicksY = [16 18 20 22 24 26 28 30];
TicksYStr = ['16N';'18N';'20N';'22N';'24N';'26N';...
            '28N';'30N'];
 TicksXStr = ['98W';'96W';'94W';'92W';'90W';...
            '88W';'86W';'84W';'82W';'80W';'78W'];
 set(gca,'YTick', TicksY,'YTickLabel',TicksYStr,...
            'XTick',TicksX,'XTickLabel',TicksXStr,...
            'FontSize',12,'FontWeight','bold','Ycolor','k','Xcolor','k','FontName','Arial')

colorbar;
hold on
lat = histogram.ensemble_grid.lat;
lon = histogram.ensemble_grid.lon;
data = histogram.ensemble_grid.count;
cbarTicks =[0:.5:8];
cbarTicksLabels = cellstr(strsplit(num2str(cbarTicks)))

    for height_cicle = 1:length(Heights)
        max_val = max(max(max(data(:,:,height_cicle,:),[],4)));
        caxis(log([1,100*0.1]))
        img_name = [num2str(Heights(height_cicle)),'m'];
        title(img_name);
        %title('Surface oil, 3^{rd} oil component');
        hpc = pcolor(lon,lat,data(:,:,height_cicle)); shading flat;
        uistack(hpc,'bottom');
        cm = colormap(palette);
        colorbar('Ticks',cbarTicks,'TickLabels',cbarTicksLabels);
        export_fig(ensembleMaps,[outputFolder,img_name],'-png','-nocrop',saving_quality)
    end

    figure(gcf)
end
