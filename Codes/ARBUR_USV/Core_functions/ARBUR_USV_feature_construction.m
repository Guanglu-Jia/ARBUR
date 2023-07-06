function seg = ARBUR_USV_feature_construction(seg,freq_resolution,time_resolution,freq_max)

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



tic


USV_num = length(seg.data);

seg.features = [];
seg.features_mean_sub = [];
seg.mean_freq = [];




% threshold for acertaining whether two rats vocalize simultaneously
threshold_double_rats = 2; % ms；
seg.double_rats = zeros(USV_num,1);


seg.max_ind = zeros(1,USV_num);

% set to 0 for frequency below 32-kHz in the spectrogram；
seg.data_above_32 = seg.data;
for num = 1: USV_num
    seg.data_above_32{num}(round(256-30/freq_resolution):end,:) = 0;
end

for num = 1: USV_num

% seg.data_processed{num} = seg.data{num};

seg.data_processed{num}=medfilt2(seg.data{num},[3,5]);

seg.data_processed{num}((seg.data_processed{num}<10)) = 0;
seg.data_processed{num}=medfilt2(seg.data_processed{num},[3,5]);

% Nomalized in the time domain;
BW2 = bwperim(seg.data_processed{num});
BW3 = bwboundaries(seg.data_processed{num});

% Extract the boundary of countours
% sort the boundaries in time in ascending order
count_boundary = 0;
temp_BW3 = [];
temp_length = [];


% Maximum intensity within the countour
countour_max_intensity = 0;
for i = 1:length(BW3)
    countour_max_intensity = max(countour_max_intensity,max(max(seg.data_processed{num}(:,min(BW3{i}(:,2)):max(BW3{i}(:,2))))));
end

% Extract eligible contours
for i = 1:length(BW3)
    % length of countour >22
	% maximum intensity within contour > 15
	% maximum intensity within contour > half the maximum of the spectrogram
    if ((length(BW3{i})>=30 && max(max(seg.data_processed{num}(min(BW3{i}(:,1)):max(BW3{i}(:,1)),min(BW3{i}(:,2)):max(BW3{i}(:,2)))))>15) ||...
             (length(BW3{i})>=22 && max(max(seg.data_processed{num}(:,min(BW3{i}(:,2)):max(BW3{i}(:,2)))))>20)) && ...
             (max(max(seg.data_processed{num}(min(BW3{i}(:,1)):max(BW3{i}(:,1)),min(BW3{i}(:,2)):max(BW3{i}(:,2)))))>countour_max_intensity/2)
                          
       count_boundary = count_boundary+1;
       temp_BW3{count_boundary,1} = BW3{i};
       temp_length(count_boundary,1) = length(BW3{i});
    end
    
end

% Extract the four longest contours 
[~,ind_BW3] = sort(temp_length,'descend');
ind_BW3_1 = find(ind_BW3<5);
for i = 1:length(ind_BW3_1)
seg.BW3{num,1}{i,1} = temp_BW3{ind_BW3_1(i)};
end
% counter number of each USV
seg.contour_num(num,1) = length(ind_BW3_1);


BW4 = edge(seg.data_processed{num});


if seg.contour_num(num,1) > 0
    max_ind = 1;
for i = 2: length(seg.BW3{num,1})
    if length(seg.BW3{num,1}{i})>length(seg.BW3{num,1}{max_ind})
        max_ind = i;
    end
end

seg.max_ind(1,num) = max_ind;
end
% imagesc(BW2);
% plot(BW3{max_ind}(:,2),BW3{max_ind}(:,1));
% set(gca,'YDir','reverse')


if seg.contour_num(num,1) == 1 

    if ~isempty(seg.BW3{num,1}) ...
       ...%&& length(BW3{max_ind}) > 30  
       && (max(seg.BW3{num,1}{1}(:,2))-min(seg.BW3{num,1}{1}(:,2))+1)*time_resolution > 5 ... 
       && max(seg.BW3{num,1}{1}(:,1)) < freq_max-30/freq_resolution 

