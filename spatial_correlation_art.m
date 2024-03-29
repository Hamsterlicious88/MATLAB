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
regparam=eps;

CorrParam.window=11; %Full Width of correlation window--assume odd for now to center it on a pixel
CorrParam.halfwindow=floor(CorrParam.window/2); %Half width of window in each direction from center pixel
CorrParam.extrapad=3; %Extra padding on mesh window to allow >1 pixel shift
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

Win=hamming(2*Nw+1)*hamming(2*Nw+1)';
Win=Win/sum(Win(:));

C1=CObj.^2;
M1=CMesh.^2;

CCObj=imfilter(C1,Win,Padd,Filt,outsize);
CCM=imfilter(M1,Win,Padd,Filt,outsize);

% CCObj=conv2(C1,flip(flip(Win,1),2),'same');
% CCM=conv2(M1,flip(flip(Win,1),2),'same');

imin=40;
imax=2008;
jmin=40;
jmax=2008;

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

        
        % testfit
        % [X, Y] = meshgrid(1:size(D1,2), 1:size(D1,1));
        % fit_model = fit([X(:) Y(:)], D1(:), 'poly44');
        % plot(fit_model, [X(:) Y(:)], D1(:))
        % D=[fit_model(X,Y)];

        [a2,G] = min(D(:));
        [r2,c2] = ind2sub(size(D),G);

        Dx=r2; Dy=c2;

Dxp1=Dx+1;
Dxm1=Dx-1;
Dyp1=Dy+1;
Dym1=Dy-1;

if Dxm1<1
    Dxm1=Dx;
end
if Dym1<1
    Dym1=Dy;
end
if Dxp1>size(D,2)
    Dxp1=Dx;
end
if Dyp1>size(D,2)
    Dyp1=Dy;
end
% 
% if Dxm1<1
%     Dxm1=Dx;
% else 
%     Dxminus=D(Dy,Dxm1);
% 
% end
% if Dym1<1
%     Dym1=Dy;
% else
%     Dyminus=D(Dym1,Dx);
% end
% 
% if Dxp1>size(D,2)
%     Dxp1=Dx;
% else
%     Dxplus=D(Dy,Dxp1);
% end
% 
% if Dyp1>size(D,2)
%     Dyp1=Dy;
% 
% else
%     Dyplus=D(Dyp1,Dx);
% end
% 
% Dx0=D(Dy,Dx);
% Dy0=D(Dy,Dx);

        
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

D2a=PoiSolveSym(DPCx2+DPCy2,CorrParam.window,regparam,'a');
D2s=PoiSolveSym(DPCx2+DPCy2,CorrParam.window,regparam,'s');
D2n=PoiSolveSym(DPCx2+DPCy2,CorrParam.window,regparam,'n');
FCsDPC1=FrankotChellapa(DPCy,DPCx,CorrParam.window,regparam,'s');
FCsDPC2=FrankotChellapa(DPCy2,DPCx2,CorrParam.window,regparam,'s');
FCsgrad=FrankotChellapa(Gy,Gx,CorrParam.window,regparam,'a');

figure; imagesc(ATT3); colormap gray; axis image
figure; imagesc(DPCx); colormap gray; axis image
figure; imagesc(DPCy); colormap gray; axis image
figure; imagesc(DPCx2); colormap gray; axis image
figure; imagesc(DPCy2); colormap gray; axis image
figure; imagesc(FCsDPC1); colormap gray; axis image
figure; imagesc(FCsDPC2); colormap gray; axis image
figure; imagesc(MD); colormap gray; axis image
figure; imagesc(D2a); colormap gray; axis image
figure; imagesc(D2n); colormap gray; axis image
figure; imagesc(D2s); colormap gray; axis image

function [Dx,Dy] = subpixpeak(z)
%SUBPIXPEAK computes a 2D quadratic surface fit to a 3x3 neighborhood
%   centered on the peak of the cross-correlation. 
%   z is the 3x3 matrix of values of the cross correlation
%   [Dx,Dy] are the relative positions of the fitted peak compared to the
%   central coordinate of the 3x3 matrix
X=[-1,0,1;-1,0,1;-1,0,1]; %Set up coordinates for X
Y=X';                    % "                  "  Y

%Solve a*x^2+b*x+c*x*y+d*y^2+e*y+f=z for all 9 points
%x^2,x,xy,y^2,y values for the 9 points are arranged as columns of A with
%1s in the last column
%then z(:)=A*b represents our data, where B is a vector of [a,b,c,d,e,f]
%So Z\A=B solves the coefficients
A=[X(:).^2,X(:),X(:).*Y(:),Y(:).^2,Y(:),ones(length(Y(:)),1)];
b=z(:)\A;

denom=(b(3)^2-4*b(1)*b(4));
Dx=(2*b(2)*b(4)-b(3)*b(5))/denom;
Dy=(2*b(1)*b(5)-b(2)*b(3))/denom;
%To do: 
% 1) Differentiate analytically to find expression for critical points
%   in x and y to compute sub-pixel coord
% 2) Then calculate determinant to verify that this is a maximum vs min vs
%   saddle

end