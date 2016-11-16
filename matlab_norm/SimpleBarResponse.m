%%
% parameters needed: filter bank dimension, scales, orientations; the
% threshold for a positive response
%%
% create a bank of filters
fscales = [2,3,4,5,6,7,8];
nS = length(fscales);
forients = 36;
% simple bar shapes for now
fbank = makeBarBank(15, forients,fscales);

[nr nc nF] = size(fbank);
%%
InputFileNames = {'H4.tiff'; 'H20.tiff'; 'I65.tiff'; 'I200.tiff'};
%InputFileNames = {'I65.tiff'; 'I200.tiff'}; nfiles = 2;
nfiles = length(InputFileNames);
posResponseSums= zeros(nS,nfiles);
%%
% set a threshold (basically 40%)
responseThresh = 40;
%%
for files = 1:nfiles
%for files = 1:1
    inI = imread(InputFileNames{files});
    dI = double(inI);
    [imR imC] = size(inI);

    responses = zeros(imR -nr + 1, imC - nc + 1, nF);
    for i = 1:nF
        responses(:,:,i)=conv2(dI,fbank(:,:,i),'valid');
    end
    % print response range
    min(responses(:))
    max(responses(:))
    
    % reduced space by using max response for each scale
    %  TO DO: we should record which orientation was the max
    cResponse = zeros(imR -nr + 1, imC - nc + 1,nS);
    j=1;
    for i = 1:nS
        [cResponse(:,:,i), indxI] = max(responses(:,:,j:j+forients-1),[],3);
        % record orientation from indxI value if indxI only one element
        % orient(:,:,i) = indxI(1);
        j = j+forients;
    end
    % cResponse is the rotation invariant response to the filter at each
    % scale - now find only the response that are "big enough" 
    
    posCR = cResponse>responseThresh;
    pSc = zeros(nS,1);
    % doesn't work if the input files are a different size
    %FBresponse(:,:,:,files) = cResponse;
    
    % HACK:
    % just summing means the number found will depend on the ROI size and
    % the image size - should really rescale this ...but for same size
    % images, a raw comparison is ok for now
    for i=1:nS
        tmpI = posCR(:,:,i);
        pSc(i) = sum(tmpI(:));
    end
    posResponseSums(:,files) = pSc;
    
    for i=1:nS
        %indices  = find(posCR(:,:,i));
        [yy,xx] = ind2sub(size(posCR(:,:,i)), find(posCR(:,:,i)));
        xx = ceil(nc/2) + xx;
        yy = ceil(nr/2) + yy;
        figure, imshow(inI);
        hold on; plot(xx,yy,'r.');
        ptitle  = sprintf('image: %s scale = %d',InputFileNames{files},fscales(i));
        title (ptitle);
    end
end
    
%%
% figure, imshow(imread('H4.tiff')); title('H4');
% figure, imshow(imread('H20.tiff')); title('H20');
% figure, imshow(imread('I200.tiff')); title('I200');
% figure, imshow(imread('I65.tiff')); title('I65');
%%
figure, plot(fscales, posResponseSums(1:nS,1),'r+:', 'MarkerSize',10);
hold on;
plot(fscales, posResponseSums(1:nS,2),'g+:', 'MarkerSize',10);
plot(fscales, posResponseSums(1:nS,3),'b+:', 'MarkerSize',10);
plot(fscales, posResponseSums(1:nS,4),'m+:', 'MarkerSize',10);
legend('H4 ', 'H20', 'I65 ', 'I200');
title('Bar-Shaped Filter Response - threshold 40');
xlabel('Scale')
ylabel('Filter Response')
