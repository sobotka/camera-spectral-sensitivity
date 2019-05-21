%06/12/2012
%
%Summary
%   The function is to estimate the camera spectral sensitivity under
%   the daylight whose spectrum is unknown
%   if debug is set to 1, the measured daylight and camera spectral
%   sensitivity of Canon 60D is used as an example. To use your own data,
%   turn debug to 0
%
%[OUT]
%   cmf: the ground truth (the measured camera spectral sensitivity)
%   cmfHat: the estimated camera spectral sensitivity
%
function [cmfHat]=RecoverCSS_singlePic()
%% Load captured CCDC


% load info of captured images
folder='./raw/';
filename='img_0153';

% Convert from CR2 to pgm
system(['./dcraw -4 -D -j -v -t 0 ', [folder,filename,'.CR2']]);

% save as mat file
img = imread([folder,filename,'.pgm']);
save ([folder,'rawData.mat'], 'img');

bayerP='RGGB';



%% Load the CCDC relectance (the duplicate and glossy patches are removed)
wWanted=400:10:720;

w2=400:10:720;
reflectance=load('CCDC_meas.mat');
reflectance=reflectance.CCDC_meas;
reflectance=reflectance.spectra;

glossyP=[79,99,119,139,159,179,199,219];
darkP=[21,40,81,100,141,160,201,220];
darkP=[darkP,150,151,152];
unwantedP=[glossyP,darkP];

refl=reflectance(3:end-1,:);

w=w2;


%remove the duplicate and glossy patches in CCDC
range=21:220;

refl2=zeros(length(w),length(range)-length(unwantedP));

idx=1;
for i=range(1):range(end)
    if(isempty(find(unwantedP==i)))
        refl2(:,idx)=refl(:,i);
        idx=idx+1;
    end
    
end


clear refl;
refl=refl2;
clear refl2;


%% Load captured radiance by the camera
% the raw data image are captured and saved as mat file

[radiance1]=GetRGBdc(folder,bayerP);
radiance1=radiance1./(2^16);

% remove the radiance of those glossy or duplicate patches in CCDC
range=21:220;
radiance1Copy=zeros(3,length(range)-length(unwantedP));

idx=1;
for i=range(1):range(end)
    if(isempty(find(unwantedP==i)))
        radiance1Copy(:,idx)=radiance1(:,i);
        idx=idx+1;
    end
end

radiance1=radiance1Copy;
radiance=radiance1;

clear radiance1Copy;

radiance=radiance';


%% Load measured daylight for evaluation purpose only

load([folder,'daylight.mat']);
w=380:5:780;
ill_groundTruth=interp1(w,ill,wWanted);

ill_groundTruth=ill_groundTruth.*100./ill_groundTruth(find(wWanted==560));
clear spd;

w=wWanted;

%% Load the measured cmf (ground truth) of the camera
camName='Canon60D';

[rgbCMF,camNameAll]=getCameraSpectralSensitivity();
for i=1:length(camNameAll)
    if(strcmp(camNameAll{i},camName))
        cmf=[rgbCMF{1}(:,i),rgbCMF{2}(:,i),rgbCMF{3}(:,i)];
    end
    
end



cmf=cmf./max(cmf(:));

figure;
plot(w,cmf(:,1),'r');
hold on;
plot(w,cmf(:,2),'g');
hold on;
plot(w,cmf(:,3),'b');
title('Measured camera response function');
legend('R','G','B');


%% Get the eigenvectors of the camera spectral sensitivity
numEV=2;
[eRed,eGreen,eBlue]=PCACameraSensitivity(numEV);

%% Recover camera spectral sensitivity from a single image under unknown daylight
CCTrange=4000:100:27000;
diff_b=zeros(1,length(CCTrange));
for i=1:length(CCTrange)
    [ill]=getDaylightScalars(CCTrange(i));
    
    deltaLamda=10;
    [cmfHat(:,1)]=RecoverCMFev(ill,refl,w,radiance(:,1),eRed);
    [cmfHat(:,2)]=RecoverCMFev(ill,refl,w,radiance(:,2),eGreen);
    [cmfHat(:,3)]=RecoverCMFev(ill,refl,w,radiance(:,3),eBlue);
    
    I_hat=refl'*diag(ill)*cmfHat*deltaLamda;
    diff_b(i)=norm(radiance-I_hat);
    
    
end


figure;
plot(CCTrange,diff_b,'-o');
xlim([CCTrange(1),CCTrange(end)]);
xlabel('CCT');
ylabel('norm of radiance difference');


[minDiff,minDiffIdx]=min(diff_b);
[ill]=getDaylightScalars(CCTrange(minDiffIdx));

ill=ill./ill(find(w==560));


w=wWanted;
figure;

ill_groundTruth=ill_groundTruth./ill_groundTruth(find(w==560));
plot(w,ill_groundTruth);
hold on;

plot(w,ill,'r-.');
legend('measured daylight','our result');


[cmfHat(:,1)]=RecoverCMFev(ill,refl,w,radiance(:,1),eRed);
[cmfHat(:,2)]=RecoverCMFev(ill,refl,w,radiance(:,2),eGreen);
[cmfHat(:,3)]=RecoverCMFev(ill,refl,w,radiance(:,3),eBlue);

cmfHat=cmfHat./max(cmfHat(:));
cmfHat(cmfHat<0)=0;

w=400:10:720;
figure;

plot(w,cmf(:,1),'r');
hold on;
plot(w,cmf(:,2),'g');
hold on;
plot(w,cmf(:,3),'b');
hold on;

plot(w,cmfHat(:,1),'r-.');
hold on;
plot(w,cmfHat(:,2),'g-.');
hold on;
plot(w,cmfHat(:,3),'b-.');
hold on;

legend('r_m','g_m','b_m','r_e','g_e','b_e');




save (['cmf',camName,'.mat'], 'cmf', 'cmfHat');


end
