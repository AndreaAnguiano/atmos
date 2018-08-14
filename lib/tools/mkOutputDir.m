function outputFolder = mkOutputDir(ModelConfig,saving)
if saving.Data_on  || saving.MapsImage_on 
  outputFolder.Main = ModelConfig.OutputDir;
  mkdir(outputFolder.Main)
  if saving.Data_on
    outputFolder.Data = [outputFolder.Main,'Data/'];
    mkdir(outputFolder.Data)
  end
  if saving.MapsImage_on
    outputFolder.MapsImage = [outputFolder.Main,'MapsImage/'];
    mkdir(outputFolder.MapsImage)
  end
else
  outputFolder = [];
end
end