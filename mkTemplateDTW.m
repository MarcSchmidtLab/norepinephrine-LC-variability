function template = mkTemplateDTW(exemplars)

%ALIGNS EXEMPLARS AND AVERAGES. RETURNS BOTH AVERAGE AND MATRIX OF EXEMPLAR
%LAG TIMES


smpnm = length(exemplars);

freqnum = size(exemplars{1},1);

lenvc = zeros(1,smpnm);
for i = 1:smpnm
    lenvc(i) = size(exemplars{i},2);
end

[dmy,srtind] = sort(abs(lenvc-mean(lenvc)),'ascend');

exemplars = exemplars(srtind);

template = exemplars{1};
templen = size(template,2);

for smpind= 2:smpnm
    tempSamp = exemplars{smpind};
    [w,D,d]=dtwDist2(template/(smpind-1),tempSamp,[1.4 1.4 1]);
    w = round(flipud(w));
   
    template(:,w(:,1)) = template(:,w(:,1)) + tempSamp(:,w(:,2));
    
end

template = template / smpind;