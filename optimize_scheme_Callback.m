function optimize_scheme_Callback(hObject, eventdata, handles)
% hObject    handle to make_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

template_propstrct = get(handles.template_axis,'UserData');
templatestrct = get(handles.make_template,'UserData');
clipstrct = get(handles.load_clips,'UserData');
clip_propstrct = get(handles.clip_axis,'UserData');


k = 5;

classnm = length(templatestrct.specarr);
clipnm = length(clipstrct.specarr);

protonm = tabulate(clipstrct.speclabs);


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

[dmy,srtinds_all] = sort(clipstrct.distmat,2,'ascend');

votemat = zeros(clipnm,1);
votemat2 = zeros(1,clipnm,classnm+1);
class = {};

votethresh = zeros(1,classnm);
errmat = votethresh;
falseposmat = votethresh;
falsenegmat = votethresh;


srtinds = srtinds_all(:,2:k+1);

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
    
    votemat(clipind,1) = t{winind,2};
    class{clipind} = t{winind,1};
    
    for classind = 1:classnm
        
        tind = find(strcmp(templatestrct.speclabs{classind},t(:,1)));
        if ~isempty(tind)
            votemat2(1,clipind,classind) = t{tind,2};
        end
        
    end
    
    tind = find(strcmp('x',t(:,1)));
    if ~isempty(tind)
        votemat2(1,clipind,classind+1) = t{tind,2};
    end
    
end

votevc = 6;

for classind = 1:classnm
    
    classlab = templatestrct.speclabs{classind};
    classinds = find(strcmp(clipstrct.speclabs,classlab));
    noninds = setdiff(1:clipnm,classinds);
    
    falseposvc = zeros(1,length(votevc));
    falsenegvc = falseposvc;
    errvc = falseposvc;
    
    for voteind = 1:length(votevc)
        
        posinds = find(strcmp(class,classlab) & votemat(:,1)' >= votevc(voteind));
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
    votethresh(1,classind) = votevc(optind);
    errmat(1,classind) = errvc(optind);
    falseposmat(1,classind) = falseposvc(optind);
    falsenegmat(1,classind) = falsenegvc(optind);
    
end

clipstrct.kopt = k;
clipstrct.threshvc = votethresh;
clipstrct.errvc = errmat;
clipstrct.falseposvc = falseposmat;
clipstrct.falsenegvc = falsenegmat;
clipstrct.votevc = votemat;
clipstrct.class = class;
clipstrct.votemat = squeeze(votemat2);
clipstrct.errmat = errmat;

set(handles.load_clips,'UserData',clipstrct);

saveopt = questdlg('Save sample optimization?','Save optimization','Yes','No','Yes');

if saveopt
    save_set_Callback(0, 0, handles);
end