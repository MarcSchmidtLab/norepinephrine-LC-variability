function optimize_scheme_Callback(hObject, eventdata, handles)
% hObject    handle to make_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

template_propstrct = get(handles.template_axis,'UserData');
templatestrct = get(handles.make_template,'UserData');
clipstrct = get(handles.load_clips,'UserData');
clip_propstrct = get(handles.clip_axis,'UserData');

templateind = find(template_propstrct.selectvc);
matchinds = find(strcmp(clipstrct.speclabs,templatestrct.speclabs(templateind)));
matchnm = length(matchinds);
clipnm = length(clipstrct.speclabs);
scrs = zeros(clipnm,1);

nonmatchinds = setdiff(1:clipnm,matchinds);

indtmp = randperm(matchnm);
tempinds = indtmp(1:floor(matchnm/2));
threshinds = indtmp(floor(matchnm/2)+1:end);
tempinds = matchinds(tempinds);
threshinds = matchinds(threshinds);

mininds = 1:length(tempinds);
metaind = 1;
cont = 1;

while cont == 1

    if length(mininds) > 1
        temp1{metaind} = mkTemplateDTW(clipstrct.specarr(tempinds(mininds)));
    else
        temp1(metaind) = clipstrct.specarr(tempinds(mininds));
    end

    for clipind = 1:clipnm
        clip = clipstrct.specarr{clipind};
        scrs(clipind,metaind) = dtwscore(temp1{metaind},clip);
    end

    thresh = max(scrs(nonmatchinds,metaind));
    mininds2 = find(scrs(tempinds,metaind) <= thresh);
    
    if metaind > 1
        mininds = intersect(mininds,mininds2);
    else
        mininds = mininds2;
    end
    %
    %     mininds = find(scrs(:,metaind) < thresh);

    scrs2 = zeros(clipnm,metaind);
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
set(handles.make_template,'UserData',templatestrct);
deselect_all_Callback(handles.template_axis);