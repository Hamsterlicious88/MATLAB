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
open(video); %open the file for writing
for i=1:length(angs) %where N is the number of images
    namei=num2str(angs(i));
    I = double(imread(strcat('image_',namei,'.tif'))); %read the next image
    writeVideo(video,mat2gray(I)); %write the image to file
end
close(video); %close the file