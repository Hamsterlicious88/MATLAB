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

CorrParam.window=4; %Full Width of correlation window--assume odd for now to center it on a pixel
CorrParam.halfwindow=floor(CorrParam.window/2); %Half width of window in each direction from center pixel
CorrParam.step=1; %Step size in pixels
CorrParam.extrapad=4; %Extra padding on mesh window to allow >1 pixel shift
CorrParam.startidx=[ceil(CorrParam.window/2+CorrParam.extrapad),...
    ceil(CorrParam.window/2+CorrParam.extrapad)]; %Start index not to crop outside image
CorrParam.endidx=[size(Obj,1)-floor(CorrParam.window/2+CorrParam.extrapad),...
    size(Obj,2)-floor(CorrParam.window/2+CorrParam.extrapad)]; %End index not to go outside image

ATT3=zeros(size(CObj,2));
DPCx=ATT3;
DPCy=ATT3;
MD=ATT3;

Nw=CorrParam.halfwindow;
Ns=CorrParam.extrapad;

Win=hamming(2*Nw+1)*hamming(2*Nw+1)';
Win=Win/sum(Win(:));

C1=CObj.^2;
M1=CMesh.^2;

CCObj=imfilter(C1,Win);
CCM=imfilter(M1,Win);

imin=500;
imax=1800;
jmin=500;
jmax=1800;

for i=imin:imax
    for j=jmin:jmax
        t1=CCObj(i,j);
        t3=CCM(i-Nw-Ns:i+Nw+Ns,j-Nw-Ns:j+Nw+Ns);

        tmesh=CMesh(i-Nw-Ns:i+Nw+Ns,j-Nw-Ns:j+Nw+Ns);
        tobj=CObj(i-Nw:i+Nw,j-Nw:j+Nw);

        t5=imfilter(tmesh,Win.*tobj);
        %t5=imresize(t5,size(tobj));

        K=t5./t3;

        D = t1  + (K.^2).*t3 - 2*K.*t5;

        [a2,G] = min(D(:));
        [r2,c2] = ind2sub(size(D),G);
        
        ATT3(i,j)=K(r2,c2);
        DPCx(i,j)=r2-Ns;
        DPCy(i,j)=c2-Ns;
        MD(i,j)=D(r2,c2);

    end
    i
end
ATT3=ATT3(imin+10:imax,jmin+10:jmax);
DPCx=DPCx(imin+10:imax,jmin+10:jmax);
DPCy=DPCy(imin+10:imax,jmin+10:jmax);
MD=MD(imin+10:imax,jmin+10:jmax);

figure; imagesc(ATT3); colormap gray; axis image
figure; imagesc(DPCx); colormap gray; axis image
figure; imagesc(DPCy); colormap gray; axis image
figure; imagesc(MD); colormap gray; axis image

