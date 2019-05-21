%12/06/2012
%Jun Jiang
%Summary
%   The function is to get the readiance of each patch based on the input paramter
%[IN]
%   img: the captured img
%   row: the number of rows
%   col: the number of cols of the patches
%   sampleSz: the window size within whcih pixel values are averaged
%[OUT]
%   radiance: the radiance of each patch
%
function [radiance]=GetPatchRadiance(img,row,col,sampleSz)

if(mod(sampleSz,2))
    sampleSz=sampleSz+1;
end


%save in row major order
radiance=zeros(1,length(row)*length(col));

for i=1:length(row)
    for j=1:length(col)
        pixels=img(row(i)-sampleSz/2:row(i)+sampleSz/2,col(j)-sampleSz/2:col(j)+sampleSz/2);
        radiance((i-1)*length(col)+j)=mean(pixels(:));
    end
end



end
