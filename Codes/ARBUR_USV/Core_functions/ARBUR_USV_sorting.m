function seg = ARBUR_USV_sorting(seg)

% Description:
% ---------
% Construct feature vectors according to their continuity (step or non-step)
% For step USVs, a maximum of four longest contours are considered
% The upper/lower boundaries of contours are normalized and mapped to (1-50)/(51-100) in the 100-feature vector
%
% Inputs: 
% ---------
% seg : a struct containing the in-process variables
% freq_resolution: frequency resolution of the USV spectrograms
% time_resolution : temporal resolution of the USV spectrograms
% freq_max : upper limit of the USV spectrograms
%
% Outputs: 
% ----------
% seg : a struct containing the in-process variables
% ----------
% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.

seg.L_1_to_5 = seg.L_1_to_5_backup;
% Constructe the mean and sem of the 100-feature vectors in each cluster for clusters 1-60
% Stored in seg_analy.cluster_features_mean and seg_analy.cluster_features_sem
seg_analy = struct();
for cluster_num_i = 1:60
    features_temp = seg.features_mean_sub(seg.features_ind_1_to_5(seg.L_1_to_5 == cluster_num_i));
    features_temp = cell2mat(features_temp');
    seg_analy.cluster_features_mean{cluster_num_i,1} = mean(features_temp,1);
    seg_analy.cluster_features_sem{cluster_num_i,1} = sqrt(sum((features_temp-mean(features_temp,1)).^2,1)/size(features_temp,1));
end

for cluster_num_i = 61:65
    i = cluster_num_i-60;
    ind_22k(i) = mean(seg.features_good_5(1,seg.L5  == i));
end


% Sorting the clusters according to slope (for clusters 1-60) and duration (for clusters 61-65)
% in descending order
ind_resort = ones(60,1);
slope_ = zeros(60,1);
for i = 1:60
   slope_(i) =  seg_analy.cluster_features_mean{i}(50)-seg_analy.cluster_features_mean{i}(1);
end
[a ind_temp] = sort(slope_(1:10),'descend');
% ind_resort(1:10) = ind_temp;
ind_resort(1:10) = ind_temp;
[a ind_temp] = sort(slope_(11:35),'descend');
ind_resort(11:35) = 10+ind_temp;
[a ind_temp] = sort(slope_(36:45),'descend');
ind_resort(36:45) = 35+ind_temp;
[a ind_temp] = sort(slope_(46:60),'descend');
ind_resort(46:60) = 45+ind_temp;
[a ind_temp] = sort(ind_22k','descend');
ind_resort(61:65) = 60+ind_temp;




% ind_resort(61:65) = [65,61,63,64,62];
for i = 1:length(seg.L_1_to_5_backup)

%     seg.L_1_to_5(i) = ind_resort(seg.L_1_to_5(i));
%     if seg.L_1_to_5(i)<=60
        seg.L_1_to_5(i) = find(ind_resort ==  seg.L_1_to_5(i));
%     else
%         seg.L_1_to_5(i) = ind_resort(seg.L_1_to_5(i));
%     end
end

% Calculate the features after sorting;
% stored in seg_analy.cluster_features_mean and seg_analy.cluster_features_sem 
seg_analy = struct();
for cluster_num_i = 1:60
    features_temp = seg.features_mean_sub(seg.features_ind_1_to_5(seg.L_1_to_5 == cluster_num_i));
    features_temp = cell2mat(features_temp');
    seg_analy.cluster_features_mean{cluster_num_i,1} = mean(features_temp,1);
    seg_analy.cluster_features_sem{cluster_num_i,1} = sqrt(sum((features_temp-mean(features_temp,1)).^2,1)/size(features_temp,1));
end

seg.ind_resort = ind_resort;
end