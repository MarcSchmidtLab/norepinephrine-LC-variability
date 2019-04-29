function optimize_scheme_Callback(hObject, eventdata, handles)
% hObject    handle to make_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

template_propstrct = get(handles.template_axis,'UserData');
templatestrct = get(handles.make_template,'UserData');
clipstrct = get(handles.load_clips,'UserData');
clip_propstrct = get(handles.clip_axis,'UserData');

classnm = length(templatestrct.specarr);

clipnm = length(clipstrct.specarr);

% distp = questdlg('Spectral or feature-based distance?','Distance option','Spectral','Feature','Spectral');

winlen = clip_propstrct.f_winlen;
winadv = winlen;

f = clip_propstrct.fs*[0:winlen/2]/winlen;
f = f(clipstrct.freqinds);

freqinds = templatestrct.freqinds;
amp_cutoff = clip_propstrct.amp_cutoff;

if ~isfield(clipstrct,'distmat')    
    for clipind = 1:clipnm
        clipstrct.specarr2{clipind} = tdft(clipstrct.wavarr{clipind},winlen,winadv);
        clipstrct.specarr2{clipind} = log(max(clipstrct.specarr2{clipind}(freqinds,:),amp_cutoff)) - log(amp_cutoff);
    end   
    clipstrct.distmat = calcdistmat(clipstrct.specarr2);
end

kvc = 1:2:15;
knm = length(kvc);

h = waitbar(0/knm,'Optimizing k');

[dmy,srtinds_all] = sort(clipstrct.distmat,2,'ascend');

votemat = zeros(clipnm,knm);
votemat2 = zeros(knm,clipnm,classnm+1);
class = {};

votethresh = zeros(knm,classnm);
errmat = votethresh;
falseposmat = votethresh;
falsenegmat = votethresh;


for kind = 1:knm
    
    srtinds = srtinds_all(:,2:kvc(kind)+1);
    
    for clipind = 1:clipnm
        srtindstmp = srtinds(clipind,:);
        t = tabulate(clipstrct.speclabs(srtindstmp));
        
        winind = find(cell2mat(t(:,2))==max(cell2mat(t(:,2))));
        if length(winind)>1
           distmp = clipstrct.distmat(clipind,srtindstmp);
           winindind = 1;
           winscr = mean(distmp(find(strcmp(t{winind(winindind),1},clipstrct.speclabs(srtindstmp)))));
           
           for indtmp = 2:length(winind)
               scrtmp = mean(distmp(find(strcmp(t{winind(winindind),1},clipstrct.speclabs(srtindstmp)))));
               if scrtmp < winscr
                   winindind = indtmp;
                   winscr = scrtmp;
               end
           end
           
           winind = winind(winindind);
        end
        
        votemat(clipind,kind) = t{winind,2};
        class{kind}{clipind} = t{winind,1};
        
        for classind = 1:classnm
            
           tind = find(strcmp(templatestrct.speclabs{classind},t(:,1)));
           if ~isempty(tind)
              votemat2(kind,clipind,classind) = t{tind,2}; 
           end
            
        end
        
        tind = find(strcmp('x',t(:,1)));
        if ~isempty(tind)
            votemat2(kind,clipind,classind+1) = t{tind,2};
        end
        
    end
       
    votevc = 1:kvc(kind);
    
    for classind = 1:classnm
        
        classlab = templatestrct.speclabs{classind};
        classinds = find(strcmp(clipstrct.speclabs,classlab));
        noninds = setdiff(1:clipnm,classinds);
        
        falseposvc = zeros(1,length(votevc));
        falsenegvc = falseposvc;
        errvc = falseposvc;
        
        for voteind = 1:length(votevc)
            
            posinds = find(strcmp(class{kind},classlab) & votemat(:,kind)' >= votevc(voteind));
            neginds = setdiff(1:clipnm,posinds);
            
            falseposinds = setdiff(posinds,classinds);
            falseneginds = setdiff(neginds,noninds);
            
            falsepos = length(falseposinds);
            falseneg = length(falseneginds);
            pos = length(posinds);
            neg = length(neginds);
            
            falseposvc(voteind) = falsepos / pos;
            falsenegvc(voteind) = falseneg / neg;
            errvc(voteind) = (falsepos + falseneg) / clipnm;
            
        end
        
        optind = floor(median(find(errvc==min(errvc))));
        votethresh(kind,classind) = votevc(optind);
        errmat(kind,classind) = errvc(optind);
        falseposmat(kind,classind) = falseposvc(optind);
        falsenegmat(kind,classind) = falsenegvc(optind);
        
    end
    
    h = waitbar(kind/knm,h);
    
end

close(h)

errmn = median(errmat');
optind = find(errmn==min(errmn),1,'last');
clipstrct.kopt = kvc(optind);
clipstrct.threshvc = votethresh(optind,:);
clipstrct.errvc = errmat(optind,:);
clipstrct.falseposvc = falseposmat(optind,:);
clipstrct.falsenegvc = falsenegmat(optind,:);
clipstrct.votevc = votemat(:,optind);
clipstrct.class = class{optind};
clipstrct.votemat = squeeze(votemat2(optind,:,:));
clipstrct.errmat = errmat;

set(handles.load_clips,'UserData',clipstrct);

saveopt = questdlg('Save sample optimization?','Save optimization','Yes','No','Yes');

if saveopt
    save_set_Callback(0, 0, handles);
end