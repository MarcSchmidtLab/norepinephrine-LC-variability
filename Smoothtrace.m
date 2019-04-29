function [smooth] = smoothtrace (waveform,Twin)

%%	smoothtrace.m
%%
%% function [smooth] = smoothtrace (waveform,Twin)
%% Default for synchrony profile is Twin = 1 msec.
%% Script to smooth waveform
%% written by M. F. Schmidt on 6/99

	srate=44100;

   N    = length(waveform);
	win  = Twin*(srate/1000);
   half = (win - 1)/2;
   width = 2;

	%% Filter and full-wave rectify song file


	%% smooth with gaussian kernel
   f  = normpdf([-1+2/win:2/win:1],0,1/width);
   w = conv(waveform,f);%convolve left neural trace
   smooth = w(half+1:N+half); %./max(l2(half:N+half));
	smooth = smooth ./ mean (smooth);
