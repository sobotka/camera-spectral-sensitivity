%12/06/2012
%Jun Jiang
%Summary
%   The function is to calculate the scalars given the CCT
%[IN]
%   CCT: the correlated color temperature
%[OUT]
%   SD: spectrum of the daylight 
%
function [SD]=getDaylightScalars(CCT)

if(CCT>=4000 && CCT<=7000)
    xD=-4.607*10^9/(CCT^3) + 2.9678*10^6/(CCT^2) +0.09911*10^3/CCT +0.244063;
else
    xD=-2.0064*10^9/(CCT^3) + 1.9018*10^6/(CCT^2) +0.24748*10^3/CCT +0.23704;
end

yD=-3*xD^2 +2.87*xD -0.275;

M1=(-1.3515-1.7703*xD+5.9114*yD)/(0.0241+0.2562*xD -.7341*yD);

M2=(0.03-31.4424*xD+30.0717*yD)/(0.0241+0.2562*xD -.7341*yD);

load('daylightScalars.txt');

S0=daylightScalars(:,2);
S1=daylightScalars(:,3);
S2=daylightScalars(:,4);

SD=S0+M1*S1+M2*S2;

end
