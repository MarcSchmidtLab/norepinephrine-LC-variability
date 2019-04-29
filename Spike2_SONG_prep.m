%   Spike2_SONG_prep.m
%
%   open WAV file, crop to desired song length, generate song reverse and save as .wav file
%   Note: Final cut songs are filtered with a highpass set at 200Hz.
%
%   Written by M. Schmidt on March 21, 2013

% 1. File input
cd ('/Users/marcschm/Desktop/SCHMIDT -LAB/UVA_PAM_EXPERIMENTS/SONG_FILES')

[fname,pname]=uigetfile('*.wav','Choose WAV file to convert');
pathfile=strcat(pname,fname);
[file_rot,frq,bits] = wavread(pathfile);
file_in = rot90(file_rot);

% 2. Highpass filter (500Hz cutoff) song file
file_flt = Highpass_filter (file_in,500,frq);
file_song = Highpass_filter (file_in,500,frq);

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

song = file_song(coord(1):coord(2));
song_rev = fliplr(song);

% 6. Convert to .wav file and save

wavwrite (song_m,frq, 'song');
wavwrite (song_rev_m,frq,'song_rev');


clear all


