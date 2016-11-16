FullPathFolder = '/Users/shilpika/Documents/code/Combustion-Filters/images/';
FileNameBase = 'Honda-LD1.1-3hole-NSAC-15MPa-10mm-T1_C001H001S000100000';
OutputFolder = '/Users/shilpika/Documents/code/Combustion-Filters/op/'

%%
i=1;
InputFileName = sprintf('%s%s%d.tif',FullPathFolder,FileNameBase,i);
disp(InputFileName);
%%
inI = imread(InputFileName);

sumI = double(inI);
disp(size(sumI))

figure, imagesc(sumI); colormap gray;
%%
% do 10-20 images?
for i=2:9
    InputFileName = sprintf('%s%s%d.tif',FullPathFolder,FileNameBase,i);
    inI = imread(InputFileName);
    sumI = sumI + double(inI);
end
background = sumI / 10;

disp(size(background))

figure, imagesc(background); colormap gray;

    

%%
% save background - currently converting to 8 bit gray scale - seems ok?
check tiff pro

minFileNum = 1000;
maxFileNum = 1001;
for i=minFileNum:maxFileNum
    InputFileName = sprintf('%s%s%06d.tif',FullPathFolder,FileNameBase,i)
    inI = imread(InputFileName); 
    tmpI = double(inI) ./ background; % transmission is ratio at each pixel
    tmax = max(tmpI(:))
    tmin = min(tmpI(:))
    drescaleI = 255.0*(tmpI - tmin)/(tmax-tmin);
    rescaleI = uint8(drescaleI);
    OutputFileName = sprintf('%sRatio%06d.tif',OutputFolder,i)
    imwrite(rescaleI,OutputFileName,'tif');
end