function [seqmat,N] = vc2seqsOLD(vc,N_min,M_min,maxrepeat,silind,vc0)

vclen = length(vc);
labnm = length(unique(vc));

seqarr = {};
contflg = 1;
seqind = 1;

seqmat = zeros(500,20);
N = zeros(500,1);

k = 1;

M = M_min;

if nargin == 6
    indsval_all = false(vclen-M_min+2,1);
    inds = findSeq(vc,vc0);
    indsval_all(inds) = 1;
    
    if isempty(inds)
        contflg = 0;
    end
    
else
    indsval_all = true(vclen-M_min+2,1);
end

while contflg
    
    kvc = (labnm+1).^[0:M-1];
    
    if M > M_min
        seq = seq(1:end-1) + vc(M:end)*kvc(end);
    else
        seq = zeros(vclen-M_min+1,1);
        for i = 1:M_min
            seq = seq + vc(i:end-M_min+i)*kvc(i);
        end
        
    end
    
    seqtab = tabulate(-seq(indsval_all(1:end-1)));
    indsval = find(seqtab(:,2) >= N_min);
    indsval_all = indsval_all(1:end-1) & ismember(-seq,seqtab(indsval,1));
 
    if ~isempty(indsval)
        
        seqstmp = -seqtab(indsval,1);
        seqmatmp = zeros(length(indsval),M);
        
        seqmatmp(:,M) = floor(seqstmp / kvc(M));
        for i = M-1:-1:1
            seqmatmp(:,i) = floor(seqstmp / kvc(i) - seqmatmp(:,i+1:M)*kvc(2:M-i+1)');
        end
        
        indsvalval = zeros(1,length(indsval));
        m = 1;
        for i = 1:length(indsval)
            tabtmp = tabulate(seqmatmp(i,:));
            nm_repeats = length(find(tabtmp(:,2)>=2));
            if ~any(seqmatmp(i,2:end-1)==silind) &&  nm_repeats <= maxrepeat && max(tabtmp(:,2)) <= maxrepeat+1
                indsvalval(m) = i;
                m = m + 1;
            end
        end
        indsval = indsval(indsvalval(1:m-1));
        
        if ~isempty(indsval)
            indstmp = k:k+length(indsval)-1;
            
            seqmat(indstmp,1:M) = seqmatmp(indsvalval(1:m-1),:);
            N(indstmp) = seqtab(indsval,2);
            
            M = M + 1;
            k = k + length(indsval);
            
        else
            contflg = 0;
        end
        
    else
        contflg = 0;
        
    end
    
end

seqmat = seqmat(1:k-1,1:M-1);
N = N(1:k-1);
