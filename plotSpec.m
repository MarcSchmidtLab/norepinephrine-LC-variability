function [h,timesReal,freqsReal] = plotSpec(spec,timeBin,freqBin)

%figure

if nargin<2
   timeBin = 1; %4000/24414.1;
end
if nargin<3
   freqBin = 1; %24414.1/128000;
end

timesReal = ([1:size(spec,2)] - 1)*timeBin;
freqsReal = ([1:size(spec,1)] - 1)*freqBin;

h = figure;
imagesc(timesReal,freqsReal,spec);

set(gca,'ydir','normal');
%xlabel('msec')
%ylabel('kHz')