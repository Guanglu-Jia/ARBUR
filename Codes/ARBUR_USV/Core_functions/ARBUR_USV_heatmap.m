function ARBUR_USV_heatmap(seg,sigma,time_resolution)

% Description:
% ---------
% Calculate and plot the heatmap of USVs according to 
% their duration and mean frequency of the longest contour	
%
% Inputs: 
% ---------
% seg : a struct containing the in-process variables
% sigma : kernel width for point density calculation
% time_resolution : temporal resolution of the USV spectrograms
%
% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.

x = randn(100,1);
y = randn(100,1);
freq_max = 125; % maximum frequency in the spectrogram


% Define the 2-dimensional feature for coarse clustering: 
% mean frequency and duration of the longest contour 
% Separate the signals with a threshold of 32 kHz
ind_duration_max_c = find(seg.duration_max_c>0 & seg.mean_freq'>32 ); 
% features_duration_max_c = [seg.duration_max_c(ind_duration_max_c),seg.mean_freq(ind_duration_max_c)'];
features_duration_max_c = [seg.duration_max_c(ind_duration_max_c)/max(seg.duration_max_c(ind_duration_max_c)),seg.mean_freq(ind_duration_max_c)'/125];
% sigma = .025;
numPoints_x = 3000; 
numPoints_y = 1250;
numPoints = [numPoints_x numPoints_y];
% features_duration_max_c = flipud(features_duration_max_c);
% rangeVals = [-1,max(max(features_duration_max_c(:)),-min(features_duration_max_c(:,1))) ];
% rangeVals = [-max(max(x(:)),-min(x(:,1))),max(max(x(:)),-min(x(:,1))) ];
% [xx,yy,density_map] = findPointDensity([x,y],sigma,numPoints,rangeVals);
rangeVals = [0,1 ];
[xx,yy,density_map] = findPointDensity(features_duration_max_c,sigma,numPoints,rangeVals);

f = figure;
f.Color = [1 1 1];
% default_cm = colormap;
% colormap jet
% c = colormap(hot);
% colormap(flip(c));
% colormap([.8 .8 .8;c]);
density_map = flipud(density_map);
density_map_temp = density_map;
time_end = 250/time_resolution;
freq_upper_lim = 350;
freq_lower_lim = 300;
imagesc(density_map_temp(350:end-300,1:time_end));
ax = gca;
ax.XTick = [];
ax.YTick = [];
% imagesc(density_map(1:numPoints_y*(100-32)/100,1:numPoints_x/2));
xlabel("Duration: 0-"+string(time_end*time_resolution)+" (ms)");
ylabel("Mean Freq: "+string(freq_lower_lim/numPoints_y*freq_max)+"-"+string(125-freq_upper_lim/numPoints_y*freq_max)+" (kHz)");

% figure
% surf(density_map_temp(350:3:end-300,1:3:time_end));

end