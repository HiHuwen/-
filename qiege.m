function [e,left,top]=qiege(dxx)
d=dxx;
[m,n]=size(d);
x=round(m*0.1);
y=round(n*0.1);
d(1:x,1:y)=0;
d(1:x,n-y:n)=0;
d(m-x:m,1:y)=0;
d(m-x:m,n-y:n)=0;
top=1;
bottom=m;
left=1;
right=n;
while sum(d(top,:))==0 && top<=m
    top=top+1;
end
while sum(d(bottom,:))==0 && bottom>1
    bottom=bottom-1;
end
while sum(d(:,left))==0 && left<n
    left=left+1;
end
while sum(d(:,right))==0 && right>=1
    right=right-1;
end
dd=right-left;
hh=bottom-top;
e=imcrop(dxx,[left top dd hh]);