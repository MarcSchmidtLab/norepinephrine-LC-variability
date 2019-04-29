% 	manual_UVA_cut.m

%	Script that allows the user to specify, using ginput, the onset
%	time of individual syllables in cowbird song. The script then uses
%   these onset times to cut segments of song based on syllable onsets.

%	Written by Marc F. Schmidt on October 10, 2013

clear all
close all

cd ('C:\Users\mgull\Desktop\R3\Pre Lesion\Feb14\1869')

[fname,pname] = uigetfile('*.wav','Choose .wav file to convert');
pathfile = strcat(pname,fname);
[file_rot,frq,bits] = wavread(pathfile);
file_in = rot90(file_rot);

% 2. Highpass filter (200Hz cutoff) song file
file_flt = Highpass_filter (file_in,500,frq);

% 3. Normalize sound file
big = max(file_flt);
small = min(file_flt);

if big > abs(small);
   divisor = big;
else
   divisor = (0 - small);
end;

file_norm = (file_flt ./ divisor);

% 4. Choose cut coordinates from filtered file
   
figure(1)
plot(file_norm)
coord=ginput(2);

% 5. Cut unfiltered song file

song = file_norm (coord(1):coord(2));

% 6. Asking for variables

   prompt = {'Number of start points','Time pre-onset (ms)','Time post-onset (ms)','Total song (ms)'};
   titre = 'Syllables';
   def = {'1','400','800','1200'};
   lineNo = 1;
   [answer] = inputdlg (prompt,titre,lineNo,def);
   number = str2num (answer {1});
   syll_pre = str2num (answer {2});
   syll_post = str2num (answer {3});
   total_song = str2num (answer {4});

% 7. View Song

figure(2)
subplot(211)
plot(song)
axis ([0 length(song)  -1 1]);

subplot(212)

[b,f,t] = specgram (song,1000,frq,hamming(1000),800);

colormap ('default');
new_t = length(t);
conversion = (1000 ./ frq);
le=length(song)*conversion;
time_sono = ((le/new_t):(le/new_t):le);
imagesc (time_sono,f,20*log10(abs(b)));
axis ('xy');
axis ([0 le 0 10000]);


time_song = (1/10:1/10:length (new_t)/10);
xlabel('msec')
ylabel('Freq')





% 8. Determine Motif or Syllable Onset
%
% 	This section allows you to first zoom in on syllables of the first
%	motif to determine onset times then zoom out and zoom back in on 
%	second motif to determine the last half of syllable onsets. Between both
%	zoom tasks you must type 'return' at 'keyboard' prompt.

%zoom on
%keyboard
[x,y] = ginput(number);
index_on=[];

conversion_song = frq ./ 1000;


for q=1:number
   axis ([(x(q)-(30*conversion_song)) (x(q)+(100*conversion_song)) -0.15 0.15])	 
  [onset,y]=ginput(1);
  index_on=[index_on onset];
	q=q+1;
end


% 9. To convert Time values to data points based on sampling rate.

syll_pre = syll_pre * conversion_song;
syll_post = syll_post * conversion_song;
total_song = total_song * conversion_song;

% 10. Cut Files
n=length(index_on);
for i=1:n
   pre=index_on(1,i);
   s(i,:)= song(pre-syll_pre:pre+syll_post);
   i=i+1;
end

pre_syll_1 = index_on(1,1);
all_song = song(pre_syll_1-syll_pre:pre_syll_1+total_song);
%all_song = [];

s=s';

song = s(:,1);

%	Note: if you get error message: 'Index into matrix is negative or zero'
%	then check to make sure that syll_pre time is not longer that the onset time
%	of the fist syllable of the song.

% 11. Save Files
prompt  = {'Base filename'};
titre   = 'SAVE FILE';
   	def = {'song-'};
		lineNo  = 1;
   	[answer]  = inputdlg(prompt,titre,lineNo,def);
      name = (answer {1});

cd ('C:\Users\mgull\Desktop\R3\Analysis\song\')
      save (name,'song');