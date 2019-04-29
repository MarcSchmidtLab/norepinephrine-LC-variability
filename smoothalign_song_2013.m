% 	nalini.m
%	Script to smooth and then align song to a syllable: taken from Marc
%	Schmidt's scripts, adapted by Nalini on 4.28.14






















%cd ('/Users/marcschm/Desktop/SCHMIDT -LAB/GRANTS/GRANT APPLICATIONS - pending/NSF-2014/nsf2014 - Figure 3/LMAN-lesion-LB47/Analysis-syllable1')
%load LMAN_ALL

%a= corrcoef (song1_s, song2_s); b= a(2,1);


%a= corrcoef (song2_s, song3_s); b= [b,a(2,1)];
%a= corrcoef (song3_s, song4_s); b= [b,a(2,1)];
%a= corrcoef (song3_s, song4_s); b= [b,a(2,1)];
%a= corrcoef (song4_s, song5_s); b= [b,a(2,1)];
%a= corrcoef (song5_s, song6_s); b= [b,a(2,1)];
%a= corrcoef (song6_s, song7_s); b= [b,a(2,1)];


%average = mean(b);
%standard = std(b);





for i=1:n
   pre=index(i,1);
   n1(i,:)= FL(pre - syll_pre : pre + syll_post);
   n2(i,:)= HVc(pre-syll_pre:pre+syll_post);
   s(i,:)= song(pre-syll_pre:pre+syll_post);
   i=i+1;
end