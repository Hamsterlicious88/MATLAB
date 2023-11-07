%% 
close all
clear all
clc

%%
fdir='testslot'; %Directory of images

Obj=double(imread(strcat('.',filesep,fdir,filesep,'Obj.tif'))); %Read object
Mesh=double(imread(strcat('.',filesep,fdir,filesep,'Mesh.tif'))); %Read mesh
% Offset=double(imread(strcat('.',filesep,fdir,filesep,'Offset.tif'))); %Read offset
% Gain=double(imread(strcat('.',filesep,fdir,filesep,'Gain.tif'))); %Read gain

CObj=double(Obj);
CMesh=double(Mesh);
Padd='circular';
Filt='corr';
outsize='same';

CorrParam.window=21; %Full Width of correlation window--assume odd for now to center it on a pixel
CorrParam.halfwindow=floor(CorrParam.window/2); %Half width of window in each direction from center pixel
CorrParam.step=1; %Step size in pixels
CorrParam.extrapad=1; %Extra padding on mesh window to allow >1 pixel shift
CorrParam.startidx=[ceil(CorrParam.window/2+CorrParam.extrapad),...
    ceil(CorrParam.window/2+CorrParam.extrapad)]; %Start index not to crop outside image
CorrParam.endidx=[size(Obj,1)-floor(CorrParam.window/2+CorrParam.extrapad),...
    size(Obj,2)-floor(CorrParam.window/2+CorrParam.extrapad)]; %End index not to go outside image

ATT3=zeros(size(CObj,2));
DPCx=ATT3;
DPCx=DPCx(CorrParam.startidx(1):CorrParam.endidx(1),CorrParam.startidx(2):CorrParam.endidx(2));
DPCy=DPCx;
MD=ATT3;

Nw=CorrParam.halfwindow;
Ns=CorrParam.extrapad;

Win=hann(2*Nw+1)*hann(2*Nw+1)';
Win=Win/sum(Win(:));

C1=CObj.^2;
M1=CMesh.^2;

% CCObj=imfilter(C1,Win,Padd,Filt,outsize);
% CCM=imfilter(M1,Win,Padd,Filt,outsize);

CCObj=conv2(C1,flip(flip(Win,1),2),'same');
CCM=conv2(M1,flip(flip(Win,1),2),'same');

imin=30;
imax=2030;
jmin=30;
jmax=2030;

tic

parfor i=imin:imax
    tic
    for j=jmin:jmax
        t1=CCObj(i,j);
        t3=CCM(i-Ns:i+Ns,j-Ns:j+Ns);

        tmesh=CMesh(i-Nw-Ns:i+Nw+Ns,j-Nw-Ns:j+Nw+Ns);
        tobj=Win.*CObj(i-Nw:i+Nw,j-Nw:j+Nw);
        tobj1=flip(tobj,1);
        tobj2=flip(tobj1,2);

        % t5=conv2(tmesh,tobj2,'valid');
        t5=conv2(tmesh,tobj2,'valid');

        K=t5./t3;

        D = t1  + (K.^2).*t3 - 2*K.*t5;

        [a2,G] = min(D(:));
        [r2,c2] = ind2sub(size(D),G);

        Dx=r2; Dy=c2;

Dxp1=Dx+1;
Dxm1=Dx-1;
Dyp1=Dy+1;
Dym1=Dy-1;

if Dxm1<1
    Dxm1=1;
end
if Dym1<1
    Dym1=1;
end
if Dxp1>size(D,2)
    Dxp1=size(D,2);
end
if Dyp1>size(D,2)
    Dyp1=size(D,2);
end


        
        Dxminus=D(Dy,Dxm1);
        Dxplus=D(Dy,Dxp1);
        Dx0=D(Dy,Dx);
        Dyminus=D(Dym1,Dx);
        Dyplus=D(Dyp1,Dx);
        Dy0=D(Dy,Dx);

        Dxshift=Dx-round(size(D,2)/2)-(Dxminus-Dxplus)./(Dxminus+Dxplus+2*Dx0);
        Dyshift=Dy-round(size(D,1)/2)-(Dyminus-Dyplus)./(Dyminus+Dyplus+2*Dy0);

        Dxtemp(i,j)=Dxshift;
        Dytemp(i,j)=Dyshift;
        
        
        ATT3(i,j)=K(r2,c2);
        DPCx(i,j)=r2-Ns;
        DPCy(i,j)=c2-Ns;
        MD(i,j)=D(r2,c2);

    end
    toc
     %i
end

toc

ATT3=ATT3(imin+10:imax,jmin+10:jmax);
DPCx=DPCx(imin+10:imax,jmin+10:jmax);
DPCy=DPCy(imin+10:imax,jmin+10:jmax);
DPCx2=Dxtemp(imin+10:imax,jmin+10:jmax);
DPCy2=Dytemp(imin+10:imax,jmin+10:jmax);
MD=MD(imin+10:imax,jmin+10:jmax);

[Gx,Gy]=gradient(ATT3);

FCsDPC1=FrankotChellapa(DPCy,DPCx,CorrParam.window,eps,'s');
FCsDPC2=FrankotChellapa(DPCy2,DPCx2,CorrParam.window,eps,'s');
FCsgrad=FrankotChellapa(Gy,Gx,CorrParam.window,eps,'a');

figure; imagesc(ATT3); colormap gray; axis image
figure; imagesc(DPCx); colormap gray; axis image
figure; imagesc(DPCy); colormap gray; axis image
figure; imagesc(DPCx2); colormap gray; axis image
figure; imagesc(DPCy2); colormap gray; axis image
figure; imagesc(FCsDPC1); colormap gray; axis image
figure; imagesc(FCsDPC2); colormap gray; axis image
figure; imagesc(MD); colormap gray; axis image

