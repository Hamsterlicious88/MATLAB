


crop  = 'D:/.research/Research/mesh_based/231027/test3/Projections/';
cropdir = dir(fullfile(crop,'*.tif'));
for k = 1:numel(cropdir)
    F = dir(fullfile(crop,cropdir(k).name));
    cropdir(k).data = imread(strcat(F.folder,'/',F.name));
end

%%

rect=[0,0,2048,1479]);
for i = 1:359
    
