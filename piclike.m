function Dmax = piclike(pic1,pic2) 
SamBw2=pic2;
maxs = zeros(1,9);
k=1;
for i=-1:1
    for j=-1:1
        se=translate(strel(1),[i,j]);
        SegBw2=imdilate(pic1,se);
        maxs(k)=piclikeABS(SegBw2,SamBw2);
        k=k+1;
    end
end
Dmax=min(maxs);
% Dmax = piclikeABS(pic1,pic2);
end