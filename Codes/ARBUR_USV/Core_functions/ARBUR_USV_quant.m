function ARBUR_USV_quant(seg)

% Description:
% ---------
% Quantification of the clustering results
%
% Inputs: 
% ---------
% seg : a struct containing the in-process variables
%
% Outputs: 
% ----------
% Five figures: Duration, frequency range, mean frequency, USV numbers, frequency
% range/duration within each cluster
% ----------
% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.

cluster_num_all = max(seg.L_1_to_5);
f = figure;
f.Color = [1 1 1];
% colormap jet
% f.InnerPosition = [ 507          49        1150         947];

subplot(5,1,2);
hold on;
% xlabel("cluster type (AU)");
ylabel("Frequency range (kHz)");
freq_range_mean = zeros(cluster_num_all,1);
freq_range_all = [];

for i = 1:cluster_num_all
    freq_range_all{i} = seg.freq_range(seg.features_ind_1_to_5(find(seg.L_1_to_5==i)));
    freq_range_mean(i) = mean(freq_range_all{i});
    scatter(0.75+rand(length(freq_range_all{i}),1)/2+i-1,freq_range_all{i},'.','k');
    plot([0.7 1.3]+i-1,[freq_range_mean(i) freq_range_mean(i)],'r','LineWidth',1);
end
axis([0 70 0 50]);
subplot(5,1,1);
hold on;
% xlabel("cluster type (AU)");
ylabel("Duration (ms)");
duration_mean = zeros(cluster_num_all,1);
duration_all = [];

for i = 1:cluster_num_all
    duration_all{i} = seg.duration(seg.features_ind_1_to_5(find(seg.L_1_to_5==i)));
    duration_mean(i) = mean(duration_all{i});
    scatter(0.75+rand(length(duration_all{i}),1)/2+i-1,duration_all{i},'.','k');
    plot([0.7 1.3]+i-1,[duration_mean(i) duration_mean(i)],'r','LineWidth',1);
end
axis([0 70 0 300]);
subplot(5,1,3);
hold on;
% xlabel("cluster type (AU)");
ylabel("Mean frequency (kHz)");
mean_freq_mean = zeros(cluster_num_all,1);
mean_freq_all = [];

for i = 1:cluster_num_all
    mean_freq_all{i} = seg.mean_freq(seg.features_ind_1_to_5(find(seg.L_1_to_5==i)));
    mean_freq_mean(i) = mean(mean_freq_all{i});
    scatter(0.75+rand(length(mean_freq_all{i}),1)/2+i-1,mean_freq_all{i},'.','k');
    plot([0.7 1.3]+i-1,[mean_freq_mean(i) mean_freq_mean(i)],'r','LineWidth',1);
end
axis([0 70 0 100]);
subplot(5,1,4);
hold on;
% xlabel("cluster type (AU)");
ylabel("signals");
signal_num = zeros(cluster_num_all,1);
signal_num_all = [];

for i = 1:cluster_num_all
    signal_num_all{i} = sum((seg.L_1_to_5==i));
%     duration_mean(i) = mean(signal_num_all{i});
%     scatter(0.75+rand(length(signal_num_all{i}),1)/2+i-1,signal_num_all{i},'.','k');
%     plot([0.7 1.3]+i-1,[signal_num_all{i} signal_num_all{i}],'r','LineWidth',1);
    fill([0.7 1.3 1.3 0.7]+i-1,[0 0 signal_num_all{i} signal_num_all{i}],[0 0 0]);
end
subplot(5,1,5);
hold on;
xlabel("Cluster type");
ylabel("Frequency range / duration (kHz/ms)");
freq_range_mean = zeros(cluster_num_all,1);
freq_range_all = [];

for i = 1:cluster_num_all
    freq_range_all{i} = seg.freq_range(seg.features_ind_1_to_5(find(seg.L_1_to_5==i)))'./seg.duration(seg.features_ind_1_to_5(find(seg.L_1_to_5==i)));
    freq_range_mean(i) = mean(freq_range_all{i});
    scatter(0.75+rand(length(freq_range_all{i}),1)/2+i-1,freq_range_all{i},'.','k');
    plot([0.7 1.3]+i-1,[freq_range_mean(i) freq_range_mean(i)],'r','LineWidth',1);
end