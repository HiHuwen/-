function Dmax = piclikeABS(pic1,pic2) 
SegBw2=pic1;
SamBw2=pic2;
SubBw2=zeros(40,20);
% test=zeros(40,20);
for i=1:40
    for j=1:20
        if SegBw2(i,j)>0
            SegBw2(i,j)=255;
        else
            SegBw2(i,j)=0;
        end
    end
end
% figure,imshow(SegBw2);
for i=1:40
    for j=1:20
       if SamBw2(i,j)>0
            SamBw2(i,j)=255;
        else
            SamBw2(i,j)=0;
        end
    end
end
% figure,imshow(SamBw2);
for i=1:40
    for j=1:20
       if SegBw2(i,j)==SamBw2(i,j)
           SubBw2(i,j)=0;
       else
           SubBw2(i,j)=255;
       end
    end
end
Dmax=0; 
for k=1:40
    for l=1:20
        if SubBw2(k,l)~=0
            Dmax=Dmax+1;
        end
    end
end
% figure,imshow(SubBw2);
return
end


