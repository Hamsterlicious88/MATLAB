    tic
        [iOPL,delimiterOut]=importdata("OPL"+num2str(i)+".txt");
        iI1=imtophat(iOPL,strel('line',1,0));
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
        aplmsk=k.*I2;
        dlmwrite("WMask"+num2str(i)+".txt",k, 'delimiter','\t','newline','pc','precision',5);
        imshow(aplmsk), title("Watershed mask: t="+num2str(i))
        drawnow
    toc
end
%%

for i=1:17
    tic
        [iMask,delimeterOut]=importdata("Mask"+num2str(i)+".txt");
        imshow(iMask), title("Hand drawn mask: t="+num2str(i))
        drawnow
    toc
end

%%

for i=1:17
    tic
        [iMask,delimeterOut]=importdata("WMask"+num2str(i)+".txt");
        imshow(iMask), title("Watershed generated mask: t="+num2str(i))
        drawnow
    toc
end

%%

for i=1:17
    tic
        [iOPL,delimeterOut]=importdata("OPL"+num2str(i)+".txt");
        [iMask,delimeterOut]=importdata("WMask"+num2str(i)+".txt");
        %[iMask,delimeterOut]=importdata("Mask"+num2str(i)+".txt");
        iOPL=imadjust(iOPL);
        hmapl=iMask.*iOPL;
        %iOPL=imagesc(iOPL);
        imshow(hmapl), title("Optical path length: t="+num2str(i))
        drawnow
    toc
end
