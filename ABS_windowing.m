

Obj1=double(Obj);
Mesh1=double(Mesh);
Offset1=double(Offset);
Gain1=double(Gain);

blankslate1=zeros(size(Obj1));
blankslate2=zeros(size(Obj1));
blankslate3=zeros(size(Obj1));
blankslate4=zeros(size(Obj1));
blankslate5=zeros(size(Obj1));
blankslate6=zeros(size(Obj1));

%%
%%
CObj1=Obj1;
CMesh1=Mesh1;
CObj1=(Obj1-Offset1)./(Gain1-Offset1);
CMesh1=(Mesh1-Offset1)./(Gain1-Offset1);
% CObj1=(Obj1-Offset1);

%%
%%
xmin=300;
xmax=900;
cropdim=11;
for i = xmin:xmax
    for j = xmin:xmax
        [CObji,recti] = imcrop(CObj1,[i,j,cropdim,cropdim]);
        [Meshi]     = imcrop(CMesh1,recti);
        avg=mean2(CObji)/mean2(Meshi);
        ratio=real(ifft2(fft2(CObji)./fft2(Meshi)));
        ratio=mean2(ratio);
        blankslate1(j,i)=avg;
        blankslate2(j,i)=ratio;
    end
end
figure; imagesc(imcrop(blankslate1,[xmin,xmin,xmax-xmin,xmax-xmin])); colormap gray; axis image
figure; imagesc(imcrop(blankslate2,[xmin,xmin,xmax-xmin,xmax-xmin])); colormap gray; axis image
clear CObji
clear ratio
clear avg
clear cropdim
%%
%%
xmin=800;
xmax=1600;
cropdim=11;
for i = xmin:xmax
    for j = xmin:xmax
        [CObji,recti] = imcrop(Obj1,[i,j,cropdim,cropdim]);
        [Meshi]     = imcrop(Mesh1,recti);
        avg=mean2(CObji)/mean2(Meshi);
        ratio=real(ifft2(fft2(CObji)./fft2(Meshi)));
        ratio=mean2(ratio);
        blankslate3(j,i)=avg;
        blankslate4(j,i)=ratio;
    end
end
figure; imagesc(imcrop(blankslate3,[xmin,xmin,xmax-xmin,xmax-xmin])); colormap gray; axis image
figure; imagesc(imcrop(blankslate4,[xmin,xmin,xmax-xmin,xmax-xmin])); colormap gray; axis image
clear CObji
clear ratio
clear avg
clear cropdim
%%
%%
rdiv=Obj1./Mesh1;
ldiv=Obj1.\Mesh1;
xmin=1;
xmax=2048;
cropdim=10;
for i = xmin:xmax
    for j = xmin:xmax
        [CObji,recti] = imcrop(rdiv,[i,j,cropdim,cropdim]);
        [Meshi]     = imcrop(ldiv,recti);
        avg=mean2(CObji)/mean2(Meshi);
        ratio=real(ifft2(fft2(CObji).*fft2(Meshi)));
        ratio=mean2(ratio);
        blankslate5(j,i)=avg;
        blankslate6(j,i)=ratio;
    end
    i
end
figure; imagesc(imcrop(blankslate5,[xmin,xmin,xmax-xmin,xmax-xmin])); colormap gray; axis image
figure; imagesc(imcrop(blankslate6,[xmin,xmin,xmax-xmin,xmax-xmin])); colormap gray; axis image
clear CObji
clear ratio
clear avg

%%
%%

rdiv=Obj1./Mesh1;
ldiv=Obj1.\Mesh1;
xmin=1500;
xmax=2049;
cropdim=11;
for i = xmin:xmax
    for j = xmin:xmax
        [CObji,recti] = imcrop(rdiv,[i,j,cropdim,cropdim]);
        [Meshi]     = imcrop(ldiv,[i,j,cropdim,cropdim]);
        avg=mean(CObji(:))/mean(Meshi(:));
        ratio=real(ifft2(fft2(CObji).*fft2(Meshi)));
        ratio=mean2(ratio);
        blankslate5(j,i)=avg;
        blankslate6(j,i)=ratio;
    end
end
figure; imagesc(imcrop(blankslate5,[xmin,xmin,xmax-xmin,xmax-xmin])); colormap gray; axis image
figure; imagesc(imcrop(blankslate6,[xmin,xmin,xmax-xmin,xmax-xmin])); colormap gray; axis image
clear CObji
clear ratio
clear avg
