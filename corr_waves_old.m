clear all
close all

cd ('Z:\Afrah\OR18\Songs\5_27_14\CutSong\')
load song_all.mat

n = 10;
twin = 10;
all_corr = [];

songall = songall';

for k = 1:n;

        ccc=[];                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
        i=1;
                  
    while k+i <= n
        a = Smoothtrace (abs(songall(k,:)),twin);
        b = Smoothtrace (abs(songall(k+i,:)),twin);
        figure(1)
        plot(a)
        hold on
        ab = xcorr(a,b,'coeff');
        cc = max(ab); 
        ccc = [ccc,cc];
        i = i+1;
    end

all_corr = [all_corr,ccc];

k = k+1;

end

average = mean(all_corr)
standard = std(all_corr)

bk42minus1_xcorr10=all_corr;

cd Z:\Afrah\OR18\Songs\CorrSong\
save bk42minus1_xcorr10 bk42minus1_xcorr10