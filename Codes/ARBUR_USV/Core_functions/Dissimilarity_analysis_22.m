function Dissimilarity_analysis_22(seg)

% Description:
% ---------
% Analyze the clustering results of 22-kHz USVs by using inter-cluster distance and intra-cluster variance
%
% Inputs: 
% ---------
% seg : a struct containing the in-process variables
%
% Outputs: 
% ----------
% Figure : inter-cluster distance and intra-cluster variance for clusters 61-65;
% Figure : inter-cluster distance matrix;
% Figure : intra-cluster variance matrix
% ----------
% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.


cluster_num_all = max(seg.L5);
Dissimilar_matrix_22 = -0.1*ones(cluster_num_all,cluster_num_all);

% for cluster_num_i = 60+(1:cluster_num_all)
%     features_temp = seg.features(seg.features_ind_1_to_5(seg.L_1_to_5 == cluster_num_i));
%     features_temp = cell2mat(features_temp');
%     seg_analy.cluster_features_mean{cluster_num_i,1} = mean(features_temp,1);
%     seg_analy.cluster_features_sem{cluster_num_i,1} = sqrt(sum((features_temp-mean(features_temp,1)).^2,1)/size(features_temp,1));
% end

 for i = 1:cluster_num_all
     cluster_features{i} = seg.features_good_5(:,find(seg.L5 == i));  
     % Calculate mean and sem for each cluster
     cluster_mean{i}(:,1) = mean(cluster_features{i},2);
     cluster_sem{i}(:,1) = sqrt(sum((cluster_features{i}-cluster_mean{i}(:,1)).^2,2)/length(cluster_features{i}));
%      cluster_sem_uni{i}(:,1) = norm(cluster_sem{i}(:,1));
 end

Dissimilar_vec_intra = [];
for i = 1:cluster_num_all
    for j = 1:cluster_num_all
        Dissimilar_matrix_22(i,j) = norm(cluster_mean{i}-cluster_mean{j});
        
    end
    Dissimilar_vec_intra(i) = mean(cluster_sem{i});
end

Dissimilar_matrix_22 = Dissimilar_matrix_22';


f = figure;
f.Color = [1 1 1];
% f.InnerPosition = [1086         712         244         171];
% a = colormap(jet);
% a = [0.7 0.7 0.7;a; ];
% colormap(a)
colormap jet
imagesc(Dissimilar_matrix_22);
colorbar
ax = gca;
ax.XTickLabel = string(61:65);
ax.YTickLabel = string(61:65);

Dissimilar_vec_inter_22 = sum(Dissimilar_matrix_22)/(cluster_num_all-1);
Dissimilar_vec_intra_22 = [0.037015124517434,0.070822726138971,0.053792943500837,0.105755578052625,0.059258471049955];

% Dissimilar_matrix_22 -->> Dissimilar_mat_inter_22
for i = 1:5
    temp = Dissimilar_matrix_22(i,:);
    temp(i) = [];
    Dissimilar_mat_inter_22(i,:) = temp;
end


% Plot the intra-cluster variance matrix
f = figure;
f.Color = [1 1 1];
% f.InnerPosition = [1086         712         244         171];
colormap jet
imagesc(diag(Dissimilar_vec_intra));
colorbar
ax = gca;
ax.XTickLabel = string(61:65);
ax.YTickLabel = string(61:65);

%  Plot inter-cluster distance and intra-cluster variance
f = figure;
f.Color = [1 1 1];
hold on;
colormap hsv;
% f.InnerPosition = [1218         558         165         285];
cm = colormap(jet);
for i = 1:length(Dissimilar_vec_inter_22)
%     signal_num_all{i} = sum((seg.L_1_to_5==i));
%     duration_mean(i) = mean(signal_num_all{i});
%     scatter(0.75+rand(length(signal_num_all{i}),1)/2+i-1,signal_num_all{i},'.','k');
%     plot([0.7 1.3]+i-1,[signal_num_all{i} signal_num_all{i}],'r','LineWidth',1);
    fi1 = fill([0.6 1.4 1.4 0.6]+i-1,[0 0 Dissimilar_vec_inter_22(i) Dissimilar_vec_inter_22(i)],cm(round(64-i*1),:));
    set(fi1,'facealpha',0.5,'edgealpha',1);
    sc = scatter(0.75+rand(size(Dissimilar_mat_inter_22,2),1)/2+i-1,Dissimilar_mat_inter_22(i,:),7,'o','k');
    sc.MarkerEdgeColor = 'k';
    sc.MarkerFaceColor = [1 1 1];
%     plot([0.7 1.3]+i-1,[Dissimilar_vec_intra(i) Dissimilar_vec_intra(i)],'k','LineWidth',1);  
    fi2 = fill([0.6 1.4 1.4 0.6]+i-1,[0 0 Dissimilar_vec_intra_22(i) Dissimilar_vec_intra_22(i)],cm(round(64-i*1),:));
    set(fi2,'facealpha',0.5,'edgealpha',1);
end
% axis([0 6 0 max(max(Dissimilar_mat_inter_22))+10]);
xlabel("Cluster types",'FontSize',10);
ylabel("Inter-cluster distance",'FontSize',10);
ax = gca;
ax.TickDir = 'out';
ax.XTick = [1 5];
ax = gca;
ax.XTickLabel = string(61:65);
end