%06/06/2012
%
%Summary
%   The function is to do PCA on camera sensitivity
%[IN]
%   numEV: number of eigenvectors to retain
%
%[OUT]
%   eRed, eGreen, eBlue: the eigenvectors of each of the three channel
%
function [eRed,eGreen,eBlue]=PCACameraSensitivity(numEV)
%% 07/30/2012

[rgbCMF]=getCameraSpectralSensitivity();


redCMF=rgbCMF{1};
greenCMF=rgbCMF{2};
blueCMF=rgbCMF{3};


%normalize to each curve
for i=1:size(greenCMF,2)
    redCMF(:,i)=redCMF(:,i)./max(redCMF(:,i));
    greenCMF(:,i)=greenCMF(:,i)./max(greenCMF(:,i));
    blueCMF(:,i)=blueCMF(:,i)./max(blueCMF(:,i));
    
end



%% do PCA on cmf

if(nargin>0)
    retainEV=numEV;
else
    retainEV=1;
end


[eRed]=GetEigenvector(redCMF,retainEV);
[eGreen]=GetEigenvector(greenCMF,retainEV);
[eBlue]=GetEigenvector(blueCMF,retainEV);


end
