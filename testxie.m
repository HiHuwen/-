% 利用hough变换实现车牌图像的倾斜校正
close all; clear all; clc;
I = imread('测试1quanuqn.jpg');  % read image into workspace
figure;
%subplot(131), imshow(IX); 
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
subplot(133), imshow(I);