% Main script for USVs cluster 
%
% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.
%% import data
clear;
clc;
% Initialization
flag_colum_num = 257;
freq_max_num = 256; % 
freq_recording_range = 125; % kHz
freq_resolution = freq_recording_range/freq_max_num;
time_resolution = 0.5; % Temporal resolution of the spectrogram: 0.5 ms

load('DemoData\USV\demo_ARBUR_USV_data.mat');
USV_num = length(seg.data);

%% Feature construction
seg = ARBUR_USV_feature_construction(seg,freq_resolution,time_resolution,freq_max_num);
disp("Number of USVs with two rats vocalizing simultaneously: "+sum(seg.double_rats));

%%  Drawing heatmap
%   Mean frequency vs. duration 
sigma = 0.022; 
ARBUR_USV_heatmap(seg,sigma,time_resolution);
cluster_num = 2;
%% Coarse clustering
seg = coarse_clustering(seg,cluster_num);

%% Fine clustering for 50-kHz USVs
% cluster numbers for non-step/step low-frequency 50-kHz USVs and non-step/step high-frequency 50-kHz USVs
cluster_num_vec = [10,25,10,15]; 
seg = fine_clustering_50(seg,cluster_num_vec);
%% Feature construction for 22-kHz USVs
seg = feature_construction_22(seg,freq_resolution,time_resolution,freq_max_num);

%% Fine clustering for 22-kHz USVs
% cluster number for 22-kHz USVs
cluster_num_22 = 5; 
seg = fine_clustering_22(seg,cluster_num_22);
%% Combining clustering results
% 5 groups,65 subgroups(clusters)
seg.L{1} = seg.L1;
seg.L{2} = max(seg.L{1})+seg.L2;
seg.L{3} = max(seg.L{2})+seg.L3;
seg.L{4} = max(seg.L{3})+seg.L4;
seg.L{5} = max(seg.L{4})+seg.L5;
% Cluster number vector
seg.L_1_to_5 = [seg.L{1},seg.L{2},seg.L{3},seg.L{4},seg.L{5}];
seg.L_1_to_5_backup = seg.L_1_to_5;
% Cluster index vector
seg.features_ind_1_to_5 = [seg.features_ind_1_to_4, seg.features_ind_5];

%% Sorting clustering results
% Sorting clusters according to slope (group A-d) and duration (group E) within each group.
seg = ARBUR_USV_sorting(seg);
seg.cluster = zeros(1,USV_num);
seg.cluster(seg.features_ind_1_to_5) = seg.L_1_to_5;

%% Quantification of the clustering results
% Duration, frequency range, mean frequency, USV numbers, frequency
% range/duration within each cluster
ARBUR_USV_quant(seg);

%% Visualize the clustering results
ARBUR_USV_spectro_visual(seg,time_resolution);

%% Compare inter-cluster distances with intra-cluster variance
% clusters 1-60
Dissimilarity_analysis_50(seg);
% clusters 61-65
Dissimilarity_analysis_22(seg);
%% Only visualizing the spectrograms in the same group
group_num = 1; % low-frequency non-step 50-kHz USVs;
% spectrogram_visual_group(seg,group_num,freq_resolution,freq_max_num);
%% Output images
% num = length(seg.data);
% num = 10;
% USV_Output_images(seg,num);