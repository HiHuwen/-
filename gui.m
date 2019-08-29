function varargout = gui(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
%������ʼ��
function gui_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
function varargout = gui_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;

% ======================����ͼ��===============================
function pushbutton1_Callback(hObject, ~, handles)
[filename, pathname]=uigetfile({'*.jpg';'*.bmp'}, 'File Selector');
I=imread([pathname '\' filename]);
handles.I=I;
guidata(hObject, handles);
axes(handles.axes1);
imshow(I);title('ԭͼ');

% ======================ͼ����===============================
function pushbutton2_Callback(~, ~, handles)
I=handles.I;
I1X = rgb2gray(I);  % ��ԭʼͼ��ת��Ϊ�Ҷ�ͼ��
I2X = wiener2(I1X, [5, 5]);  % �ԻҶ�ͼ�����ά���˲�
I3X = edge(I2X, 'canny');  % ��Ե���
[mX, nX] = size(I3X);  % compute the size of the image
rho = round(sqrt(mX^2 + nX^2)); % ��ȡ�ѵ����ֵ���˴�rho=282
theta = 180; % ��ȡ�ȵ����ֵ
r = zeros(rho, theta);  % ������ֵΪ0�ļ�������
for i = 1 : mX
   for j = 1 : nX
      if I3X(i,j) == 1  % I3�Ǳ�Ե���õ���ͼ��
          for k = 1 : theta
             ru = round(abs(i*cosd(k) + j*sind(k)));
             r(ru+1, k) = r(ru+1, k) + 1; % �Ծ������ 
          end
      end
   end
end
r_max = r(1,1); 
for i = 1 : rho
   for j = 1 : theta
       if r(i,j) > r_max
          r_max = r(i,j); 
          c = j; % �Ѿ���Ԫ�����ֵ����Ӧ���������͸�c
       end
   end
end
if c <= 90
   rot_theta = -c;  % ȷ����ת�Ƕ�
else
    rot_theta = 180 - c; 
end
I = imrotate(I, rot_theta, 'crop');  % ��ͼ�������ת��У��ͼ��

hx=fspecial('average',3);
I=imfilter(I,hx);

I1=rgb2gray(I);
axes(handles.axes2);imshow(I1);title('����У����ĻҶ�ͼ');

I2=edge(I1,'roberts',0.10,'both');
axes(handles.axes3);imshow(I2);title('��Ե���');

se=[1;1;1];
I3=imerode(I2,se);%��ʴ����
[hig,len]=size(I3);
se=strel('rectangle',[round(hig*0.05),round(len*0.05)]);
I4=imclose(I3,se);%ͼ����࣬���ͼ��

I5=bwareaopen(I4,round(hig*len*0.005));%ȥ�����ŻҶ�ֵС��2000�Ĳ���

[y,x,~]=size(I5);%����15��ά�ĳߴ磬�洢��x,y,z��
myI=double(I5);

Blue_y=zeros(y,1);%����һ��y*1������
for i=1:y
    for j=1:x
        if(myI(i,j,1)==1)%���myIͼ������Ϊ��i��j����ֵΪ1����������ɫΪ��ɫ��blue��һ
            Blue_y(i,1)=Blue_y(i,1)+1;%��ɫ���ص�ͳ��
        end
    end
end
[~, MaxY]=max(Blue_y);
%Y����������ȷ��
%tempΪ����yellow_y��Ԫ���е����ֵ��MaxYΪ��ֵ������
ykx=round(x*0.02);
yky=round(y*0.02);
PY1=MaxY;
while((Blue_y(PY1,1)>=yky)&&(PY1>1))
    PY1=PY1-1;
end
PY2=MaxY;
while((Blue_y(PY2,1)>=yky+2)&&(PY2<y))
    PY2=PY2+1;
end

%X����������ȷ��
Blue_x=zeros(1,x);%��һ��ȷ��x����ĳ�������
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
PX1=PX1-1;%�Գ�������Ľ���
PX2=PX2+1;
dw=I(PY1:PY2,PX1:PX2,:);
axes(handles.axes4);imshow(dw),title('��λ����');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b=rgb2gray(dw);%������ͼ��ת��Ϊ�Ҷ�ͼ
% imwrite(b,'�Ҷȳ���.jpg');%���Ҷ�ͼд���ļ�
g_max=double(max(max(b)));
g_min=double(min(min(b)));
T=round(g_max-(g_max-g_min)/3);%TΪ��ֵ������ֵ

d=(double(b)>=T);%d:��ֵͼ��
[rx,xy]=size(b);
bcnt=0;
for i=1:rx
    for j=1:xy
        if d(i,j)==1
            bcnt=bcnt+1;
        end
    end
end
if bcnt/rx/xy > 0.5
    d=(double(b)<=T);%d:��ֵͼ��
end


h=fspecial('average',3);
%����Ԥ������˲����ӣ�averageΪ��ֵ�˲���ģ��ߴ�Ϊ3*3
d=imbinarize(round(filter2(h,d)));%ʹ��ָ�����˲���h��h����d����ֵ�˲�

zid=d;
dots=round(rx*xy*0.0025);
d=bwareaopen(d,dots);
%ĳЩͼ����в���
%���ͻ�ʴ
se=eye(2);%��λ����
[m,n]=size(d);%������Ϣ����
if bwarea(d)/m/n>=0.365%�����ֵͼ���ж�������������������ı��Ƿ����0.365
    d=imerode(d,se);%�������0.365����и�ʴ
elseif bwarea(d)/m/n<=0.235%�����ֵͼ���ж�������������������ı�ֵ�Ƿ�С��0.235
    d=imdilate(d,se);%%���С����ʵ�����Ͳ���
end
%Ѱ�����������ֵĿ飬�����ȴ���ĳ��ֵ������Ϊ�ÿ��������ַ���ɣ���Ҫ�ָ�
[d,chx,chy]=qiege(d);
zix=chx;
ziy=chy;
[~,n]=size(d);
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
        [~,num]=min(sum(d(:,k1+5:k2-5)));
        d(:,k1+num+5)=0;%�ָ�
    end
end
%���и�
[d,chx,chy]=qiege(d);
zix=zix+chx-1;
ziy=ziy+chy-1;
%�и��7���ַ�
[~,length]=size(d);
y1=round(length*0.05);
y2=0.25;
flag=0;
word1=[];
while flag==0
    [m,~]=size(d);
    wide=0;
    while sum(d(:,wide+1))~=0
        wide=wide+1;
    end
    if wide<y1 %��Ϊ������� 
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
%�ָ���ڶ����߸��ַ�
[word2,d]=getword(d);
[word3,d]=getword(d);
[word4,d]=getword(d);
[word5,d]=getword(d);
[word6,d]=getword(d);
[word7,~]=getword(d);
%����ϵͳ�����й�һ����СΪ40*20
word1=imresize(word1,[40 20]);
word2=deldot(word2);
word2=imresize(word2,[40 20]);
word3=deldot(word3);
word3=jugOne(word3);
word3=imresize(word3,[40 20]);
word4=deldot(word4);
word4=jugOne(word4);
word4=imresize(word4,[40 20]);
word5=deldot(word5);
word5=jugOne(word5);
word5=imresize(word5,[40 20]);
word6=deldot(word6);       %ע����仰������ ����11.jpg ��չʾû��ȥ���ӵ�Ч��
word6=jugOne(word6);
word6=imresize(word6,[40 20]);
word7=deldot(word7);
word7=jugOne(word7);
word7=imresize(word7,[40 20]);
axes(handles.axes5);imshow(word1),title('1');
axes(handles.axes6);imshow(word2),title('2');
axes(handles.axes7);imshow(word3),title('3');
axes(handles.axes8);imshow(word4),title('4');
axes(handles.axes9);imshow(word5),title('5');
axes(handles.axes10);imshow(word6),title('6');
axes(handles.axes11);imshow(word7),title('7');
axes(handles.axes13);imhist(I1);title('�ҶȻ�ֱ��ͼ');
wait=imread('wait.jpg');
axes(handles.axes12);imshow(wait),title('���ƺ������ڼ�����','Color','b');
axes(handles.axes13);imhist(I1);title('�ҶȻ�ֱ��ͼ');

imwrite(word1,'1.jpg');
imwrite(word2,'2.jpg');
imwrite(word3,'3.jpg');
imwrite(word4,'4.jpg');
imwrite(word5,'5.jpg');
imwrite(word6,'6.jpg');
imwrite(word7,'7.jpg');
Code=carnum();
axes(handles.axes12);imshow(dw),title(['���ƺ��룺',Code],'Color','b');

% ==========================�˳�ϵͳ============================
function pushbutton3_Callback(~, ~, ~)
close(gcf);



