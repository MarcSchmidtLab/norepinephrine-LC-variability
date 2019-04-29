% 	align_song.m
%
%	Script to smooth and align songs
%
%	Written by Marc F. Schmidt on October 10, 2013

clear all
close all

%% (1) Setting up the path
cd ('Z:\Nalini\499\MatlabAnalysis\BK42\CutSong\Day_-1')
[fname,pname]=uigetfile('Z:\Nalini\499\MatlabAnalysis\Bk42\CutSong\Day_-1')
pathfile=strcat(pname,fname);
load (pathfile);

%% (2) Parameters

	if (exist('N') == 0) 				N = 10; end;						%	number of song iterations
	if (exist('twin') == 0) 			twin = 15; end;					% 	Smoothing WINDOW
  

for i=1:N
    

    foo (i,:) = Smoothtrace (abs(csongall(i,:)),twin);
   
    i=i+1;
end


%% (3) Plotting

clow = 0;
chigh= 0.8;

clim = [clow,chigh];

figure; imagesc (csongall,clim)
figure; imagesc (foo,clim)
%% (4) Save File
%prompt  = {'Base filename'};
%titre   = 'SAVE FILE';
   	%def = {'s-song-'};
		%lineNo  = 1;
   	%[answer]  = inputdlg(prompt,titre,lineNo,def);
     % name = (answer {1});
      
      
%cd ('Z:\Nalini\499\MatlabAnalysis\LB47\SmoothSong\Day_-3')
      %save (name,'foo');

