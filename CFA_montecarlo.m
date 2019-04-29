function statstrct = CFA_montecarlo(Wrl,indrl,jitterl,Knm,N)

M = length(Wrl);

D = -diff(eye(M))';

R = zeros(M,0);
Q = zeros(M,0);

pvc = zeros(1,Knm);
psidiff = zeros(M,Knm);
Wdiff = psidiff;
psiall = psidiff;
Wall = psidiff;

sigmall = zeros(M-1,Knm);
sigmadiff = sigmall;

for k = 1:Knm
    
    jtmp2 = zeros(N,M-1);
    
    for jind = 1:length(jitterl)
        jtmp2(:,jind) = normrnd(0,jitterl(jind),N,1);
    end
    
    jtmp2 = [mean(jitterl)*normrnd(0,1,N,1) jtmp2 mean(jitterl)*normrnd(0,1,N,1)];
    
    j2 = diff(jtmp2')';
    
    n = zeros(N,M);
    for h2 = 1:M
        n(:,h2) = normrnd(0,indrl(h2),N,1);
    end
    
    g = normrnd(0,1,N,1);
    
    g = g*Wrl(:)';
    
    X = n + j2 + g;
    
    [W,psi,phi,sigma,omega,iter,n_fail,logp,Chat] = CFAfull_spc(X,Q,100,1,D,R);
    
    W = W * sign(sum(W));
    
    pvc(k) = logp;
    psidiff(:,k) = std(n)' - sqrt(psi);
    Wdiff(:,k) = std(g)'  - W;
    
    psiall(:,k) = std(n)';
    Wall(:,k) = std(g)';
    
    sigmall(:,k) = std(jtmp2(:,2:end-1))';
    sigmadiff(:,k) = std(jtmp2(:,2:end-1))' - sqrt(sigma);
    
    k
        
end


statstrct.Wall = Wall;
statstrct.psiall = psiall;
statstrct.sigmall = sigmall;
statstrct.Wdiff = Wdiff;
statstrct.psidiff = psidiff;
statstrct.sigmadiff = sigmadiff;
statstrct.pvc = pvc;

statstrct.Wbias = mean(statstrct.Wdiff');
statstrct.Wsem = std(statstrct.Wdiff');

statstrct.indbias = mean(statstrct.psidiff');
statstrct.indsem = std(statstrct.psidiff');

statstrct.jitterbias = mean(statstrct.sigmadiff');
statstrct.jittersem = std(statstrct.sigmadiff');
