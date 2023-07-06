function seg = coarse_clustering(seg,cluster_num)

% Description:
% ---------
% Coarse clustering of 50-kHz USVs into low-frequency and high-frequency ones
%
% Inputs: 
% ---------
% seg : a struct containing the in-process variables
% cluster_num : number of clusters 
%
% Outputs: 
% ----------
% seg : a struct containing the in-process variables
% ----------
% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.


% Define features
ind_duration_max_c = find(seg.duration_max_c>0 & seg.mean_freq'>32); 
features_duration_max_c = [seg.duration_max_c(ind_duration_max_c)/max(seg.duration_max_c(ind_duration_max_c)),(seg.mean_freq(ind_duration_max_c)'-32)/(max(seg.mean_freq(ind_duration_max_c)')-32)];
% Unsupervised learning using k-means
G0_max_c = kmean(features_duration_max_c',cluster_num);
L_max_c = G2L(G0_max_c);

% scatter(seg.duration_max_c(ind_duration_max_c(find(L_max_c==4))),seg.mean_freq(ind_duration_max_c(find(L_max_c==4))),'.');


% indices for all high-frequency 50-kHz USVs
% ind_duration_max_c((find(L_max_c==temp_ind_65_kHz)))
[~,temp_ind_HF_50_kHz]=max([mean(seg.mean_freq(ind_duration_max_c(find(L_max_c==1)))),mean(seg.mean_freq(ind_duration_max_c(find(L_max_c==2))))]);%,,mean(seg.mean_freq(ind_duration_max_c(find(L_max_c==3))))])%,...
    %mean(seg.mean_freq(ind_duration_max_c(find(L_max_c==4))))]);
seg.ind_HF_50_kHz = ind_duration_max_c((find(L_max_c==temp_ind_HF_50_kHz)));
temp_ind_50_kHz = find([1 2 ] ~= temp_ind_HF_50_kHz);
seg.ind_LF_50_kHz = ind_duration_max_c((find(L_max_c==temp_ind_50_kHz(1) )));%|L_max_c==temp_ind_50_kHz(2))));

f_max_c = figure;
f_max_c.Color = [1 1 1];
hold on;
ylabel("Mean Frequency (kHz)");
xlabel("Duration (ms)");
title("Max contour in all USVs");
scatter(seg.duration_max_c(ind_duration_max_c(find(L_max_c==temp_ind_50_kHz(1)))),seg.mean_freq(ind_duration_max_c(find(L_max_c==temp_ind_50_kHz(1)))),'.','MarkerEdgeColor',[153 101 191]/255);
% scatter(seg.duration_max_c(ind_duration_max_c(find(L_max_c==temp_ind_50_kHz(2)))),seg.mean_freq(ind_duration_max_c(find(L_max_c==temp_ind_50_kHz(2)))),'.','g');
% scatter(seg.duration_max_c(ind_duration_max_c(find(L_max_c==temp_ind_50_kHz(3)))),seg.mean_freq(ind_duration_max_c(find(L_max_c==temp_ind_50_kHz(3)))),'.','g');
scatter(seg.duration_max_c(ind_duration_max_c(find(L_max_c==temp_ind_HF_50_kHz))),seg.mean_freq(ind_duration_max_c(find(L_max_c==temp_ind_HF_50_kHz))),'.','MarkerEdgeColor',[0 203 198]/255);

seg.ind_32_kHz = find(seg.duration_max_c>0 &seg.mean_freq'<32);
end