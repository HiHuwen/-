% ����hough�任ʵ�ֳ���ͼ�����бУ��
close all; clear all; clc;
I = imread('����1quanuqn.jpg');  % read image into workspace
figure;
%subplot(131), imshow(IX); 
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
subplot(133), imshow(I);