function y=Highpass_filter(x,cutoff,sr)
%usage: y=highpass(x,cutoff,sr);
%high-pass  cutoff filter
%10th order butterworth non-causal; b=nth order 

nyquist=sr/2;
[b,a]=butter(8, cutoff/nyquist,'high');
y=filtfilt(b,a,x);
