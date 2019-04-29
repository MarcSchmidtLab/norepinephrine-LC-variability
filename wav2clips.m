function [clipsamps,clipons,amps] = wav2clips(s,winlen,winadv,amp_thresh,gap_thresh,normopt,logopt,logthresh,minsamps,maxsamps)

if nargin==1
    winlen = 64;
    winadv = 64;
    amp_thresh = 0.5;
    gap_thresh = 10;
    normopt = 1;
    logopt = 1;
    minsamps = 10;
    maxsamps= 500;
    logthresh = 0.01/winlen;
end

clipsamps = [];
clipons = [];

amps = ampwav(s,winlen,winadv);

if logopt
    amps = log(max(amps,logthresh)) - log(logthresh);
end

if normopt
    amps = amps / max(amps);
%     amps = amps / prctile(amps,95);
end

sndinds = find(amps >= amp_thresh);

if ~isempty(sndinds)
    clipons = [sndinds(1) sndinds(find(diff(sndinds) > 1) + 1)]*winadv;
    clipoffs = [sndinds(find(diff(sndinds) > 1)) sndinds(end)]*winadv;

    clipsamps = clipoffs - clipons + 1;
    valinds = find(clipsamps >= minsamps & clipsamps <= maxsamps);
    
    clipons = clipons(valinds);
    clipoffs = clipoffs(valinds);

    
    if length(clipons) > 0
               
        oninds = 2:length(clipons);
        offinds = 1:length(clipons)-1;
        gaplens = clipons(oninds) - clipoffs(offinds) + 1;
        
        clipinds = find(gaplens >= gap_thresh);
        
        clipons = uint32(max(1,[clipons(1) clipons(oninds(clipinds))] - 32*winadv));
        clipoffs = uint32(min(length(s),[clipoffs(offinds(clipinds)) clipoffs(end)] + 32*winadv));
        
        clipsamps = clipoffs - clipons + 1;
        
        valinds = find(clipsamps <= maxsamps);
        
        clipons = clipons(valinds);
        clipsamps = clipsamps(valinds);
        
    end
    
end