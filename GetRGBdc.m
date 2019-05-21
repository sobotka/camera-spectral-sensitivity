%12/06/2012
%Jun Jiang
%Summary
%   The fucntion is to get the digital counts from the captured image (a
%   CCDC target)
%
%[IN]
%   folder: the folder within which captured data is saved
%   bayerP: the bayer pattern of the raw data
%
%[OUT]
%   radiance: the radiance (raw data) of each patch in the CCDC target
%
function [radiance]=GetRGBdc(folder,bayerP)
%% load the raw data

if(nargin==0)
    disp('folder has to be specified');
    return;
elseif(nargin==1)
    disp('bayer pattern has to be specified. use dcraw -i -v ');
end

load([folder,'rawData.mat']);


%% subtract the dark image
img=double(img);
 
% get the dark image taken with lens cap on
imgDark=imread([folder,'./canon60d_black.pgm']);


img2=img-double(imgDark);
img2(img2<0)=0;

%% No demosaic is used
if(strcmp(bayerP,'RGGB'))
    imgR = img2(1:2:end, 1:2:end);
    imgG = img2(1:2:end, 2:2:end);
    imgB = img2(2:2:end, 2:2:end);
elseif(strcmp(bayerP,'GBRG'))
    imgR = img2(2:2:end, 1:2:end);
    imgG = img2(1:2:end, 1:2:end);
    imgB = img2(1:2:end, 2:2:end);
elseif(strcmp(bayerP,'BGGR'))
    imgR = img2(2:2:end, 2:2:end);
    imgG = img2(1:2:end, 2:2:end);
    imgB = img2(1:2:end, 1:2:end);
elseif(strcmp(bayerP,'GRBG'))
    imgR = img2(1:2:end, 2:2:end);
    imgG = img2(1:2:end, 1:2:end);
    imgB = img2(2:2:end, 1:2:end);
    
end

%% extract the four corners of the CCDC
%Click on the four corners of CCDC in the order of (top left, top right,
%bottom right, and bottom left)
%You only need to do this once. To re-select, delete the file xyCorner.mat
%in the folder first
%
xyCornerFile='xyCorner.mat';
if(isempty(dir([folder,xyCornerFile])))
    imagesc(imgG);
    grid on;
    
    xyCorner=ginput(4);
    save ([folder,xyCornerFile], 'xyCorner');
else
    load([folder,xyCornerFile]);
end


xyCorner=round(xyCorner);
xyCorner=flipdim(xyCorner,2);

rowRange=min(xyCorner(1:2,1)):min(xyCorner(3:4,1));
colRange=min(xyCorner([1,4],2)):max(xyCorner([2,3],2));

imgR=imgR(rowRange,colRange);
imgG=imgG(rowRange,colRange);
imgB=imgB(rowRange,colRange);

figure;
imagesc(imgR);

%% get the coordinates of each patch
figure;imagesc(imgR);grid on;

nRow=12;
nCol=20;

patchSz=[size(imgR,1)/nRow,size(imgR,2)/nCol];


col=patchSz(2)/2:patchSz(2):size(imgG,2);
row=patchSz(1)/2:patchSz(1):size(imgG,1);





col=round(col);
row=round(row);

hold on; plot(col,repmat(row,length(col),1),'ko')



%%
patchSamplingSz=4;
radiance=zeros(3,nRow*nCol);

[radiance(1,:)]=GetPatchRadiance(imgR,row,col,patchSamplingSz);
[radiance(2,:)]=GetPatchRadiance(imgG,row,col,patchSamplingSz);
[radiance(3,:)]=GetPatchRadiance(imgB,row,col,patchSamplingSz);







end