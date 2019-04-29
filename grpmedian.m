function [y,n,gu] = grpmedian(x,g)

gu = unique(g);
y = zeros(length(gu),size(x,2));
n = zeros(length(gu),1);
for i = 1:length(gu)
    y(i,:) = median(x(g==gu(i),:));
    n(i) = sum(g==gu(i));
end