% 	adapting from corr_waves.m

clear all
close all

cd ('S:\Schmidt\Shared\Afrah\Uva_LMAN\GR20\Songs\6_26_14 (1)\CutSong')
load song_all.mat

n = 10;
twin = 10;
all_corr = [];
all_smoothsong = [];

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
        plot(b)
        ab = xcorr(a,b, 'coeff');
        cc = max(ab);
        ccc = [ccc,cc];
        i = i+1;
    end
    
all_corr = [all_corr,ccc];

c = Smoothtrace (abs(songall(k,:)),twin);
all_smoothsong = [all_smoothsong;c];
figure(2);
imagesc(all_smoothsong);

k = k+1;

end

average = mean(all_corr)
standard = std(all_corr)

cd S:\Schmidt\Shared\Afrah\Uva_LMAN\GR20\Songs\6_26_14 (1)\CorrSong
save allcorr6_26_14 (1) all_corr all_smoothsong