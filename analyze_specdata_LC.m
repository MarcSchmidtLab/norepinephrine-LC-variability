clear
clc
close all

%NOTE: the spalgnarr field within the spec structs must be calculated
%separately because of a bug in the clip_analysis sequence. To do this, you
%must run through analysis like normal but stop right after hitting 'Spec
%Var', then save Export the Spectral Data (which should contain the
%spalgnarr field). Continue through analysis normally, which should give
%you the rest of the spec struct. Then (with both structs you just made),
%extract the spalgnarr field, add it to the spec struct, and save the
%struct. Make sure to preserve the correct order of the sequence you're
%interested in (the spalgnarr field that was created through partial
%clip_analysis is in alphabetical order, not the correct order of the song
%sequence). Also, make sure that the new field is an Nx1 cell array.
%You can check a correct specstrct from Chris Glaze's analysis to copy it.
%Here is what I did to extract it:

% spalgnarr_field = getfield(spalgnarr_struct, 'spalgnarr')
% spalgnarr_field = {spalgnarr_field{3}; spalgnarr_field{1}; spalgnarr_field{2}; spalgnarr_field{4}}
% specstrct.spalgnarr = spalgnarr_field


%LCbirdarr = {'RD_2','SI_026','PU_31','BL_16'};
LCbirdarr = {'WH09'};

%NEbirdarr = {'BR_2','OR_13','BR26','OR2','WH57','BRFINAL'};


% NEbirdarr = {'BR26'};


stdsal = [];
mnsal = [];
stdexp = [];
mnexp = [];
birdall = [];
sylall = [];

birdiff = zeros(numel(LCbirdarr),1);
Nexp = birdiff;
Nsal = birdiff;

LCbirdarr_all = {};

for birdind = 1:numel(LCbirdarr)
    load(['./' LCbirdarr{birdind} '/specdata_undir.mat'])
    
    [stdtmp_exp,distmp_exp] = spec_regression(specstrct_U_stim.spalgnarr);
    [stdtmp_sal,distmp_sal] = spec_regression(specstrct_U_nostim.spalgnarr);
    
    stdsal = [stdsal;stdtmp_sal'];
    mnsal = [mnsal;specstrct_U_nostim.mn'];
    
    stdexp = [stdexp;stdtmp_exp'];
    mnexp = [mnexp;specstrct_U_stim.mn'];
    
    sylall = [sylall;specstrct_U_stim.seq'];
    birdall = [birdall;repmat(LCbirdarr(birdind),numel(specstrct_U_stim.std),1)];
    
    Nexp(birdind) = size(specstrct_U_stim.distmat,1);
    Nsal(birdind) = size(specstrct_U_nostim.distmat,1);

end

figure
%h = plotbird(stdsal,stdexp,birdall);
plot(stdsal, stdexp, 'bo')
hold on
plot([.5 .9],[.5 .9],'k--')
set(gca,'ylim',[.5,.8])
set(gca,'xlim',[.5,.8])
xlabel('No Stim')
ylabel('Stim')

title('LC vs. No Stim - Undirected')
paramat = [stdsal stdexp mnsal mnexp];