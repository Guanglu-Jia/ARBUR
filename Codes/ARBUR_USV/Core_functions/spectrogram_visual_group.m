function spectrogram_visual_group(seg,group_num,freq_resolution,freq_max_num)

% Description:
% ---------
% Construct feature vectors according to their continuity (step or non-step)
% For step USVs, a maximum of four longest contours are considered
% The upper/lower boundaries of contours are normalized and mapped to (1-50)/(51-100) in the 100-feature vector
%
% Inputs: 
% ---------
% seg : a struct containing the in-process variables
% group_num : one of the five groups output by coarse clustering
% freq_resolution: frequency resolution of the USV spectrograms
% freq_max_num : upper limit of the USV spectrograms
%
% Outputs: 
% ----------
% Figure : spectrograms of USVs in the group (group_num)
%
% ----------
% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.

f = figure;
f.Color = [1 1 1];
colormap jet
freq_resolution = freq_resolution/freq_max_num;


if group_num== 1
    ind_temp = seg.features_ind_1;
elseif group_num == 2
    ind_temp = seg.features_ind_2;
elseif group_num == 3
    ind_temp = seg.features_ind_3;
elseif group_num == 4
    ind_temp = seg.features_ind_4;
else
    ind_temp = seg.features_ind_5;
end

for num = 1:length(seg.data)
    if sum(num == ind_temp) && seg.double_rats(num)==0 %&& seg.duration_max_c(find(ind_duration_max_c==num))>100
        %num = find(ind_duration_max_c==num);
seg.data_processed{num}=medfilt2(seg.data{num},[3,5]);
% seg.data_processed{num}((seg.data_processed{num}<10)) = 0;
seg.data_processed{num}=medfilt2(seg.data_processed{num},[3,5]);
%     
imagesc(seg.data_processed{num},[0,max(max(seg.data_processed{num}))]);
title("Segmentation number: "+ num +"; Mean freq: " +seg.mean_freq(num)+";");
% xlabel("Time: "+ seg.time{num}(1,1) + " s: "+0+" - "+ ((seg.time{num}(end,1))-seg.time{num}(1,1))*1000+" ms" );
ylabel("USV fequency (KHz) ");
ax = gca;
ax.YTickLabel = round((100:-25:0)+freq_resolution*7);
colorbar
pause(1);
    end
end
end