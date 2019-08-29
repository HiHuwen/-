clc;
I = imread('测试12.jpg');  % read image into workspace

I1X = rgb2gray(I);  % 将原始图像转换为灰度图像
I2X = wiener2(I1X, [5, 5]);  % 对灰度图像进行维纳滤波
I3X = edge(I2X, 'canny');  % 边缘检测
[mX, nX] = size(I3X);  % compute the size of the image
rho = round(sqrt(mX^2 + nX^2)); % 获取ρ的最大值，此处rho=282
theta = 180; % 获取θ的最大值
r = zeros(rho, theta);  % 产生初值为0的计数矩阵
for i = 1 : mX
   for j = 1 : nX
      if I3X(i,j) == 1  % I3是边缘检测得到的图像
          for k = 1 : theta
             ru = round(abs(i*cosd(k) + j*sind(k)));
             r(ru+1, k) = r(ru+1, k) + 1; % 对矩阵计数 
          end
      end
   end
end
r_max = r(1,1); 
for i = 1 : rho
   for j = 1 : theta
       if r(i,j) > r_max
          r_max = r(i,j); 
          c = j; % 把矩阵元素最大值所对应的列坐标送给c
       end
   end
end
if c <= 90
   rot_theta = -c;  % 确定旋转角度
else
    rot_theta = 180 - c; 
end
I = imrotate(I, rot_theta, 'crop');  % 对图像进行旋转，校正图像

hx=fspecial('average',3);
I=imfilter(I,hx);

I1=rgb2gray(I);
figure,imshow(I1);title('灰度图');

I2=edge(I1,'roberts',0.10,'both');
figure,imshow(I2);title('边缘检测');

se=[1;1;1];
I3=imerode(I2,se);%腐蚀操作
figure,imshow(I3);

se=strel('rectangle',[25,25]);
I4=imclose(I3,se);%图像聚类，填充图像
figure,imshow(I4);
[hig,len]=size(I4);
I5=bwareaopen(I4,round(hig*len*0.005));%去除聚团灰度值小于2000的部分
figure,imshow(I5);

[y,x]=size(I5);%返回I5各维的尺寸，存储在x,y,z中

myI=double(I5);
figure,imshow(myI); 

Blue_y=zeros(y,1);%产生一个y*1的零针
for i=1:y
    for j=1:x
        if(myI(i,j,1)==1)%如果myI图像坐标为（i，j）点值为1，即背景颜色为蓝色，blue加一
            Blue_y(i,1)=Blue_y(i,1)+1;%蓝色像素点统计
        end
    end
end
[tempY,MaxY]=max(Blue_y);
%Y方向车牌区域确定
PY1=MaxY;
ykx=round(x*0.02);
yky=round(y*0.03);
while((Blue_y(PY1,1)>=yky)&&(PY1>1))
    PY1=PY1-1;
end
PY2=MaxY;
while((Blue_y(PY2,1)>=yky+2)&&(PY2<y))
    PY2=PY2+1;
end
IY=I(PY1:PY2,:,:);
figure,imshow(IY);
%X方向车牌区域确定
Blue_x=zeros(1,x);%进一步确认x方向的车牌区域
for j=1:x
    for i=PY1:PY2
        if(myI(i,j,1)==1)
            Blue_x(1,j)=Blue_x(1,j)+1;
        end
    end
end
PX1=1;
while((Blue_x(1,PX1)<ykx)&&(PX1<x))
    PX1=PX1+1;
end
PX2=x;
while((Blue_x(1,PX2)<ykx)&&(PX2>PX1))
    PX2=PX2-1;
end
PX1=PX1-1;%对车牌区域的矫正
PX2=PX2+1;
dw=I(PY1:PY2,PX1:PX2,:);
figure,imshow(dw);

b=rgb2gray(dw);%将车牌图像转换为灰度图

g_max=double(max(max(b)));
g_min=double(min(min(b)));
T=round(g_max-(g_max-g_min)/3);%T为二值化的阈值
d=(double(b)>=T);%d:二值图像
[rx,xy]=size(d);
bcnt=0;
for i=1:rx
    for j=1:xy
        if d(i,j)==1
            bcnt=bcnt+1;
        end
    end
end
if bcnt/rx/xy > 0.5
    d=(double(b)<=T);%d:二值图像
end


figure,imshow(d);

h=fspecial('average',3);
d=imbinarize(round(filter2(h,d)));%使用指定的滤波器h对h进行d即均值滤波

zid=d;
dots=round(rx*xy*0.003);
d=bwareaopen(d,dots);
figure,imshow(d);

se=eye(2);                    %单位矩阵
[m,n]=size(d);                 %返回信息矩阵
if bwarea(d)/m/n>=0.365        %计算二值图像中对象的总面积与整个面积的比是否大于0.365
    d=imerode(d,se);           %如果大于0.365则进行腐蚀
