function Dissimilarity_analysis_50(seg)

% Description:
% ---------
% Analyze the clustering results of 50-kHz USVs by using inter-cluster distance and intra-cluster variance
%
% Inputs: 
% ---------
% seg : a struct containing the in-process variables
%
% Outputs: 
% ----------
% Figure : inter-cluster distance and intra-cluster variance for clusters 1-60;
% Figure : inter-cluster distance matrix;
% Figure : intra-cluster variance matrix
% ----------
% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.


cluster_num_all = max(seg.L_1_to_5)-5;
cluster_num_all = 60;
Dissimilar_matrix = -0.1*ones(cluster_num_all,cluster_num_all);


seg_analy = struct();
cluster_start = 0;
for cluster_num_i = 1:cluster_num_all
%     features_temp = seg.features(seg.features_ind_1_to_5(seg.L_1_to_5 == cluster_num_i));
    cluster_num_j = cluster_num_i+cluster_start;
    features_temp = seg.features_mean_sub(seg.features_ind_1_to_5(seg.L_1_to_5 == cluster_num_j));    
    features_temp = cell2mat(features_temp');
    seg_analy.cluster_features_mean{cluster_num_i,1} = mean(features_temp,1);
    seg_analy.cluster_features_sem{cluster_num_i,1} = sqrt(sum((features_temp-mean(features_temp,1)).^2,1)/size(features_temp,1));
end



for i = 1:cluster_num_all
    for j = 1:cluster_num_all
        Dissimilar_matrix(i,j) = norm(seg_analy.cluster_features_mean{i}-seg_analy.cluster_features_mean{j});
    
    end
end

Dissimilar_matrix = Dissimilar_matrix';
% 
% 
% f = figure;
% f.Color = [1 1 1];
% % a = colormap(jet);
% % a = [0.7 0.7 0.7;a; ];
% % colormap(a)
% colormap jet
% imagesc(Dissimilar_matrix);
% colorbar
% 
% title("Inter-cluster distance");
% xlabel("Cluster types",'FontSize',10);
% ylabel("Cluster types",'FontSize',10);

% Dissimilar_vec_inter = sum(Dissimilar_matrix)/(cluster_num_all-1);


for i = 1:cluster_num_all
        if i<=10
            Dissimilar_vec_inter(i) = sum(Dissimilar_matrix(1:10,i))/9;
        elseif i<=35
            Dissimilar_vec_inter(i) = sum(Dissimilar_matrix(11:35,i))/24;
        elseif i<=45
            Dissimilar_vec_inter(i) = sum(Dissimilar_matrix(36:45,i))/9;
        else
            Dissimilar_vec_inter(i) = sum(Dissimilar_matrix(46:60,i))/14;
        end
    
end

% f = figure;
% f.Color = [1 1 1];
% scatter(1:length(Dissimilar_vec_inter),Dissimilar_vec_inter);
% hold on;
% scatter(1:length(seg_analy.cluster_features_sem),mean(cell2mat(seg_analy.cluster_features_sem),2));

Dissimilar_vec_intra = mean(cell2mat(seg_analy.cluster_features_sem),2);



Dissimilar_mat_inter = zeros(length(Dissimilar_matrix),length(Dissimilar_matrix)-1);
for i = 1:size(Dissimilar_matrix,2)
    Dissimilar_mat_inter(i,:) = Dissimilar_matrix(i,Dissimilar_matrix(i,:)~=0);
end

% f = figure;
% f.Color = [1 1 1];
% hold on;
% 
% for i = 1:cluster_num_all
% %     signal_num_all{i} = sum((seg.L_1_to_5==i));
% %     duration_mean(i) = mean(signal_num_all{i});
% %     scatter(0.75+rand(length(signal_num_all{i}),1)/2+i-1,signal_num_all{i},'.','k');
% %     plot([0.7 1.3]+i-1,[signal_num_all{i} signal_num_all{i}],'r','LineWidth',1);
% 
%     fill([0.7 1.3 1.3 0.7]+i-1,[0 0 Dissimilar_vec_inter(i) Dissimilar_vec_inter(i)],[0 0 0]);
%     sc = scatter(0.75+rand(size(Dissimilar_mat_inter,2),1)/2+i-1,Dissimilar_mat_inter(i,:),10,'o','k');
%     sc.MarkerEdgeColor = 'k';
%     sc.MarkerFaceColor = [1 1 1];
%     plot([0.7 1.3]+i-1,[Dissimilar_vec_intra(i) Dissimilar_vec_intra(i)],'r','LineWidth',1);    
% end
% 
% ax = gca;
% ax.FontSize = 15;
% ax.TickDir = 'out';
% % ax.XTick = 1:cluster_num_all;
% % ax.XTickLabel = string((cluster_start+1:cluster_start+cluster_num_all));
% 
% ax.LabelFontSizeMultiplier = 1.5;
% title("Inter-cluster distance and intra-cluster variance");
% % xlabel("Cluster types",'FontSize',20);
% ylabel("Inter-cluster distance",'FontSize',10);
% % axis([0 61 0 200]);
% % f.InnerPosition = [403         532        1447         446];
% 
% 
% % 
% f = figure;
% f.Color = [1 1 1];
% plot(1:length(Dissimilar_vec_inter),Dissimilar_vec_inter);
% hold on;
% scatter(1:length(seg_analy.cluster_features_sem),mean(cell2mat(seg_analy.cluster_features_sem),2),'.');
% for i = 1:cluster_num_all
%     plot([0.6 1.4]+i-1,[Dissimilar_vec_intra(i) Dissimilar_vec_intra(i)],'r','LineWidth',1);   
% end
% box off
% 
% % 
% f = figure;
% f.Color = [1 1 1];
% hold on;
% colormap jet;
% cm = colormap;
% for i = 1:60
%     fi1 = fill([0.5 1.5 1.5 0.5]+i-1,[0 0 Dissimilar_vec_inter(i) Dissimilar_vec_inter(i)],cm(round(i/2),:));
%     set(fi1,'facealpha',0.5,'edgealpha',0.0);
%     plot([0.5 1.5]+i-1,[Dissimilar_vec_intra(i) Dissimilar_vec_intra(i)],'k','LineWidth',1);   
%     fi2 = fill([0.5 1.5 1.5 0.5]+i-1,[0 0 Dissimilar_vec_intra(i) Dissimilar_vec_intra(i)],cm(round(i/2),:));
%     set(fi2,'facealpha',0.8,'edgealpha',0.0);
% end
% axis([0 61 0 max(Dissimilar_vec_inter)+10]);
% box on


f = figure;
f.Color = [1 1 1];
hold on;
colormap hsv;
% f.InnerPosition = [231         558        1152         420];
cm = colormap(jet);
for i = 1:60
%     signal_num_all{i} = sum((seg.L_1_to_5==i));
%     duration_mean(i) = mean(signal_num_all{i});
%     scatter(0.75+rand(length(signal_num_all{i}),1)/2+i-1,signal_num_all{i},'.','k');
%     plot([0.7 1.3]+i-1,[signal_num_all{i} signal_num_all{i}],'r','LineWidth',1);
    if i<=10
        fi1 = fill([0.6 1.4 1.4 0.6]+i-1,[0 0 Dissimilar_vec_inter(i) Dissimilar_vec_inter(i)],cm(round(i*1),:));
        set(fi1,'facealpha',0.5,'edgealpha',1);
        sc = scatter(0.75+rand(9,1)/2+i-1,Dissimilar_mat_inter(i,1:9),7,'o','k');
        sc.MarkerEdgeColor = 'k';
        sc.MarkerFaceColor = [1 1 1];
        fi2 = fill([0.6 1.4 1.4 0.6]+i-1,[0 0 Dissimilar_vec_intra(i) Dissimilar_vec_intra(i)],cm(round(i*1),:));
        set(fi2,'facealpha',0.5,'edgealpha',1);
    elseif i<=35
        fi1 = fill([0.6 1.4 1.4 0.6]+i-1,[0 0 Dissimilar_vec_inter(i) Dissimilar_vec_inter(i)],cm(round(i*1),:));
        set(fi1,'facealpha',0.5,'edgealpha',1);
        sc = scatter(0.75+rand(24,1)/2+i-1,Dissimilar_mat_inter(i,(1:24)+10),7,'o','k');
        sc.MarkerEdgeColor = 'k';
        sc.MarkerFaceColor = [1 1 1];
        fi2 = fill([0.6 1.4 1.4 0.6]+i-1,[0 0 Dissimilar_vec_intra(i) Dissimilar_vec_intra(i)],cm(round(i*1),:));
        set(fi2,'facealpha',0.5,'edgealpha',1);    
    elseif i<=45
        fi1 = fill([0.6 1.4 1.4 0.6]+i-1,[0 0 Dissimilar_vec_inter(i) Dissimilar_vec_inter(i)],cm(round(i*1),:));
        set(fi1,'facealpha',0.5,'edgealpha',1);
        sc = scatter(0.75+rand(9,1)/2+i-1,Dissimilar_mat_inter(i,(1:9)+35),7,'o','k');
        sc.MarkerEdgeColor = 'k';
        sc.MarkerFaceColor = [1 1 1];
        fi2 = fill([0.6 1.4 1.4 0.6]+i-1,[0 0 Dissimilar_vec_intra(i) Dissimilar_vec_intra(i)],cm(round(i*1),:));
        set(fi2,'facealpha',0.5,'edgealpha',1);    
    else
        fi1 = fill([0.6 1.4 1.4 0.6]+i-1,[0 0 Dissimilar_vec_inter(i) Dissimilar_vec_inter(i)],cm(round(i*1),:));
        set(fi1,'facealpha',0.5,'edgealpha',1);
        sc = scatter(0.75+rand(14,1)/2+i-1,Dissimilar_mat_inter(i,(1:14)+45),7,'o','k');
        sc.MarkerEdgeColor = 'k';
        sc.MarkerFaceColor = [1 1 1];
        fi2 = fill([0.6 1.4 1.4 0.6]+i-1,[0 0 Dissimilar_vec_intra(i) Dissimilar_vec_intra(i)],cm(round(i*1),:));
        set(fi2,'facealpha',0.5,'edgealpha',1);    
    end
%     fi1 = fill([0.6 1.4 1.4 0.6]+i-1,[0 0 Dissimilar_vec_inter(i) Dissimilar_vec_inter(i)],cm(round(i*1),:));
%     set(fi1,'facealpha',0.5,'edgealpha',1);
%     sc = scatter(0.75+rand(size(Dissimilar_mat_inter,2),1)/2+i-1,Dissimilar_mat_inter(i,:),7,'o','k');
%     sc.MarkerEdgeColor = 'k';
%     sc.MarkerFaceColor = [1 1 1];
% %     plot([0.7 1.3]+i-1,[Dissimilar_vec_intra(i) Dissimilar_vec_intra(i)],'k','LineWidth',1);  
%     fi2 = fill([0.6 1.4 1.4 0.6]+i-1,[0 0 Dissimilar_vec_intra(i) Dissimilar_vec_intra(i)],cm(round(i*1),:));
%     set(fi2,'facealpha',0.5,'edgealpha',1);
end
axis([0 61 0 max(max(Dissimilar_mat_inter))+10]);
xlabel("Cluster types",'FontSize',10);
title("Inter-cluster distance and intra-cluster variance",'FontSize',10);
ax = gca;
ax.TickDir = 'out';


f = figure();
f.Color = [1 1 1];
% f.InnerPosition = [680   558   508   420];
colormap jet;
imagesc(Dissimilar_matrix);
cb = colorbar;

title("Inter-cluster distance");
xlabel("Cluster types",'FontSize',10);
ylabel("Cluster types",'FontSize',10);


f = figure();
f.Color = [1 1 1];
% f.InnerPosition = [680   558   508   420];
colormap jet;
imagesc(diag(Dissimilar_vec_intra));
cb = colorbar;
title("Intra-cluster variance");
xlabel("Cluster types",'FontSize',10);
ylabel("Cluster types",'FontSize',10);

end