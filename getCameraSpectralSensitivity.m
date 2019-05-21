%07/25/2012
%Chris
%Summary
%   The function is to get all the camera spectral sensitivity from the
%   database of 28 cameras
%[OUT]
%   rgbCMF: the 1x3 cell containing the camera spectral sensitivity for
%   each channel
%   camName: camera names
%
function [rgbCMF,camName]=getCameraSpectralSensitivity()

folder='./camSpecSensitivity/';
files=dir(folder);
idx=1;
for i=1:length(files)
    if(length(files(i).name)>5 && strcmp(files(i).name(1:3),'cmf'))
        load([folder,files(i).name]);
        
        redCMF(:,idx)=r';
        greenCMF(:,idx)=g';
        blueCMF(:,idx)=b';
        
     
            
        camName{idx}=files(i).name(5:end-4);
        
        
        idx=idx+1;

    end
    
end


rgbCMF{1}=redCMF;
rgbCMF{2}=greenCMF;
rgbCMF{3}=blueCMF;
end
