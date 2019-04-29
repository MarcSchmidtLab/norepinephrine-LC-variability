function optimize_scheme_CallbackOLD4(hObject, eventdata, handles)
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
    nonnm = length(nonmatchinds);

    indtmp = randperm(matchnm);
    tempinds{templateind} = matchinds(indtmp(1:floor(matchnm/2)));
    threshinds{templateind} = matchinds(indtmp(floor(matchnm/2)+1:end));

    tempnm = length(tempinds{templateind});
    threshnm = length(threshinds{templateind});

    
    scrs_temp = zeros(threshnm,tempnm);
    scrs_non = zeros(nonnm,tempnm);
    
    templab = templatestrct.speclabs(templateind);
    
    for tempind = 1:tempnm
        
        
        h = waitbar((templateind-1+tempind/tempnm)/templatenm,h,['Optimizing templates (' templab{1} ')']);
        
        temp = clipstrct.specarr{tempinds{templateind}(tempind)};
        for tempind2 = 1:threshnm
            clip = clipstrct.specarr{threshinds{templateind}(tempind2)};
            scrs_temp(tempind2,tempind) = dtwscore(temp,clip);
        end
        
        for nonind = 1:nonnm
            clip = clipstrct.specarr{nonmatchinds(nonind)};
            scrs_non(nonind,tempind) = dtwscore(temp,clip);
        end
        
    end

    [tempmax,tempmax_inds] = max(scrs_temp');
    [nonmax,nonmax_inds] = min(scrs_non');
    
    d = min(scrs_temp) - max(scrs_non);
    [maxd,maxind] = max(d);
    
    temp1{1} = clipstrct.specarr{tempinds{templateind}(maxind)};

    if maxd <= 0

        inds1 = find(scrs_temp(:,maxind) <= max(scrs_non(:,maxind)));
        inds2 = find(scrs_non(:,maxind) >= min(scrs_temp(:,maxind)));

        t = tabulate(tempmax_inds(inds1));

        [tval,tind] = max(t(:,2));
        maxind2 = t(tind,1);

        temp1{2} = clipstrct.specarr{tempinds{templateind}(maxind2)};

    end

    templatestrct.temparr{templateind} = temp1;

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