clear all, close all
for i = 1:17
    [iOPL,delimiterOut]=importdata("OPL"+num2str(i)+".txt");
    x=mean(iOPL,1);
    y=mean(iOPL,2);
    iOPL=iOPL-x-y;
   
    iI1=imtophat(iOPL,strel('disk',100));
    I2=imadjust(iI1);
    level=graythresh(I2);
    BW=im2bw(I2,level);
    C=~BW;
    D=-bwdist(C);
    D(C)=-inf;
    L=watershed(D);
    k=L;
    k=imbinarize(k,'adaptive');
    %m=I2;
    %m(L==0)=0;
    %figure, imshow(m);
dlmwrite("WMask"+num2str(i)+".txt",k, 'delimiter','\t','newline','pc','precision',5);
end