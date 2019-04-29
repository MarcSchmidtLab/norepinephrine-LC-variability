%   loadsong_UvaLMAN.m
%
%   open WAV file, crop to desired song length, and convert to matlab format
%
%   Written by M. Schmidt on July 25, 2012
%   Edited by Nalini J on 10/5/13

% 1. File input
cd ('Z:\Nalini\499\MatlabAnalysis\BK42\SongFiles\Day_0')

[fname,pname]=uigetfile('*.wav','Choose WAV file to convert');
pathfile=strcat(pname,fname);
[file_rot,frq,bits] = wavread(pathfile);
file_in = rot90(file_rot);

% 2. Highpass filter (500Hz cutoff) song file
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
   
plot(file_norm)
coord=ginput(2);

% 5. Cut unfiltered song file

song = file_in(coord(1):coord(2));

% 6. Save song
%
%   Note: Song that is saved is the unfiltered song. Filter was only
%   applied to files so that they could be viewed in part 4 and coordinates
%   could be determined.

cd('Z:\Nalini\499\MatlabAnalysis\BK42\SongFiles\Day_0')

prompt  = {'Base filename'};
titre   = 'SAVE FILE';
   	def = {'song-'};
		lineNo  = 1;
   	[answer]  = inputdlg(prompt,titre,lineNo,def);
      name = (answer {1});
      
      save (name,'song');
      

      
clear all


