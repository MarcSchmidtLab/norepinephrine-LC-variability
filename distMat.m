function d = distMat(x,y,xvarmat,yvarmat)
% function d = distMat(x,y,xvarmat)
% computes pairwise Euclidean distance between columns of x and y.
% xvarmat is an optional argument that is generated in the code if not
% given (cuts down on processing if this function is in a loop).

prodmat = x'*y;

if nargin < 4
    [rows,N] = size(x);
    ysm = y.^2;
    
    if rows > 1
        ysm = sum(ysm);
    end
    
    yvarmat = ones(N,1)*ysm;
end

if nargin < 3
    [rows,M] = size(y);
    xsm = x.^2;

    if rows > 1
        xsm = sum(xsm);
    end

    xvarmat = xsm'*ones(1,M);
end

d = xvarmat + yvarmat - 2*prodmat;

% account for precision error
d(d<0)=0;