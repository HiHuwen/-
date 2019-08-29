function word=deldot(pic)
    word=pic;
    [hig,len]=size(word);
    nd=bwareaopen(word,round(hig*len*0.22),4);
    flag = 1;
    for i=1:hig
        for j=1:len
            if word(i,j)~=nd(i,j)
                flag=0;
                break;
            end
        end
        if flag==0
            break;
        end
    end
    if flag==0
         [word,~,~]=qiege(nd);
    end
end