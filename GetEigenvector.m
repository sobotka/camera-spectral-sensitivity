function [e,v]=GetEigenvector(refl,retainE)
A=refl*refl';

if(nargin==1)
    retainE=6;
end

[e,v] = eig(A);

v=diag(v);
v=v(end-retainE+1:end);
e=e(:,end-retainE+1:end);

v=flipdim(v,1);
e=flipdim(e,2);
