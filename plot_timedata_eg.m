clear
clc
close all

birdarr = {'RD_2','SI_026','PU_31','BL_16'};

cond = 0;

% birdarr = {'OR_46','BR26','WH27','WH57'};
% cond = 3;
%
% birdarr =  {'BR_2','OR_13','BR26','OR2','WH57','Y437','WH27','BRFINAL'};
%
% cond = 1;

birdarr = {'BR_2','OR_13','BR26','OR2','WH27','OR_46','WH57'};
cond = 2;
% %
% birdarr = {'Y437'};

% BR26: have data and anl HONED~, 2
% BR2: have data and anl HONED*, 5
% OR46: have data and anl HONED*, 6
% WH57: have data and anl HONED*, 5
% OR2: have data and anl, HONED~, 4
% OR13: have data and anl, HONED, M 6
% birdarr = {'WH57'};

birdiff2 = zeros(numel(birdarr),1);

stdsal = [];
mnsal = [];
seqmnsal = zeros(numel(birdarr),1);
seqstdsal = seqmnsal;
seqmnsal2 = seqmnsal;
seqmnexp2 = seqmnsal;

stdexp = [];
mnexp = [];
seqmnexp = seqmnsal;
seqstdexp = seqmnsal;

Wsal = [];
Wexp = [];
psisal = [];
psiexp = [];

Nsal = seqmnsal;
Nexp = seqmnsal;

mnsal2 = [];
mnexp2 = [];

sgall = [];

birdiff = zeros(numel(birdarr),1);

birdall = [];
birdall2 = [];

sylall = [];
sylall2 = [];

lenp = birdiff2;

birdind = 1;

load(['./' birdarr{birdind} '/timedata.mat'])

switch cond
    case 1
        lenseqexp = timestrct_U_NE.lenseq;
        lenseqsal = timestrct_U_sal.lenseq;
        seq = timestrct_U_sal.seqarr;
        sgall = [sgall;timestrct_U_sal.sg(:)];
        
    case 0
        lenseqexp = timestrct_U_stim.lenseq;
        lenseqsal = timestrct_U_nostim.lenseq;
        seq = timestrct_U_nostim.seqarr;
        sgall = [sgall;timestrct_U_nostim.sg(:)];
        
    case 2
        lenseqexp = timestrct_F_sal.lenseq;
        lenseqsal = timestrct_U_sal.lenseq;
        seq = timestrct_U_sal.seqarr;
        sgall = [sgall;timestrct_U_sal.sg(:)];
        
    case 3
        lenseqsal = timestrct_F_sal.lenseq;
        lenseqexp = timestrct_F_PHE.lenseq;
        seq = timestrct_F_sal.seqarr;
        sgall = [sgall;timestrct_F_sal.sg(:)];
        
end

lenseqsal = cleanInts(lenseqsal,5,1);
lenseqexp = cleanInts(lenseqexp,5,1);


birdiff2(birdind) = median(sum(lenseqsal')')-median(sum(lenseqexp')');
lenp(birdind) = ranksum(sum(lenseqsal')',sum(lenseqexp')');

Q = zeros(numel(seq),0);

[Wsaltmp,psisaltmp,phisaltmp,sigmasaltmp,omegasal] = CFAfull_prior_spc(lenseqsal,Q,500,1);

Wmat = W
