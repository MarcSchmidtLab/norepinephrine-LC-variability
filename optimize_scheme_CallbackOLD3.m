function optimize_scheme_CallbackOLD3(hObject, eventdata, handles)
% hObject    handle to make_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

template_propstrct = get(handles.template_axis,'UserData');
templatestrct = get(handles.make_template,'UserData');
clipstrct = get(handles.load_clips,'UserData');
clip_propstrct = get(handles.clip_axis,'UserData');

templatenm = length(templatestrct.specarr);

h = waitbar(0/templatenm,'Optimizing templates');

for templateind = 1:templatenm

    temp1 = {};

    matchinds = find(strcmp(clipstrct.speclabs,templatestrct.speclabs(templateind)));
    matchnm = length(matchinds);
    clipnm = length(clipstrct.speclabs);

    nonmatchinds = setdiff(1:clipnm,matchinds);

    indtmp = randperm(matchnm);
    tempinds{templateind} = matchinds(indtmp(1:floor(matchnm/2)));
    threshinds{templateind} = matchinds(indtmp(floor(matchnm/2)+1:end));

    tempnm = length(tempinds{templateind});
    threshnm = length(threshinds{templateind});

    scrs = zeros(tempnm,1);
    mininds = 1:tempnm;
    metaind = 1;
    cont = 1;

    while cont == 1

        ind = ceil(rand*length(mininds));
        
        temptmp = clipstrct.specarr{tempinds{templateind}(mininds(ind))};

        for clipind = 1:tempnm
            clip = clipstrct.specarr{tempinds{templateind}(clipind)};
            scrs(clipind,metaind) = dtwscore(temptmp,clip);
        end

%         inds = find(scrs(:,metaind) >= prctile(scrs(:,metaind),75));
%         temp1{metaind} = mkTemplateDTW(clipstrct.specarr(tempinds{templateind}(inds)));

        temp1{metaind} = temptmp;
        
        thresh = prctile(scrs(:,metaind),25);
        mininds2 = find(scrs(:,metaind) < thresh);

        if metaind > 1
            mininds = intersect(mininds,find(scrs(:,metaind)<thresh));
        else
            mininds = mininds2;
        end
        
%         minind = find(scrs(:,metaind)==min(scrs(:,metaind)));
        %
        %     mininds = find(scrs(:,metaind) < thresh);

        scrs2 = zeros(tempnm,metaind);
        scrs2(:,1:metaind) = scrs;
        scrs = scrs2;
        %
        %     mininds2 = intersect(mininds2,mininds);

        if ~isempty(mininds)
            metaind = metaind + 1;
        else
            cont = 0;
        end

    end

    templatestrct.temparr{templateind} = temp1;
    
    h = waitbar(templateind/templatenm,h);

end

close(h)

matchtot = clipnm * templatenm;
matchind = 1;
h = waitbar(1/matchtot,'Matching samples');

%NOW MATCH ALL SAMPLES W/ OPTIMIZED
for clipind = 1:clipnm
    clip = clipstrct.specarr{clipind};
    
    for templateind = 1:templatenm
        
        matchind = matchind + 1;
        h = waitbar(matchind/matchtot,h);

        tempnm = length(templatestrct.temparr{templateind});
        scrtmp = zeros(tempnm,1);
        
        for tempind = 1:tempnm
            scrtmp(tempind) = dtwscore(templatestrct.temparr{templateind}{tempind},clip);
        end

        [clipstrct.matchmat(clipind,templateind),clipstrct.indmat(clipind,templateind)] = max(scrtmp);

%          clipstrct.matchmat(clipind,templateind) =  dtwscore(templatestrct.specarr{templateind},clip);
%         
    end

end

close(h)

%NOW OPTIMIZE THRESHOLDS

[dmy,maxinds] = max(clipstrct.matchmat');
threshvc = 1:200;

templatestrct.errvc = zeros(1,templatenm);
templatestrct.posnonmax = templatestrct.errvc;

for templateind = 1:templatenm

    scrs = clipstrct.matchmat(:,templateind);
    tempindstmp = tempinds{templateind};
    threshindstmp = threshinds{templateind};
    
    matchinds = find(strcmp(clipstrct.speclabs,templatestrct.speclabs(templateind)));
    matchnm = length(matchinds);
    nonmatchinds = setdiff(1:clipnm,matchinds);
    
    posmaxinds = setdiff(intersect(find(maxinds==templateind),matchinds),tempindstmp);
    posnonmaxinds = setdiff(intersect(find(maxinds~=templateind),matchinds),tempindstmp);
    
    negmaxinds = intersect(find(maxinds==templateind),nonmatchinds);
    negnonmaxinds = intersect(find(maxinds~=templateind),nonmatchinds);
    
    poscrs = scrs(posmaxinds);
    negscrs = scrs(negmaxinds);
    
    posnonmaxnm = length(posnonmaxinds);
    
    maxnm = length(find(maxinds==templateind));
    
    errvc = zeros(1,200);
    for threshind = 1:length(threshvc)
       falsepos = length(find(negscrs >= threshvc(threshind))); 
       falseneg = length(find(poscrs < threshvc(threshind))); 
       errvc(threshind) = (falsepos + falseneg + posnonmaxnm) / clipnm; 
    end
    
    [rt,ind] = min(errvc);
    templatestrct.threshvc(templateind) = threshvc(ind);
    templatestrct.errvc(templateind) = rt;
    templatestrct.posnonmax(templateind) = posnonmaxnm;
    
end
    
set(handles.load_clips,'UserData',clipstrct);
set(handles.make_template,'UserData',templatestrct);

plotemplates(handles)