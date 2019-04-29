%%	-----------------------------------------------------------------------------------------
%%	Histosong_Uva1
%%
%%	Script to calculate histogram for the neural trace aligned to the song. 
%%	
%%	Threshold value for th eneural files is based on mean and STD values of background activity.
%%	Mean and STD for each file must be supplied from rectified waveforms.
%%
%%	Method used for building histogram:
%%		1.	points <threshold = 0
%%	 	2.	smooth remaining waveform
%%		3.	Calculate sum of smooth thresholded waveform
%%
%%
%%	Script performs calculations for all files in a defined folder. Path has to be defined
%%	in script.
%%
%%	Written by Marc Schmidt, June 26, 2001
%%  Edited by Nalini Jain and Randall Tassone, May 2013
%%	-----------------------------------------------------------------------------------------

tic
echo on


%% 1. Open Directory

cd (['/Users/randalltassone/Desktop/Research/Uva Project/Step 2 Processed Files/LB50'])
		%%	Only necessary when running alone

%%	2. Default Variables

	%% a. parameters
	if (exist('SRATE') == 0) 			;SRATE = 25000; end;			%	sampling rate
	if (exist('N') == 0) 				;N = 4; end;					%	number of song iterations
	if (exist('TWIN') == 0) 			;TWIN = 1; end;                 % 	Smoothing WINDOW
    if (exist('songsegment') == 0) 		;songsegment = 1; end;			%	segment number determines the syllable being analyzed
	if (exist('THRESH') == 0) 			;THRESH = 3; end;				%	THRESH = Number of STDs above mean
   
   %% b. Threshold Values
    if (exist('MEAN_NEURAL') == 0) 		;MEAN_NEURAL = 0.048; end;     % 	Mean neural (from rectified trace)
   
    if (exist('STD_NEURAL') == 0) 		;STD_NEURAL = 0.034; end;		% 	Standard deviation neural (from rectified trace)


   %%	c. filenames
    if (exist('filename') == 0)		;filename = 'song_'; end;	%open filename
   
    histo_neural = [];
    histo_song = [];
   
%%	3. Conversion of Variables into sample points based on sampling rate of 10 KHz

sr = SRATE/1000;

%%	4. Smoothing Parameters
TWIN = 1;
win  = TWIN*(SRATE/1000);
half = (win - 1)/2;
width = 2;
f  = normpdf([-1+2/win:2/win:1],0,1/width);


%%	5. Calculation of Threshold

thresh_neural = MEAN_NEURAL + (THRESH * STD_NEURAL);

%%	6. Calculation of Smoothed Histogram

for i=1:N;
    file = strcat(filename,int2str(i)); 
    load (sprintf(file));

   %%	a. Loading normal traces
   
    neural1=neural(:,songsegment);
    n = abs (neural1);L = length(neural1);
    %n=n';
    
    song1=song(:,songsegment);
    song1 = song1 ./ max (song1);
    song1 = song1';
   
   %%	b. Thresholding waveform
   
    %thresh_neural1 = find (neural1 <= thresh_neural);
    %n(thresh_neural1) = 0;
    % randall = find (n > thresh_neural);
    % n (randall) = 1; % this will turn the vector into 1s and 0s.
   
   %% c. Convolution of thresholded traces
   neural3 = conv(n,f); 
   neural3 = neural3 ((win/2) : length(neural3) - (win/2)); % to reduce vector to original length
   new_neural = neural3'; 
   
   %% d. Summing of smoothed traces
   histo_neural = [histo_neural ;  new_neural];
   histo_song = [histo_song ; song1];
   
   i=i+1;
end

%%	7. normalization of smoothed histograms.

sum_histoneural = sum(histo_neural);

histo_neural_norm = sum_histoneural ./ N;		% averaged histo

%%	8. Creation of Time Vector from histo 

      time=1/sr:1/sr:L/sr;
      
%%	9. Figures 

figure
subplot(211);
h = histo_neural(1,:) ./ max(histo_neural(1,:)); plot (time,h,'k')
hold on
h = histo_neural(2,:) ./ max(histo_neural(2,:)); plot (time,h+1,'k')
h = histo_neural(3,:) ./ max(histo_neural(3,:)); plot (time,h+2,'k')
%h = histo_neural(4,:) ./ max(histo_neural(4,:)); plot (time,h+3,'k')
%h = histo_neural(5,:) ./ max(histo_neural(5,:)); plot (time,h+4,'k')
%h = histo_neural(6,:) ./ max(histo_neural(6,:)); plot (time,h+5,'k')
%h = histo_neural(7,:) ./ max(histo_neural(7,:)); plot (time,h+6,'k')
%h = histo_neural(8,:) ./ max(histo_neural(8,:)); plot (time,h+7,'k')
%h = histo_neural(9,:) ./ max(histo_neural(9,:)); plot (time,h+8,'k')
%h = histo_neural(10,:) ./ max(histo_neural(10,:)); plot (time,h+9,'k')
plot (time, 12*(histo_neural_norm) -5, 'r')
axis ([0 400 -5 N+2])
title ('Neural Activity (black = single trial; Red = Average)')

subplot (212); 
plot (time, song1)
axis ([0 400 -1.5 1.5])
title ('Syllable')


%%	10. Saving Files 

cd ('/Users/randalltassone/Desktop/Research/Uva Project/Step 3 Processed Files/LB50');

%save MARC histo_song histo_neural sum_histoneural time N histo_neural_norm

%clear all

toc
