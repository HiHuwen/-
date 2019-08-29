I = imread('1.jpg');
se=translate(strel(1),[1,0]);
B=imdilate(I,se);
figure; 
subplot(1,2,1),imshow(I); 

subplot(1,2,2),imshow(B); 