seg.duration_max_c(num,1) = (max(seg.BW3{num,1}{1}(:,2))-min(seg.BW3{num,1}{1}(:,2))+1)*time_resolution; 
seg.freq_range(num,1) = (max(seg.BW3{num,1}{1}(:,1))-min(seg.BW3{num,1}{1}(:,1)))*freq_resolution;

seg.time_min(num,1) = (min(seg.BW3{num,1}{1}(:,2))+1)*time_resolution;
seg.freq_min(num,1) = (freq_max-max(seg.BW3{num,1}{1}(:,1)))*freq_resolution;

seg.features{num} = zeros(1,100); 
temp_BW3{1}(:,2) = temp_BW3{1}(:,2)-min(temp_BW3{1}(:,2))+1;


vec_upper = temp_BW3{1}(1:min(find(max(temp_BW3{1}(:,2))==temp_BW3{1}(:,2))),:);
seg.duration(1,num) = (max(temp_BW3{1}(:,2))-min(temp_BW3{1}(:,2))+1)*time_resolution; % Duration
% Eliminate the repetitions；
[C,ind_unique,ic] = unique(vec_upper(:,2),'rows');
vec_upper = vec_upper(ind_unique,:);

vec_bottom = temp_BW3{1}(max(find(max(temp_BW3{1}(:,2))==temp_BW3{1}(:,2))):end-1,:);
if vec_bottom(end,2)>1
    vec_bottom(end+1,:) = vec_bottom(end,:); 
    vec_bottom(end,2) = 1;
end
[C,ind_unique,ic] = unique(vec_bottom(:,2),'rows');
vec_bottom = vec_bottom(ind_unique,:);



% figure;
% plot(vec_upper(:,2),vec_upper(:,1));
% hold on;
% plot(vec_bottom(:,2),vec_bottom(:,1));


seg.features{num}(1) = vec_upper(1,1);
seg.features{num}(50) = vec_upper(end,1);
for i = 2:50-1
    x = 1+(max(vec_upper(:,2))-1)/49*(i-1);
    seg.features{num}(i) = vec_upper(floor(x),1)+(vec_upper(ceil(x),1)-vec_upper(floor(x),1))*(x-floor(x));
    
    
end

seg.features{num}(51) = vec_bottom(1,1);
seg.features{num}(100) = vec_bottom(end,1);
for i = (2:50-1)
    x = 1+(max(vec_bottom(:,2))-1)/49*(i-1);
    seg.features{num}(i+50) = vec_bottom(floor(x),1)+(vec_bottom(ceil(x),1)-vec_bottom(floor(x),1))*(x-floor(x));
end

% seg.features_mean_sub{num}(1:50) = seg.features{num}(1:50)-mean(seg.features{num}(1:50));
% seg.features_mean_sub{num}((1:50)+50) = seg.features{num}((1:50)+50)-mean(seg.features{num}((1:50)+50));

seg.mean_freq(1,num) = (freq_max-mean(seg.features{num}(1:100)))*freq_resolution;
seg.features{num}(1:100) = (freq_max-seg.features{num}(1:100))*freq_resolution;
seg.features_mean_sub{num}(1:100) = seg.features{num}(1:100)-mean(seg.features{num}(1:100));

    end
elseif seg.contour_num(num,1)>1 
    
    
    min_freq = 0;
    for i = 1:length(seg.BW3{num,1})
        if max(seg.BW3{num,1}{i,1}(:,1))>min_freq
            min_freq = max(seg.BW3{num,1}{i,1}(:,1));
        end
    end
    
    
    max_freq_1 = 300;
    for i = 1:length(seg.BW3{num,1})
        if min(seg.BW3{num,1}{i,1}(:,1))< max_freq_1
            max_freq_1 = min(seg.BW3{num,1}{i,1}(:,1));
        end
    end    
    
    
    if min_freq  > freq_max-30/freq_resolution && ...
       max_freq_1  < freq_max-30/freq_resolution
            seg.double_rats(num,1) = 1; 
            seg.duration_max_c(num,1) = 0; 
    end
    
    
    seg.duration_max_c(num,1) = (max(seg.BW3{num,1}{max_ind}(:,2))-min(seg.BW3{num,1}{max_ind}(:,2))+1)*time_resolution; % 持续时间
    seg.freq_range(num,1) = (min_freq-max_freq_1)*freq_resolution;
    
    seg.time_min(num,1) = (min(seg.BW3{num,1}{1}(:,2))+1)*time_resolution;
    seg.freq_min(num,1) = (freq_max-min_freq)*freq_resolution;
    

    
    seg.features{num} = zeros(1,100); 
    vec_upper = []; 
    vec_bottom = [];
    
    
    for kk = 1:seg.contour_num(num,1)
         
