close all
clear
clc
%%
Off=double(imread('Offset.tif')); %Load offset
Gain=double(imread('Gain.tif')); %Load gain
Offclean=simpleclean(Off); %Clean up offset
Gain=simpleclean(Gain); %Clean up gain

angs=0:1:179; %Angles of projections
numfiles=length(angs); %files = % of angle projections

%Slice through the y_ind slice of each image
xcent=940; %Axis of rotation pixel
xwidth=700; %Width of images to process about axis
xmin=xcent-xwidth;
xmax=xcent+xwidth;
D=zeros(size(Gain,1),length(xmin:xmax),numfiles); %Preallocate sinogram matrix


%Maybe a better way to do this is to create sinograms all at once for all
%slices and save them to files, then separately load them and produce CT.
%That way we can load all images once for sinogram production rather than
%loading them a new time for each slice.

for i=1:numfiles
    tic;
    namei=num2str(angs(i));
    Obj=simpleclean(double(imread(strcat('image_',namei,'.tif'))));
    Obj=(Obj-Off)./(Gain-Off); %Gain and offset correct
    Objc=-log(Obj(:,xmin:xmax)); %Convert to projected attenuation
    D(:,:,i)=Objc; %Create the sinogram matrix
    toc;
    i;
end
%figure; imshow(D,[],angs)
%%
%Do CT on slices
s1=iradon(squeeze(D(1,:,:)),angs); %do 1 iradon to figure out size of slice
slice=zeros(size(s1,1),size(s1,2),1); %Preallocate stack of slices
slice(:,:,1)=s1;

if size(D,1)>1

for j=2:size(D,1)
    tic;
    slice(:,:,j)=iradon(squeeze(D(j,:,:)),angs); %do 1 iradon to figure out size of slice
    toc;
    disp(strcat('Slice ',int2str(j),' of ',int2str(size(D,1))))
end

end

%%
for j=900:1:2048
imagesc(slice(:,:,j));colormap gray;drawnow;
end
%%
%slice is now a 3D volume of attenuation coefficient (basically an
%absorption map).  You can plot it in different ways.

% c=slice(floor(500),:,:);
% figure(1);imagesc(squeeze(c)');axis image; colormap gray;title('vertical slice')
% figure(2);imagesc(slice(:,:,1500));axis image; colormap gray;title('horizontal slice')


%%
function out=simpleclean(in)
Sc=in;
mask=abs(Sc-mean(Sc(:)))>3.*std(Sc(:));
Med=medfilt2(Sc,[6 6]);
Sc(mask)=Med(mask);
mask=isinf(Sc);
Sc(mask)=Med(mask);
mask=isnan(Sc);
Sc(mask)=Med(mask);
out=Sc;
end
