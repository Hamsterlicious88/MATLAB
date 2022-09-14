close all
clear 
clc
%%

dirstr='8_15 vialB';
CLEAN=1; %Only need to clean once unless you change cropping or sigma of noise removal
FINDHARMONICS=1; 
DECONV=1;
VERBOSE=1;

%Cropping in if needed--used when cleaning up images
% Crop.hmin=101;
% Crop.hmax=1100;
% Crop.vmin=201;
% Crop.vmax=1200;
%If not, just initialize the min to 1 and it will take whole image
crop.hmin=1;
crop.vmin=1;

%Throws out pixels this many std dev or more from image mean when cleaning
%up
sig=3;

npix=8; %Number of pixel window to ignore around each harmonic when finding next maximal peak

%Geometry and source parameters
geo.Dso=75*10^4; %microns
geo.Dom=5*10^4;
geo.Dmd=35*10^4;

% For new camera
geo.dx=22;
geo.phalf=73;
source.FWHM=sqrt(160.^2+(73.3.*(geo.Dso+geo.Dom)./geo.Dmd).^2); %FWHM spot microns 

% %For old camera
% geo.dx=22;
% geo.phalf=7;
% uFWHM=7/1000; %lp/micron
% source.FWHM=2*sqrt(2*log(2)).*sqrt(150.^2/(8*log(2))+2*log(2)/(pi.^2*uFWHM.^2)); %FWHM spot microns 
%File names should be in the form:
%Mesh only image: Mesh.tif
%Obj+mesh image: Obj.tif
%Offset image should be   Offset*.tif
%Gain image should be     Gain*.tif
%If offset and gain absent, it just uses the raw grid and object images
        
%How much of a full harmonic width (half the way to the nearest harmonic)
%to use: 1=Bennet's normal processing, 2=Use all the way to the next
%harmonic, etc.
width_factor=1.0;
%Window function
w_func=@rectwin; %I think the filtering in filtered backprojection will handle windowing for us...

%How many pixels to crop into the image to avoid edge artifacts
cropin=25;
%This would define the cropping on the input images before we clean them up
%and process them
%Crop.hmin, Crop.hmax are min and max horizontal crop pixel numbers
%Crop.vmin, Crop.vmax are min and max vertical crop pixel numbers
%If undefined, crops from 1st pixel to end in either direction.
crop=struct(); %Need to declare this in case we want to use it later to crop the images we're cleaning up before processing them

%Fourier transform handles
F = @(x) fftshift(fft2(ifftshift(x)));
Ft= @(x) fftshift(ifft2(ifftshift(x)));

%%
%This will clean up the mesh and projection images,
%gain and offset correct them and save them to a "Processed" subdirectory
%with numbering so that the projection images can be read with a dir()
%command
%This expects the main folder to have only Mesh.tif, Offset.tif and
%Gain.tif and a subdirectory \Projections\ to have all the projection
%images in the format image_0.tif, image_1.tif, ... image_100.tif, ...
%as is output by the macro code

if CLEAN


    cleanup_images(dirstr,sig,crop);
end

%Find the grid harmonics or load them from a file if FINDHARMONICS=0
grid_harmonics=find_harmonics_auto(dirstr,npix,FINDHARMONICS);

 



%%
%Processing images and saving as projections of DPC, ABS, DF

load(strcat(dirstr,filesep,'Processed',filesep,'image_mesh.mat'));
%Deconvolve if deconvolving
if DECONV
    Ig=deconv_source(image_mesh,geo.Dso+geo.Dom,geo.Dmd,source.FWHM,geo.dx,eps);
else
    Ig=image_mesh;
end
clear image_mesh


fname_proj=dir(strcat(dirstr,filesep,'Processed',filesep,'image_*.mat'));
%Now start looping over projection images
for i=1:length(fname_proj)
    %Load the current projection
    load(strcat(fname_proj(i).folder,filesep,fname_proj(i).name))
    if DECONV
        Io=deconv_source(obj,geo.Dso+geo.Dom,geo.Dmd,source.FWHM,geo.dx,eps);
    else
        Io=obj;
    end
    clear Obj
    [IG,IO]=extract_harmonics(Io,Ig,grid_harmonics,width_factor,w_func);

    %Compute ABS and DPC images
    IO(:,:,1)=real(IO(:,:,1));
    IG(:,:,1)=real(IG(:,:,1));
    h=(IO./IG);
    h=h(1+cropin:end-cropin,1+cropin:end-cropin,:);
    ABS=real(h(:,:,1));
    hh=h./repmat(h(:,:,1),[1,1,size(h,3)]);
    DF=abs(real(1-(hh)));
    DF1=DF(:,:,2);
    DF2=DF(:,:,3);
    DPC=imag(hh);
    DPC1=DPC(:,:,2);
    DPC2=DPC(:,:,3);
    
    f_abs = strcat(dirstr,filesep,'Processed',filesep,'ABS',filesep,'ABS_',sprintf('%03d.mat',i-1));
    save(f_abs,'ABS')
    f_dpc1 = strcat(dirstr,filesep,'Processed',filesep,'DPC',filesep,'DPC1_',sprintf('%03d.mat',i-1));
    f_dpc2 = strcat(dirstr,filesep,'Processed',filesep,'DPC',filesep,'DPC2_',sprintf('%03d.mat',i-1));
    save(f_dpc1,'DPC1');
    save(f_dpc2,'DPC2');
    f_d2 = strcat(dirstr,filesep,'Processed',filesep,'DPC',filesep,'D2_',sprintf('%03d.mat',i-1));

    [D11,D12]=gradient(DPC1);
    [D21,D22]=gradient(DPC2);
    D2=D21+D22;

    f_df1 = strcat(dirstr,filesep,'Processed',filesep,'DF',filesep,'DF1_',sprintf('%03d.mat',i-1));
    f_df2 = strcat(dirstr,filesep,'Processed',filesep,'DF',filesep,'DF2_',sprintf('%03d.mat',i-1));
    save(f_df1,'DF1');
    save(f_df2,'DF2');  
    save(f_d2,'D2');

    if VERBOSE
        figure(1);
        subplot(3,2,1);imagesc(ABS);title('ABS');axis image;colormap gray;
        subplot(3,2,3);imagesc(DPC1);title('DPC1');axis image;colormap gray;
        subplot(3,2,4);imagesc(DPC2);title('DPC2');axis image;colormap gray;
        subplot(3,2,5);imagesc(DF1);title('DF1');axis image;colormap gray;
        subplot(3,2,6);imagesc(DF2);title('DF2');axis image;colormap gray;
        drawnow;
    end
    c=strcat('Processing projection',{' '},int2str(i-1),' for ABS, DPC and DF...');
    disp(c{1})
end

%%

% figure(1);
% imagesc(ABS); title(strcat('abs')); colormap gray;
% figure(2);
% imagesc(-DPC(:,:,2)); title(strcat('dpcv')); colormap gray; %caxis([-0.15,.15]);
% figure(3)
% imagesc(DPC(:,:,3)); title(strcat('dpch')); colormap gray; %caxis([-0.15,0.15]);

%%


