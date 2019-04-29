% 	manual_sylcut_2013_r.m
%
%	Script that allows the user to specify, using ginput, the onset
%	time of individual syllables. The script then uses these onset times
%	to cut segments of song and neural traces based on syllable onsets.
%	This has been modified from previous versions in that it allows to zoom
%	in on each individual syllable and set the onset point more precisely.
%	In addition, length of file is determined on a syllable per syllable basis.
%	Default file length start 120 ms pre syllable onset and goes until syllable
%	offset + 50 msec.
%
%	Note: Sampling rate (SR) for neural files is 10 KHz. Sound SR = 20 Khz.
%
%	Original manual_sylcut written by Marc F. Schmidt on November 3, 1999
% 	Modified by Marc Schmidt on February 10, 2002
%   Edited by Nalini Jain and Randall Tassone April 2013


cd(['Z:\Afrah\OR18\Songs\5_27_14\CutSong']);

[fname,pname]=uigetfile('*.mat');
pathfile=strcat(pname,fname); %concatenates horizontally
load (pathfile); %loads variables from pathfile

srate_song = 25000;
%srate_neural = 25000;

conversion_song = srate_song/1000;
%conversion_neural = srate_neural/1000;

disp(' ');
msg=strcat(fname);
disp(msg);
disp(' ');

   prompt  = {'number of syllables','time pre-syllable onset(ms)','time post-syllable onset(ms)'};
   titre   = 'Syllables';
   def = {'5','150','200'};
   lineNo  = 1;
   [answer]  = inputdlg(prompt,titre,lineNo,def);
   
   number  = str2num (answer {1});
   syll_pre  = str2num (answer {2});
   syll_post  = str2num (answer {3});
   %neural = n;
   %song=s;
 
   
   syll_pre_song = syll_pre * conversion_song;
   syll_post_song = syll_post * conversion_song;
   
   
   %syll_pre_neural = syll_pre * conversion_neural;
   %syll_post_neural = syll_post * conversion_neural;
   
%(1) View Song

%song_flt = Highpass_filter (s,200,srate_song);
specgram (srate_song,song);


% (2) Cut song to workable length
zoom on
keyboard
coord = ginput(2);

sta=coord(1,1);	% start point
sto=coord(2,1);	% stop point

sta_song = (sta*conversion_song) - (syll_pre*conversion_song+500); 
sto_song = (sto*conversion_song) + (syll_post*conversion_song+500);
%sta_neural = (sta*conversion_neural) - (syll_pre*conversion_neural+500); 
%sto_neural = (sto*conversion_neural) + (syll_post*conversion_neural+500);

% Note: 	We are multiplying by conversion to convert from msec to points
%			Add either syll_pre or syll_post to make sure file is long enough when cutting in next operation

s_cut = s(sta_song:sto_song);

normalizing_factor = max (abs(s_cut));
song_norm = s_cut ./ normalizing_factor;
%neural = neural (sta_neural:sto_neural);

specgram (song_norm,srate_song);


% (3) Determine Syllable Onset
%
% 	This section allows you to first zoom in on syllables of the first
%	motif to determine onset times then zoom out and zoom back in on 
%	second motif to determine the last half of syllable onsets. Between both
%	zoom tasks you must type 'return' at 'keyboard' prompt.

[x,y] = ginput(number);
index_on=[];
%subplot(211)
subplot(2,1,1)

for q=1:number	
  axis ([(x(q)-30) (x(q)+100) -0.15 0.15])	 %xmin xmax ymin ymax
  [onset,y]=ginput(1);
  index_on=[index_on onset];
	q=q+1;
end

% (4) Cut Files
n=length(index_on);
for i=1:n
   pre=index_on(i)*conversion_neural;pre=floor(pre);
   n1(i,:)= neural(pre - syll_pre_neural : pre + syll_post_neural);
   
   pre_song=index_on(i)*conversion_song;
    song_cut(i,:)= s_cut(pre_song - syll_pre_song : pre_song + syll_post_song);
   i=i+1;
end
neural=n1';song=song_cut';

%	Note: if you get error message: 'Index into matrix is negative or zero'
%	then check to make sure that syll_pre time is not longer that the onset time
%	of the fist syllable of the song.

cd ('Z:\Uva lesion experiments\UVa_LMAN_Experiments\Cut Syllables');

% (5) Save Files
prompt  = {'Base filename'};
titre   = 'SAVE FILE';
   	def = {'song_'};
		lineNo  = 1;
   	[answer]  = inputdlg(prompt,titre,lineNo,def);
      name = (answer {1});
      
      save (name,'song','neural');
      
disp(' ');
msg=strcat('save file as ',':',' ',name);
disp(msg);
disp(' ');


clear all;
close all;