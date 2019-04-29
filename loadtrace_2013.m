
% loadtrace_2013.m
% 
%	Allows user to load files from observer into matlab format. User needs to
%	define source of files as well as traces to be imported from matlab.
%	The last part of the program allows the user to cut the files to the 
%	appropriate length. You then have to save files separately i.e. this script will not do it for you.
%	Sound files are not decimated and remain at the original smapling rate of 20 KHz. 
%	Written by Marc Schmidt on November 5, 1999
%	Adapted from loadtrace.m on July 15, 2001
%   Modified on 3/26/13 by Randall and Nalini for Uva Analysis
%   Modified by Nalini on 10/4/13 by Nalini to adapt to Uva/LMAN Experiments


% Note to Randall: find out how to extract sampling rate


%Creates Window to Load a File Exported From Spike2
clear all;
close all;
cd ('Z:\Nalini\499\MatlabAnalysis\BK42\SongFiles\Day_0');
[fname,pname]=uigetfile('*.mat');
pathfile=strcat(pname,fname);
matrix = load (pathfile);
disp(' ');
msg=strcat(fname);
disp(msg);
disp(' ');
%Done Creating Window and Loading


%Extract Neural and Sound File by Specifying Channels
%neuralchannel = getfield(matrix, 'Ch3');
songchannel = getfield(matrix, 'Ch1');
%neuralvalues= getfield(neuralchannel,'values');
songvalues= getfield(songchannel,'values');
%neural = neuralvalues;
song=songvalues;
%Done Extracting


%Prompt to Customize Sampling Rate
%%Can leave out if analyzing a lot of data at the same sampling rate%
%prompt  = {'Enter Sampling Rate'};
   %titre   = 'Sampling Rate in Hertz';
   %def = {'25000'};
	%lineNo  = 1;
   %[answer]  = inputdlg(prompt,titre,lineNo,def);
   %sr  = str2num (answer {1});
%End Prompt for Sampling Rate
   

%Highpass Filter the Data 
%X1 = song;
%sr = 25000; 
%halfsr=sr/2;
%Wn = 500/halfsr;                        
%[B,A] = butter(9,Wn,'high');
%filtered_s_500 = filtfilt(B,A,X1);
%X2= neural;
%sr = 25000; 
%halfsr=sr/2;
%Wn = 500/halfsr;                        
%[B,A] = butter(9,Wn,'high');
%filtered_n_500 = filtfilt(B,A,X2);
%Done Filtering


%Normalize Song and Neural Traces and establish time axis variables
filt_s_norm = filtered_s_500 ./ max (abs(filtered_s_500));
filt_n_norm =filtered_n_500./max (abs(filtered_n_500));
time = sr/10000;
t_n = (1/time):(1/time):length(filt_n_norm)/time;
%Done Normalizing and Establishing


%Plot the entire filtered and normalized data
figure(1)
hold off; 
subplot(211)
plot (filt_n_norm);
axis ([0 length(filt_n_norm) -2 2]); 
title('Filtered and Normalized Raw Neural')
subplot(212)
plot (filt_s_norm); 
axis ([0 length(filt_s_norm) -1 1]);
title('Filtered and Normalized Raw Sound')
%Done Plotting the entire filtered/normalized data


%Choose the points where you want to cut the song to. It is easiest to look
%at the song data and cut there
[x,y]=ginput(2);
s=filt_s_norm(x(1):x(2));
n=filt_n_norm(x(1):x(2));
%End Choosing Cutting Points


%Plots the New Cut Song
t_sr=sr/1000;

figure
subplot(311)
le=length(s)/t_sr;
t_song=1/t_sr:1/t_sr:le;
plot(t_song,s)
axis ([0 le -1 1]);
title('New Cut Traces')%title of all three graphs
xlabel('mSec')
ylabel('Freq')
%Done Plotting the New Cut Song and lebeling graph


%Creates and Plots the Spectrogram 
subplot(312)
[b,f,t] = specgram (s,180,t_sr,hamming(180),178);
colormap (jet);
new_t = length(t);
tsong = length(s)/t_sr;
time_sono = ((le/new_t):(le/new_t):tsong);
imagesc (time_sono,f,20*log10(abs(b)));
axis ('xy');
freq = t_sr/2;
%axis ([0 le 0 freq]);
xlabel('mSec')
ylabel('Freq')
%End Creating and Plotting Spectrogram


%Plots the New Cut Neural
subplot(313)
hold off;
hold on;
t_axis=1/25:1/25:length(n)/25;
plot(t_axis,n,'b');
axis ([0 length(t_axis)/25 -1 1])
xlabel('mSec')
ylabel('Freq')
%Done Plotting New Cut Neural


%Save your new data
cd ('/Users/randalltassone/Desktop/Research/Uva Project/Step 1 Processed Files/LB50');
prompt  = {'Base filename'};
titre   = 'SAVE FILE';
   	def = {'1'};
		lineNo  = 1;
   	[answer]  = inputdlg(prompt,titre,lineNo,def);
      name = (answer {1});
      save (name,'n','s');
%clear all
%close all


