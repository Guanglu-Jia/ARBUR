function ARBUR_USV_spectro_visual(seg,time_resolution)

% Description:
% ---------
% Visualizing spectrograms within each clusters
%
% Inputs: 
% ---------
% seg : a struct containing the in-process variables
% time_resolution : temporal resolution of the USV spectrograms
%
% Outputs: 
% ----------
% 50 figures, each containing a spectrogram
% ----------
% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.



% Present the spectrograms in a single figure;
% 10 clusters;
% 5 spectrograms for each cluster
f = figure;
f.Color = [1 1 1];
% f.InnerPosition  = [882    60   765   926];
% cluster_num_all = max(seg.L_1_to_5);
% clusters to be visualized;
cluster_num_all = 10; 
% Number of spectrograms shown in each cluster
num_in_cluster = 5;
% The start of the first cluster
num_start = 0;

% Search for the indices for each cluster
% stored in num_plot
num_plot = zeros(cluster_num_all,num_in_cluster);
for i = 1:cluster_num_all
    j = i+num_start;
%     j = ind_resort(i+num_start);
    ind_temp = seg.features_ind_1_to_5(find(seg.L_1_to_5 == j));
    num_plot(i,1:num_in_cluster) = ind_temp(1:num_in_cluster);
end

% for i = 1:length(seg.duration)-1
%     num = seg.ind_resort(i);
%     if ~isempty(seg.BW3{num,1})
%         seg.time_min(num,1) = (min(seg.BW3{num,1}{1}(:,2))+1)*time_resolution;
%     end
% end




x_gap = 0.005;
y_gap = 0.01;
count = 0;
% Plot
for i = 1:cluster_num_all
   for j = 1:num_in_cluster
       
       hold on;
       count = count+1;
       ax(count) = subplot(num_in_cluster,cluster_num_all,cluster_num_all*(j-1)+i);

       colormap jet;
       seg.data_processed{num_plot(i,j)}=medfilt2(seg.data{num_plot(i,j)},[3,5]);
%        seg.data_processed{num_plot(i,j)}((seg.data_processed{num_plot(i,j)}<10)) = 0;
       seg.data_processed{num_plot(i,j)}= medfilt2(seg.data_processed{num_plot(i,j)},[3,5]);
       seg.data_processed{num_plot(i,j)} = seg.data_processed{num_plot(i,j)}(:,seg.time_min(num_plot(i,j))/time_resolution-2:(seg.duration(num_plot(i,j))*2+seg.time_min(num_plot(i,j))/time_resolution+2));
%        seg.data_processed{num_plot(i,j)} = seg.data_processed{num_plot(i,j)}(:,20:end-20);
%        temp = seg.data_processed{num_plot(i,j)}(double(seg.freq_min(num_plot(i,j)))*2-double(seg.freq_range(num_plot(i,j)))*2-5:double(seg.freq_min(num_plot(i,j)))*2+15,:);
        temp = seg.data_processed{num_plot(i,j)};%(round(256-seg.freq_min(num_plot(i,j))*2-seg.freq_range(num_plot(i,j))*2)-5:round(256-seg.freq_min(num_plot(i,j))*2)+5,:);
        
        % 22kHz
%         temp = seg.data_processed{num_plot(i,j)}(256-40*2.14:end,:);
        % 50kHz non-step
%         temp = seg.data_processed{num_plot(i,j)}(round(256-seg.mean_freq(num_plot(i,j))*2.14)-7*2.14:round(256-seg.mean_freq(num_plot(i,j))*2.14)+13*2.14,:);
        temp = seg.data_processed{num_plot(i,j)}(round(256-seg.mean_freq(num_plot(i,j))*2.14)-15*2.14:round(256-seg.mean_freq(num_plot(i,j))*2.14)+25*2.14,:);
       imagesc(temp);
       axis off
%        
       width_ = size(temp,2);
       height_ = size(temp,1);
       tt = text((4/100*width_),(15/100*height_),string(i+num_start),'horiz','left','color','w','fontsize',12);
       tt2 = text((96/100*width_),(85/100*height_),string(width_/2)+" ms",'horiz','right','color','w','fontsize',12);   
   end
end

% Adjust the position of the subplots
count = 0;
for i = 1:cluster_num_all
    for j = 1:num_in_cluster
         count = count+1;
               ax(count).Position = [(i-1)/cluster_num_all+x_gap/2, ((num_in_cluster-j))/num_in_cluster+y_gap/2, ...
           1/cluster_num_all-x_gap, 1/num_in_cluster-y_gap ];
    end
end
% f.InnerPosition = [1064         403        1009         539];
end