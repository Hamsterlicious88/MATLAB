clc; clear all; close all;
imag=double(importdata('image_49.tif'));
gain=double(importdata('Gain.tif'));
off=double(importdata('offset.tif'));
gi=gain-imag;
ig=imag-gain;
go=gain-off;
og=off-gain;
io=imag-off;
oi=off-imag;
oiog=oi./og;
ioog=io./og;
gigo=gi./go;
iggo=ig./go;
igth=imtophat(iggo,strel('disk',100));
gith=imtophat(gigo,strel('disk',100));
figure; imagesc(igth);colormap gray; axis image
figure; imagesc(gith);colormap gray; axis image
