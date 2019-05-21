%06/12/2012
%Chris
%Summary
%   The function is to recover the camera spectral sensitivity given the
%   spectral reflectance of the samples, the eigenvectors of the camera
%   sensitivity, and the illuminant spectrum
%
%[IN]
%   ill: the light source spectrum
%   reflSet: the spectral reflectance of samples
%   w: wavelength range
%   XYZSet: the radiance captured by the camera
%   e: eigenvector of the camera spectral sensitivity
%
%[OUT]
%   X: the recovered camera spectral sensitivity
%   A, b: Ax=b
%
function [X,A,b]=RecoverCMFev(ill,reflSet,w,XYZSet,e)


numRefl=size(reflSet,2);

A=zeros(numRefl,size(e,2));
b=zeros(size(A,1),1);

deltaLambda=10;


weight=1;
for i=1:numRefl
    %weight=XYZSet(i);
    A(i,:)=reflSet(:,i)'*diag(ill)*e.*deltaLambda.*weight;
    b(i)=XYZSet(i)*weight;
    
    
end




X=A\b;
%X = lsqnonneg(A,b);


X=e*X;


end