%         BW3{max_ind}(:,2) = BW3{max_ind}(:,2)-min(BW3{max_ind}(:,2))+1;
        

        vec_upper{kk,1} = seg.BW3{num,1}{kk,1}(1:min(find(max(seg.BW3{num,1}{kk,1}(:,2))==seg.BW3{num,1}{kk,1}(:,2))),:);

        [C,ind_unique,ic] = unique(vec_upper{kk,1}(:,2),'rows');
        vec_upper{kk,1} = vec_upper{kk,1}(ind_unique,:);

        vec_bottom{kk,1} = seg.BW3{num,1}{kk,1}(max(find(max(seg.BW3{num,1}{kk,1}(:,2))==seg.BW3{num,1}{kk,1}(:,2))):end-1,:);
        if vec_bottom{kk,1}(end,2)> min(vec_upper{kk,1}(:,2))
            vec_bottom{kk,1}(end+1,:) = vec_bottom{kk,1}(end,:); 
            vec_bottom{kk,1}(end,2) = min(vec_upper{kk,1}(:,2));
        end
        [C,ind_unique,ic] = unique(vec_bottom{kk,1}(:,2),'rows');
        vec_bottom{kk,1} = vec_bottom{kk,1}(ind_unique,:);        
        
    end
    

    if seg.contour_num(num,1) == 2 
       
        if max(vec_upper{1}(:,2))-min(vec_upper{2}(:,2)) > threshold_double_rats/time_resolution
            seg.double_rats(num,1) = 1; 
            seg.duration_max_c(num,1) = 0;
        else
        vec_upper{2}(:,2) = vec_upper{2}(:,2)-min(vec_upper{2}(:,2))+1+max(vec_upper{1}(:,2));
        vec_upper_one = [vec_upper{1};vec_upper{2}];
        vec_bottom{2}(:,2) = vec_bottom{2}(:,2)-min(vec_bottom{2}(:,2))+1+max(vec_bottom{1}(:,2));
        vec_bottom_one = [vec_bottom{1};vec_bottom{2}];            
        end
        
    end
    
    if seg.contour_num(num,1) == 3
        
        if max(vec_upper{1}(:,2))-min(vec_upper{2}(:,2)) > threshold_double_rats/time_resolution || max(vec_upper{2}(:,2))-min(vec_upper{3}(:,2)) > threshold_double_rats/time_resolution
            seg.double_rats(num,1) = 1; 
            seg.duration_max_c(num,1) = 0;
        else
        vec_upper{2}(:,2) = vec_upper{2}(:,2)-min(vec_upper{2}(:,2))+1+max(vec_upper{1}(:,2));
        vec_upper{3}(:,2) = vec_upper{3}(:,2)-min(vec_upper{3}(:,2))+1+max(vec_upper{2}(:,2));
        vec_upper_one = [vec_upper{1};vec_upper{2};vec_upper{3}];
        vec_bottom{2}(:,2) = vec_bottom{2}(:,2)-min(vec_bottom{2}(:,2))+1+max(vec_bottom{1}(:,2));
        vec_bottom{3}(:,2) = vec_bottom{3}(:,2)-min(vec_bottom{3}(:,2))+1+max(vec_bottom{2}(:,2));
        vec_bottom_one = [vec_bottom{1};vec_bottom{2};vec_bottom{3}];   
        end
    end

    if seg.contour_num(num,1) == 4
        
        if max(vec_upper{1}(:,2))-min(vec_upper{2}(:,2)) > threshold_double_rats/time_resolution || max(vec_upper{2}(:,2))-min(vec_upper{3}(:,2)) > threshold_double_rats/time_resolution...
                || max(vec_upper{3}(:,2))-min(vec_upper{4}(:,2)) > threshold_double_rats/time_resolution
            seg.double_rats(num,1) = 1; 
            seg.duration_max_c(num,1) = 0;
        else
        vec_upper{2}(:,2) = vec_upper{2}(:,2)-min(vec_upper{2}(:,2))+1+max(vec_upper{1}(:,2));
        vec_upper{3}(:,2) = vec_upper{3}(:,2)-min(vec_upper{3}(:,2))+1+max(vec_upper{2}(:,2));
        vec_upper{4}(:,2) = vec_upper{4}(:,2)-min(vec_upper{4}(:,2))+1+max(vec_upper{3}(:,2));
        vec_upper_one = [vec_upper{1};vec_upper{2};vec_upper{3};vec_upper{4}];
        vec_bottom{2}(:,2) = vec_bottom{2}(:,2)-min(vec_bottom{2}(:,2))+1+max(vec_bottom{1}(:,2));
        vec_bottom{3}(:,2) = vec_bottom{3}(:,2)-min(vec_bottom{3}(:,2))+1+max(vec_bottom{2}(:,2));
        vec_bottom{4}(:,2) = vec_bottom{4}(:,2)-min(vec_bottom{4}(:,2))+1+max(vec_bottom{3}(:,2));
        vec_bottom_one = [vec_bottom{1};vec_bottom{2};vec_bottom{3};vec_bottom{4}];        
        end
    end
    
    if min_freq  < freq_max-30/freq_resolution && seg.double_rats(num,1) ~= 1 
        
        seg.duration(1,num) = (max(seg.BW3{num,1}{seg.contour_num(num,1),1}(:,2))-min(seg.BW3{num,1}{1,1}(:,2)))*time_resolution; % 持续时间
        
        
        vec_upper_one(:,2) = vec_upper_one(:,2)-min(vec_upper_one(:,2))+1;
        vec_bottom_one(:,2) = vec_bottom_one(:,2)-min(vec_bottom_one(:,2))+1;
        

        seg.features{num}(1) = vec_upper_one(1,1);
        seg.features{num}(50) = vec_upper_one(end,1);
        for i = 2:50-1
            x = 1+(max(vec_upper_one(:,2))-1)/49*(i-1);
            seg.features{num}(i) = vec_upper_one(floor(x),1)+(vec_upper_one(ceil(x),1)-vec_upper_one(floor(x),1))*(x-floor(x));

        end

        seg.features{num}(51) = vec_bottom_one(1,1);
        seg.features{num}(100) = vec_bottom_one(end,1);
        for i = (2:50-1)
            x = 1+(max(vec_bottom_one(:,2))-1)/49*(i-1);
            seg.features{num}(i+50) = vec_bottom_one(floor(x),1)+(vec_bottom_one(ceil(x),1)-vec_bottom_one(floor(x),1))*(x-floor(x));
        end

        % seg.features_mean_sub{num}(1:50) = seg.features{num}(1:50)-mean(seg.features{num}(1:50));
        % seg.features_mean_sub{num}((1:50)+50) = seg.features{num}((1:50)+50)-mean(seg.features{num}((1:50)+50));
        seg.mean_freq(1,num) = (freq_max-mean(seg.BW3{num}{max_ind}(:,1)))*freq_resolution;
        seg.features{num}(1:100) = (freq_max-seg.features{num}(1:100))*freq_resolution;
        seg.features_mean_sub{num}(1:100) = seg.features{num}(1:100)-seg.mean_freq(1,num);
    end
        
end
    
end

if length(seg.features)<USV_num
    seg.features{USV_num} = [];
seg.features_mean_sub{USV_num} = [];
seg.duration_max_c(USV_num) = 0;
seg.mean_freq(USV_num) = 0;
seg.duration(USV_num) = 0;
end
toc

%disp("Number of USVs with two rats vocalizing simultaneously: "+sum(seg.double_rats));
end

