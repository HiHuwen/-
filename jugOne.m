function d=jugOne(img)
[m,n]=size(img);
wdot=0;
for i=1:m
    for j=1:n
        if img(i,j)==1
            wdot=wdot+1;
        end
    end
end
if (wdot/(m*n))>0.65
    flag = 1;
    img=imresize(img,[40,20]);
    for i=1:m
        flag = 1;
        for j=7:13
           flag = img(i,j)*flag;
        end
        if flag == 1
            break
        end
    end
    if flag == 1
        img=imresize(img,[40,7]);
        nimg=zeros(40,20);
        nimg(1:40,7:13)=img;
        img=nimg;
    end
end
d=img;
end