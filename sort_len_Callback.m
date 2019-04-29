function sort_len_Callback(hObject, eventdata, handles)
% hObject    handle to sort_len (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clipstrct = get(handles.load_clips,'UserData');
plotspecstrct(handles,handles.clip_axis,handles.clip_slider,clipstrct,1000,5,'length');
