clc;
num1 = imread('1.jpg'); 
num2 = imread('�ַ�ģ��\³.jpg');
num1=double(num1)>127;
num2=double(num2)>127;
Dmax = piclikeABS(num1,num2);
disp(Dmax); 