elseif bwarea(d)/m/n<=0.235    %计算二值图像中对象的总面积与整个面积的比值是否小于0.235
    d=imdilate(d,se);          %如果小于则实现膨胀操作
end
figure,imshow(d);title('第一次切割前，腐蚀膨胀后');

%寻找连续有文字的块，若长度大于某阈值，则认为该块有两个字符组成，需要分割
[d,chx,chy]=qiege(d);
zix=chx;
ziy=chy;
figure,imshow(d);title('第一次切割后');

[~,n]=size(d);
k1=1;
k2=1;
s=sum(d);
j=1;
while j~=n
    while s(j)==0
        j=j+1;
    end
    k1=j;
    while s(j)~=0 && j<=n-1
        j=j+1;
    end
    k2=j-1;
    if k2-k1>=round(n/6.5)
        [val,I]=min(sum(d(:,k1+5:k2-5)));
        d(:,k1+I+5)=0;%分割
    end
end
%再切割
figure,imshow(d);title('切割前');
[d,chx,chy]=qiege(d);
zix=zix+chx-1;
ziy=ziy+chy-1;
figure,imshow(d);title('切割后');
%切割出7个字符
[~,length]=size(d);
y1=round(length*0.05);
y2=0.25;
flag=0;
word1=[];
while flag==0
    [m,~]=size(d);
    left=1;
    wide=0;
    while sum(d(:,wide+1))~=0
        wide=wide+1;
    end
    if wide<y1 %认为是左干扰 
        d(:,1:wide)=0;
        [d,chx,chy]=qiege(d);
        zix=zix+chx-1;
        ziy=ziy+chy-1;
    else
        [temp,chx,chy]=qiege(imcrop(d,[1 1 wide m]));
        zix=zix+chx-1;
        ziy=ziy+chy-1;
        [m,~]=size(temp);
        all=sum(sum(temp));
        two_thirds=sum(sum(temp(round(m/3):2*round(m/3),:)));
        if two_thirds/all>y2
            flag=1;
            word1=temp;%word1
        end
        d(:,1:wide)=0;
        [d,chx,chy]=qiege(d);
        if flag~=1
        zix=zix+chx-1;
        ziy=ziy+chy-1;
        end
    end
end
figure,imshow(d);title('切割完第一个汉字后的图片');

se=eye(2);                    
[zim,zin]=size(zid);                 
if bwarea(zid)/zim/zin>=0.365        
    zid=imerode(zid,se);           
elseif bwarea(zid)/zim/zin<=0.235    
    zid=imdilate(zid,se);         
end
[zih,zil]=size(word1);
hanzi=imcrop(zid,[zix,ziy,zil,zih]);
word1=hanzi;
figure,imshow(hanzi);title('定位切割出的汉字');
%分割出第二至七个字符
[word2,d]=getword(d);
[word3,d]=getword(d);
[word4,d]=getword(d);
[word5,d]=getword(d);
[word6,d]=getword(d);
[word7,d]=getword(d);
[m,n]=size(word1);
%商用系统程序中归一化大小为40*20
word1=imresize(word1,[40 20]);
word2=deldot(word2);
word2=imresize(word2,[40 20]);
word3=jugOne(word3);
word3=imresize(word3,[40 20]);
word4=jugOne(word4);
word4=imresize(word4,[40 20]);
word5=jugOne(word5);
word5=imresize(word5,[40 20]);
word6=deldot(word6);
word6=jugOne(word6);
word6=imresize(word6,[40 20]);
word7=jugOne(word7);
word7=imresize(word7,[40 20]);

figure,
subplot(171);imshow(word1),title('1');
subplot(172);imshow(word2),title('2');
subplot(173);imshow(word3),title('3');
subplot(174);imshow(word4),title('4');
subplot(175);imshow(word5),title('5');
subplot(176);imshow(word6),title('6');
subplot(177);imshow(word7),title('7');
imwrite(word1,'1.jpg');
imwrite(word2,'2.jpg');
imwrite(word3,'3.jpg');
imwrite(word4,'4.jpg');
imwrite(word5,'5.jpg');
imwrite(word6,'6.jpg');
imwrite(word7,'7.jpg');
%liccode = char(['0':'9' 'A':'Z' '辽粤豫鄂鲁陕京津']);
%京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼
liccode = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ辽粤豫鄂鲁陕京津';
l=1;
Error = zeros(1,50);
Code = '';
for I=1:7
    ii=int2str(I);
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
        fname=strcat('字符模板\',liccode(k2),'.jpg');
        SamBw2=imread(fname);
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
figure,imshow(dw),title(['车牌号码：',Code],'Color','b');
%figure,imhist(I1);title('灰度化直方图');

