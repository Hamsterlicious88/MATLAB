clc; clear all; close all;
angs=0:1:179;
% reads in all of the images as individual cells so that it is not
% necessary to load process each file individually. Memory usage isn't
% terribly high, this was written on a system with only 8gb of ddr4lp mem.
%%
for i=1:length(angs)
    namei=num2str(angs(i));
    Obj{i}=double(imread(strcat('image_',namei,'.tif')));
end
%%
for i=1:length(Obj)
    figure; imagesc(Obj{i})
end

%%
video = VideoWriter('yourvideo.avi'); %create the video object
video.FrameRate=10; %sets the framerate of the video
open(video); %open the file for writing
for i=1:length(angs) %where N is the number of images
    namei=num2str(angs(i));
    I = double(imread(strcat('image_',namei,'.tif'))); %read the next image
    writeVideo(video,mat2gray(I)); %write the image to file
end
close(video); %close the file

%% 
%This section allows you to write colormap RGB images to video
video = VideoWriter('cellsnomask.avi'); %create the video object
video.FrameRate=10;
open(video); %open the file for writing
for i=1:length(iOPL) %where N is the number of images
    %namei=num2str(angs(i));
    %I = double(imread(strcat('image_',namei,'.tif'))); %read the next image
    f=rescale(iOPL{i,1});
    f=im2uint8(f);
    f=ind2rgb(f,hsv);
    drawnow
    %F(i)=getframe(gcf);
    writeVideo(video,f); %write the image to file
end
close(video); %close the file
%%
