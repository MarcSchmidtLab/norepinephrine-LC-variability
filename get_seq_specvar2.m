function [distmat,spmnarr,spstdarr,featms,seqarr,sampinds] = get_seq_specvar2(sylarr,seqvc,featms,seqstrct,wavdir,propstrct,templatestrct,dirstrct,N)

sylnm = length(sylarr);
oninds = findSeq(seqstrct.vc,seqvc);
seqnm = length(oninds);

tmstmp = seqstrct.cliptms;
lenstmp = seqstrct.cliplens;
wavindstmp = seqstrct.wavinds;

if strcmp(sylarr(1),'*')
    oninds = oninds+1;
    sylnm = sylnm-1;
    sylarr = sylarr(2:end);
end

if strcmp(sylarr(end),'*')
    sylnm = sylnm-1;
    sylarr = sylarr(1:end-1);
end

[b,a] = butter(propstrct.filt_order,2*[propstrct.freqmin propstrct.freqmax]/propstrct.fs);

if length(N)==1
    sampinds = randperm(seqnm);
    sampinds = sampinds(1:min(N,seqnm));
else
    sampinds = N;
end

sampnm = length(sampinds);

notenm = 0;
for sylind = 1:length(sylarr)
    notenm = notenm + length(featms{sylind}) - 1;
end

sylvc = zeros(1,notenm);
notenmvc = zeros(1,sylnm);

distmat = zeros(sampnm,notenm);
spmnarr = {};
spstdarr = {};
seqarr = {};
lastind = 0;

if sampnm > 0
    
    for sylind = 1:sylnm
        
        sylid = sylarr{sylind};
        
        indOn = featms{sylind}(1);
        indOff = featms{sylind}(end);
        
        noteinds = lastind+1:lastind+length(featms{sylind})-1;
        lastind = noteinds(end);
        
        specarrtmp = {};
        
        for sampind = 1:sampnm
            seqind = sampinds(sampind);
            clipind = oninds(seqind)+sylind-1;
            
            samp1 = ceil(seqstrct.cliptms(clipind) * propstrct.fs / 1000);
            samp2 = samp1 + floor(seqstrct.cliplens(clipind) * propstrct.fs / 1000) - 2;
            flnm = [wavdir filesep dirstrct.wavfls{seqstrct.wavinds(clipind)}];
            temp_file = wavread(flnm);
            %s_dim = wavread(flnm,'size');
            [s_dim,temp_var] = size(flnm);
            samp2 = min(samp2,max(s_dim));
            signal = temp_file(samp1:samp2);
            %signal = wavread(flnm,double([samp1,samp2]));
     
            signal = filter(b,a,signal);
            
            spec = tdft(signal,propstrct.f_winlen,propstrct.f_winadv);
            spec = log(max(spec,propstrct.amp_cutoff))-log(propstrct.amp_cutoff);
            specarrtmp{sampind} = spec(templatestrct.freqinds,:);
            
        end
        
        [spmn,spstd,spalgn] = mk_spec_template(specarrtmp,sylarr{sylind});
        
        template = templatestrct.specarr{seqvc(sylind)};
        
        w=dtwDist(template,spmn,[1.5 1.5 1]);
        
        for featind = 1:length(featms{sylind})
            [dmy,indtmp] = min(abs(w(:,1)-featms{sylind}(featind)));
            featms{sylind}(featind) = round(w(indtmp,2));
        end
        
        indOn = featms{sylind}(1);
        indOff =  featms{sylind}(end);
        
        spmn = spmn(:,indOn:indOff);
        spalgn = spalgn(:,:,indOn:indOff);
        
        distmatmp = spalgn - shiftdim(repmat(spmn,[1,1,size(spalgn,1)]),2);
        %     distarr{templateind} = sqrt(sum(sum(distmat.^2,2),3)/numel(spmn));
        %     distarr{templateind} = sum(sum(abs(distmat),2),3)/numel(spmn);
        
        distmp = squeeze((mean(distmatmp.^2,2)));
        
        featms{sylind} = featms{sylind} - featms{sylind}(1) + 1;
        notelentmp = diff(featms{sylind});
        notelentmp(end) = notelentmp(end) + 1;
        
        if length(featms{sylind}) > 2
            distmat(:,noteinds) = chunk(distmp,featms{sylind}) ./ repmat(notelentmp,sampnm,1);
        else
            distmat(:,noteinds) = mean(distmp,2);
        end
        
        spmnarr{sylind} = spmn;
        spstdarr{sylind} = spstd(:,indOn:indOff);
        
        sylvc(noteinds) = sylind;
        notenmvc(sylind) = length(featms{sylind})-1;
        
    end
    
    sylind = 1;
    noteind = 1;
    
    seqarr = {};
    
    for i = 1:notenm
        if notenmvc(sylvc(i)) > 1
            seqarr{i} = [sylarr{sylvc(i)} '-' num2str(noteind)];
        else
            seqarr{i} = sylarr{sylvc(i)};
        end
        
        if noteind==notenmvc(sylvc(i))
            noteind = 1;
        else
            noteind = noteind + 1;
        end
    end
    
end
