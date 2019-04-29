function plot_seq_struct_CallbackOLD(hObject, eventdata, handles)

seqstrct = get(handles.compile_sequences,'UserData');
propstrct = get(get(handles.analysis_panel,'Children'),'UserData');
matchstrct = get(handles.load_match_data,'UserData');
transtrct = get(handles.transition_matrix,'UserData');

seqind = find(propstrct.selectvc);
seq = seqstrct.seqs{seqind};
seqvc = seqstrct.seqmat(seqind,:);
seqvc = seqvc(find(seqvc));

[Nvc,Pvc,Nvcb,Pvcb] = calcseqstats(seqvc,seqstrct.vc);
transmat = transtrct.transmat;

sylnm = length(seq);
Pvc1 = zeros(1,sylnm-1);
Pvcb1 = Pvc1;

Pvc1_l = Pvc1;
Pvc1_u = Pvc1;
Pvcb1_l = Pvc1;
Pvcb1_u = Pvc1;

Pvc_l = Pvc1;
Pvc_u = Pvc1;
Pvcb_l = Pvc1;
Pvcb_u = Pvc1;

seqstrct.labsu(find(strcmp(seqstrct.labsu,'sil'))) = {'*'};

for i = 1:sylnm-1;
    ind1 = find(strcmp(seqstrct.labsu,seq{i}));
    ind2 = find(strcmp(seqstrct.labsu,seq{i+1}));
    
    Pvc1(i) = transmat(ind1,ind2) / sum(transmat(ind1,:));
    Pvcb1(i) = transmat(ind1,ind2) / sum(transmat(:,ind2));
    
    [Pvc1_l(i),Pvc1_u(i)] = propCI(Pvc1(i),sum(transmat(ind1,:)),.05);
    [Pvcb1_l(i),Pvcb1_u(i)] = propCI(Pvcb1(i),sum(transmat(ind2,:)),.05);
    
    [Pvc_l(i),Pvc_u(i)] = propCI(Pvc(i),Nvc(i),.05);
    [Pvcb_l(i),Pvcb_u(i)] = propCI(Pvcb(i),Nvcb(i),.05);
    
end

Nvc = Nvc / matchstrct.wavnm;
Nvcb = Nvcb / matchstrct.wavnm;

h = subplot(1,1,1,'Parent',handles.analysis_panel2);
cla(h,'reset');

h = [0 0 0];
h(1) = subplot(3,1,1,'Parent',handles.analysis_panel2);
plot([1:length(Nvc)]-.5,Nvc,'b-o');
hold on
plot([1:length(Nvc)]-.5,Nvcb,'r-x');
ylabel('mean # per .wav file')
ylim([0 max([Nvc Nvcb])*1.1])

legend({'forward','backward'},'Location','best')
set(h(1),'xtick',[1:length(seq)]-.5,'xticklabel',[],'xlim',[0 length(seq)],'box','off')

h(2) = subplot(3,1,2,'Parent',handles.analysis_panel2);
errorbar(1:length(Pvc),Pvc,Pvc-Pvc_l,Pvc_u-Pvc,'b-');
hold on
errorbar(1:length(Pvc1),Pvc1,Pvc1-Pvc1_l,Pvc1_u-Pvc1,'r-');
ylim([0 1])
ylabel('forward trans. prob.')

legend({'conditional','1st order'},'Location','best')
set(h(2),'xtick',[1:length(seq)]-.5,'xticklabel',[],'xlim',[0 length(seq)],'box','off')

h(3) = subplot(3,1,3,'Parent',handles.analysis_panel2);
errorbar(1:length(Pvcb),Pvcb,Pvcb-Pvcb_l,Pvcb_u-Pvcb,'b-');
hold on
errorbar(1:length(Pvcb1),Pvcb1,Pvcb1-Pvcb1_l,Pvcb1_u-Pvcb1,'r-');
ylim([0 1])
ylabel('backward trans. prob.')

legend({'conditional','1st order'},'Location','best')


set(h(3),'xtick',[1:length(seq)]-.5,'xticklabel',seq,'xlim',[0 length(seq)],'box','off')
