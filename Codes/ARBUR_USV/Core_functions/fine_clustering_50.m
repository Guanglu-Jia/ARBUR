function seg = fine_clustering_50(seg,cluster_num_vec)

% Description:
% ---------
% Fine clustering for 50-kHz USVs
% 
%
% Inputs: 
% ---------
% seg : a struct containing the in-process variables
% cluster_num_vec: cluster numbers for non-step/step low-frequency 50-kHz USVs 
% and non-step/step high-frequency 50-kHz USVs
%
% Outputs: 
% ----------
% seg : a struct containing the in-process variables
% ----------
% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.



count = 0;
seg.features_ind_1 = [];
seg.features_good_1 = [];
for i = seg.ind_LF_50_kHz'
    if ~isempty(seg.features_mean_sub{i}) && seg.contour_num(i) ==1 && seg.duration(i)>5 && seg.double_rats(i) ==0
    count = count+1;
    seg.features_ind_1(count) = i;
    seg.features_good_1(count,:) = seg.features_mean_sub{i};
%    ~isempty(seg.features{8})
    end
end
% a = unique(seg.features);

G1 = kmean(seg.features_good_1', cluster_num_vec(1));
% G0 = kmean(Poses(:,1:3000), 30);
% G0 = kmean(reduction', 30);
L1 = G2L(G1);

% 第二大类：50 kHz，不连续
count = 0;
seg.features_ind_2 = [];
seg.features_good_2 = [];
for i = seg.ind_LF_50_kHz'
    if ~isempty(seg.features_mean_sub{i}) && seg.contour_num(i) >1 && seg.duration(i)>5 && seg.double_rats(i) ==0
    count = count+1;
    seg.features_ind_2(count) = i;
    seg.features_good_2(count,:) = seg.features_mean_sub{i};
%    ~isempty(seg.features{8})
    end
end
% a = unique(seg.features);

G2 = kmean(seg.features_good_2', cluster_num_vec(2));
% G0 = kmean(Poses(:,1:3000), 30);
% G0 = kmean(reduction', 30);
L2 = G2L(G2);

% 第三大类：65 kHz，连续
% 聚类前的预处理，选择用于聚类的信号，保存在 seg.features_good 里，将其索引保存在 seg.features_ind 里；
count = 0;
seg.features_ind_3 = [];
seg.features_good_3 = [];
for i = seg.ind_HF_50_kHz'
    if ~isempty(seg.features_mean_sub{i}) && seg.contour_num(i) ==1 && seg.duration(i)>5 && seg.double_rats(i) ==0
    count = count+1;
    seg.features_ind_3(count) = i;
    seg.features_good_3(count,:) = seg.features_mean_sub{i};
%    ~isempty(seg.features{8})
    end
end
% a = unique(seg.features);

G3 = kmean(seg.features_good_3', cluster_num_vec(3));
% G0 = kmean(Poses(:,1:3000), 30);
% G0 = kmean(reduction', 30);
L3 = G2L(G3);

% 第四大类：65 kHz，不连续
% 聚类前的预处理，选择用于聚类的信号，保存在 seg.features_good 里，将其索引保存在 seg.features_ind 里；
count = 0;
seg.features_ind_4 = [];
seg.features_good_4 = [];
for i = seg.ind_HF_50_kHz'
    if ~isempty(seg.features_mean_sub{i}) && seg.contour_num(i) >1 && seg.duration(i)>5 && seg.double_rats(i) ==0
    count = count+1;
    seg.features_ind_4(count) = i;
    seg.features_good_4(count,:) = seg.features_mean_sub{i};
%    ~isempty(seg.features{8})
    end
end
% a = unique(seg.features);

G4 = kmean(seg.features_good_4', cluster_num_vec(4));
% G0 = kmean(Poses(:,1:3000), 30);
% G0 = kmean(reduction', 30);
L4 = G2L(G4);

% 把四类聚类结果组合起来
seg.features_ind_1_to_4 = [seg.features_ind_1, seg.features_ind_2,seg.features_ind_3,seg.features_ind_4];
seg.L1 = L1;
seg.L2 = L2;
seg.L3 = L3;
seg.L4 = L4;
end

