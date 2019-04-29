clear
clc
close all

LCbirdarr = {'RD_2','SI_026','PU_31','BL_16'};

stdsal = [];
mnsal = [];
seqmnsal = zeros(numel(LCbirdarr),1);
seqstdsal = seqmnsal;

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

sgall = [];

birdiff = zeros(numel(LCbirdarr),1);

for birdind = 1:numel(LCbirdarr)
   load(['./' LCbirdarr{birdind} '/timedata.mat'])
   
   lenseqsal = timestrct_U_nostim.lenseq;
   lenseqexp = timestrct_U_stim.lenseq;
   
   lenseqsal = cleanInts(lenseqsal,5,1);
   lenseqexp = cleanInts(lenseqexp,5,1);
   
   seq = timestrct_U_nostim.seqarr;
   Q = mkQmat(seq);
   
   [Wsaltmp,psisaltmp,phisal,sigmasal,omegasal] = CFAfull_spc_waitbar(lenseqsal,Q,100,1);
 
   [Wexptmp,psiexptmp,phisal,sigmasal,omegasal] = CFAfull_spc_waitbar(lenseqexp,Q,100,1);
   
   Wsaltmp = rotate_maxaccum(Wsaltmp);
   Wexptmp = rotate_maxaccum(Wexptmp);
   
   
   Nsal(birdind) = size(lenseqsal,1);
   Nexp(birdind) = size(lenseqexp,1);
   
   Wsal = [Wsal;Wsaltmp];
   Wexp = [Wexp;Wexptmp];
   
   psisal = [psisal;psisaltmp];
   psiexp = [psiexp;psiexptmp];
      
   birdiff(birdind) = median(psisaltmp-psiexptmp);
   
   
   
   mnsal = [mnsal;mean(lenseqsal)'];
   stdsal = [stdsal;std(lenseqsal)'];
   
   mnexp = [mnexp;mean(lenseqexp)'];
   stdexp = [stdexp;std(lenseqexp)'];
   
   seqmnsal(birdind) = mean(sum(lenseqsal')')';
   seqmnexp(birdind) = mean(sum(lenseqexp')')';
    
   seqstdsal(birdind) = std(sum(lenseqsal')')';
   seqstdexp(birdind) = std(sum(lenseqexp')')';

   
   sgall = [sgall;timestrct_U_nostim.sg(:)];
   
   clear timestrct_U_stim timestrct_U_notstim
   
end

cvsal = seqstdsal./seqmnsal;
cvexp = seqstdexp./seqmnexp;

figure
plot(cvsal,cvexp,'o')
hold on
plot([.01 .1],[.01 .1],'k--')