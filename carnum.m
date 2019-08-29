function Code=carnum()
    liccode = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ辽粤豫鄂鲁陕京津';
    l=1;
    Error = zeros(1,50);
    Code = '';
    imgcach=zeros(40,20,43);
    
    for num=1:43
        fname=strcat('字符模板\',liccode(num),'.jpg');
        theimg=imread(fname);
        twopic=theimg(1:40,1:20);
        imgcach(:,:,num)=twopic;
    end
    
    
    for num=1:7
        ii=int2str(num);
        t=imread([ii,'.jpg']);
        SegBw2=imresize(t,[40 20],'nearest');
        SegBw2=double(SegBw2)>127;
        if l==1 %第一位汉字识别
            kmin=37;
            kmax=43;
        elseif l==2 %第二位字母识别
            kmin=11;
            kmax=36;
        elseif l>=3   %第三位后字母或数字识别
            kmin=1;
            kmax=36;
        end
        for k2=kmin:kmax
            
%             fname=strcat('字符模板\',liccode(k2),'.jpg');
%             SamBw2=imread(fname);  
            SamBw2=imgcach(:,:,k2);
            
            SamBw2=double(SamBw2)>127;
            Dmax=piclike(SegBw2,SamBw2);
            Error(k2)=Dmax;
        end
        Error1=Error(kmin:kmax);
        MinError=min(Error1);
        findc=find(Error1==MinError);
        char = liccode(findc(1)+kmin-1);
        if char=='0'||char=='D'
            flagA=1;
            for row=1:5
                flagA=1;
                for col=1:40
                    flagA=SegBw2(col,row)* flagA;
                end
                if flagA==1
                    break;
                end
            end
            if flagA==1
                char='D';
            else
                char='0';
            end
        end
        if char=='0'||char=='Q'
            dot=0;
            for row=9:15
                for col=26:33
                    if SegBw2(col,row)==1
                        dot=dot+1;
                    end
                end
            end
            if dot>20
                char='Q';
            else
                char='0';
            end
        end
        Code(l*2-1) = char;
        Code(l*2)=' ';
        l=l+1;
    end

end