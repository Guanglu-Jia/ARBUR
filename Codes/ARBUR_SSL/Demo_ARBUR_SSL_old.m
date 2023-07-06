%%
filename = 'G:\Contributed Papers\To be submitted\9-PNAS\ARBUR_SSL\world3d2_2.csv';
filename = 'G:\Contributed Papers\To be submitted\9-PNAS\ARBUR_SSL\rats_nose_3d_2.csv';
filename = 'G:\Contributed Papers\To be submitted\9-PNAS\ARBUR_SSL\rats_nose_3d_final.csv';
filename = 'Z:\USV_datasets\voice-image\1114\seq01.12\match_point\current\01\world3d-111401-one.csv';
filename = 'Z:\USV_datasets\voice-image\1114\seq01.12\match_point\current\03\world3d-111403-one.csv';
filename = 'Z:\USV_datasets\voice-image\1114\seq01.12\match_point\current\09\world3d-111409-one.csv';


BT_temp = load('demo_behavior_label.mat');
delimiter = ',';
formatSpec = '%s%s%s%s%s%s%s%[^\n\r]';

fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
fclose(fileID);
rats_nose_3d = [dataArray{1:end-1}];
clearvars filename delimiter formatSpec fileID dataArray ans;
rats_nose_3d(1,:) = [];

% 计算每个信号的天数，即其在当天的序号
USV_day_14 = [0,2118,358,1402,545,6,511,1808,176,1847,837,161,1112,2213,1065,41,1151,82,7,35,103,20,21,80,467,10];
USV_day_16 = [0,3370,203,2850,1481,1367,661,676,216,75,26,1628,1802,1109,244,1472,575,1089,158,410,208,80,32,1272,469,637,223];
USV_day_17 = [0,181,2,10,8,8,6,24,32,6,3,13,620,43,8,5,20,4,23,184,96,25,2,6,103,130];
USV_day_18 = [0,1264,856,10,4,12,4,14,6,1,13,63,230,4,7,1,39,11,496,1,28,50,14,85,12,8,53];
USV_day_{1} = USV_day_14;
USV_day_{2} = USV_day_16;
USV_day_{3} = USV_day_17;
USV_day_{4} = USV_day_18;

day_flag_vec = 20+15+24+[0 24 48 72];
day_flag_vec_2 = [14 16 17 18];
SSL_ind = [];
day_num = [];
seg_num = [];
USV_num = [];
USV_all = [];
for i = 1:size(rats_nose_3d,1)
    a_temp = strsplit(rats_nose_3d(i,1),'-');
    b_temp = strsplit(a_temp(2),'_');
    day_flag = (str2double(b_temp(1))-14)*24+str2double(b_temp(2));
    day_num(i) = day_flag_vec_2(find(day_flag<day_flag_vec,1));
    a_temp = strsplit(rats_nose_3d(i,1),'_');
    seg_num(i) = str2double(a_temp(3));
    USV_num(i) = str2double(a_temp(4));
    USV_all(i) = USV_num(i)+sum(USV_day_{find(day_flag<day_flag_vec,1)}(1:seg_num(i)));
end

% day_num



SSL_ind = [day_num',seg_num',USV_all',USV_num'];

%% Initialization and setting parameters 
Fs=250000;  % Hz
time_resolution = Fs/1000; 
Temp=25;  % Degrees centigrade
ssl = struct();
ssl.freq_min = seg.freq_min;
ssl.freq_max = seg.freq_min+seg.freq_range;
ssl.time_init = seg.time_min;
ssl.time_end = seg.time_min+seg.duration';

source_estimated_all = [];

for ii = 1:size(SSL_ind,1)

% mini_seg_duration = 15; % ms;
% mini_seg_stride = 3; % ms；

day_ = SSL_ind(ii,1);

if day_ == 14
    load('ssl_1114.mat');
    file_path = 'Z:\USV_datasets\voice-image\1114\seq01.12\seq\';
    USV_num_all = [2118,358,1402,545,6,511,1808,176,1847,837,161,1112,2213,1065,41,1151,82,7,35,103,20,21,80,467,10];
elseif day_ == 16
    load('ssl_1116.mat');
    file_path = 'Z:\USV_datasets\voice-image\1116\seq01.12\seq\';
    USV_num_all = [3370,203,2850,1481,1367,661,676,216,75,26,1628,1802,1109,244,1472,575,1089,158,410,208,80,32,1272,469,637,223];
elseif day_ == 17
    load('ssl_1117.mat');
    file_path = 'Z:\USV_datasets\voice-image\1117\seq01.12\seq\';
    USV_num_all = [181,2,10,8,8,6,24,32,6,3,13,620,43,8,5,20,4,23,184,96,25,2,6,103,130];
elseif day_ == 18
    load('ssl_1118.mat');
    file_path = 'Z:\USV_datasets\voice-image\1118\seq01.12\seq\';
    USV_num_all = [1264,856,10,4,12,4,14,6,1,13,63,230,4,7,1,39,11,496,1,28,50,14,85,12,8,53];
end
    

% 第几段声音
% sound_half_num = 1;




rat_nose_height = 0.0; % m
% filename_1 = 'Z:\USV_datasets\data10.13\ch1\T0000001.wav';
% filename_2 = 'Z:\USV_datasets\data10.13\ch2\T0000001.wav';
% filename_3 = 'Z:\USV_datasets\data10.13\ch3\T0000001.wav';
% filename_4 = 'Z:\USV_datasets\data10.13\ch4\T0000001.wav';
% num = 57;
% Data augmentation and steered response power-based SSL
% for all segments of audio data
input_index = [];
sound_half_num = SSL_ind(ii,2);
num_all = SSL_ind(ii,3);
num = SSL_ind(ii,4);

%     % 计算该信号属于第几段
%     for half_i = 1:length(USV_num_all)-1
%         if  num_all <= sum(USV_num_all(1))
%             sound_half_num = 1;
%         elseif num_all > sum(USV_num_all(1:half_i)) &&  num_all <= sum(USV_num_all(1:half_i+1))
%             sound_half_num = half_i+1;
%         end
%     end
%     % 计算该信号(总序号为 num_all)在该段内的序号(num)
%     if sound_half_num > 1
%         num = num_all - sum(USV_num_all(1:sound_half_num-1));
%     else
%         num = num_all;
%     end
    
    if ssl.freq_min(num_all)> 0
    for rat_nose_height = 0.05 %0.13
        %         if sound_half_num <2
%             if num<10
%             filename_1 = char(file_path+"ch1\ch1_2022-11-14_20-48-00_01\ch1_2022-11-14_20-48-00_01_000"+num+".wav");
%             filename_2 = char(file_path+"ch2\ch2_2022-11-14_20-48-00_01\ch2_2022-11-14_20-48-00_01_000"+num+".wav");
%             filename_3 = char(file_path+"ch3\ch3_2022-11-14_20-48-00_01\ch3_2022-11-14_20-48-00_01_000"+num+".wav");
%             filename_4 = char(file_path+"ch4\ch4_2022-11-14_20-48-00_01\ch4_2022-11-14_20-48-00_01_000"+num+".wav");
%             elseif num<100
%             filename_1 = char(file_path+"ch1\ch1_2022-11-14_20-48-00_01\ch1_2022-11-14_20-48-00_01_00"+num+".wav");
%             filename_2 = char(file_path+"ch2\ch2_2022-11-14_20-48-00_01\ch2_2022-11-14_20-48-00_01_00"+num+".wav");
%             filename_3 = char(file_path+"ch3\ch3_2022-11-14_20-48-00_01\ch3_2022-11-14_20-48-00_01_00"+num+".wav");
%             filename_4 = char(file_path+"ch4\ch4_2022-11-14_20-48-00_01\ch4_2022-11-14_20-48-00_01_00"+num+".wav");
%             elseif num<1000
%             filename_1 = char(file_path+"ch1\ch1_2022-11-14_20-48-00_01\ch1_2022-11-14_20-48-00_01_0"+num+".wav");
%             filename_2 = char(file_path+"ch2\ch2_2022-11-14_20-48-00_01\ch2_2022-11-14_20-48-00_01_0"+num+".wav");
%             filename_3 = char(file_path+"ch3\ch3_2022-11-14_20-48-00_01\ch3_2022-11-14_20-48-00_01_0"+num+".wav");
%             filename_4 = char(file_path+"ch4\ch4_2022-11-14_20-48-00_01\ch4_2022-11-14_20-48-00_01_0"+num+".wav");    
%             elseif num<10000
%             filename_1 = char(file_path+"ch1\ch1_2022-11-14_20-48-00_01\ch1_2022-11-14_20-48-00_01_"+num+".wav");
%             filename_2 = char(file_path+"ch2\ch2_2022-11-14_20-48-00_01\ch2_2022-11-14_20-48-00_01_"+num+".wav");
%             filename_3 = char(file_path+"ch3\ch3_2022-11-14_20-48-00_01\ch3_2022-11-14_20-48-00_01_"+num+".wav");
%             filename_4 = char(file_path+"ch4\ch4_2022-11-14_20-48-00_01\ch4_2022-11-14_20-48-00_01_"+num+".wav");   
%             end
%         else

            temp_1 = dir(char(file_path+"ch1\"));
            temp_2 = dir(char(file_path+"ch2\"));
            temp_3 = dir(char(file_path+"ch3\"));
            temp_4 = dir(char(file_path+"ch4\"));
            if num<10
            filename_1 = char(file_path+"ch1\"+temp_1(sound_half_num+2).name+"\"+temp_1(sound_half_num+2).name+"_000"+num+".wav");
            filename_2 = char(file_path+"ch2\"+temp_2(sound_half_num+2).name+"\"+temp_2(sound_half_num+2).name+"_000"+num+".wav");
            filename_3 = char(file_path+"ch3\"+temp_3(sound_half_num+2).name+"\"+temp_3(sound_half_num+2).name+"_000"+num+".wav");
            filename_4 = char(file_path+"ch4\"+temp_4(sound_half_num+2).name+"\"+temp_4(sound_half_num+2).name+"_000"+num+".wav");
            elseif num<100
            filename_1 = char(file_path+"ch1\"+temp_1(sound_half_num+2).name+"\"+temp_1(sound_half_num+2).name+"_00"+num+".wav");
            filename_2 = char(file_path+"ch2\"+temp_2(sound_half_num+2).name+"\"+temp_2(sound_half_num+2).name+"_00"+num+".wav");
            filename_3 = char(file_path+"ch3\"+temp_3(sound_half_num+2).name+"\"+temp_3(sound_half_num+2).name+"_00"+num+".wav");
            filename_4 = char(file_path+"ch4\"+temp_4(sound_half_num+2).name+"\"+temp_4(sound_half_num+2).name+"_00"+num+".wav");
            elseif num<1000
            filename_1 = char(file_path+"ch1\"+temp_1(sound_half_num+2).name+"\"+temp_1(sound_half_num+2).name+"_0"+num+".wav");
            filename_2 = char(file_path+"ch2\"+temp_2(sound_half_num+2).name+"\"+temp_2(sound_half_num+2).name+"_0"+num+".wav");
            filename_3 = char(file_path+"ch3\"+temp_3(sound_half_num+2).name+"\"+temp_3(sound_half_num+2).name+"_0"+num+".wav");
            filename_4 = char(file_path+"ch4\"+temp_4(sound_half_num+2).name+"\"+temp_4(sound_half_num+2).name+"_0"+num+".wav");
            elseif num<10000
            filename_1 = char(file_path+"ch1\"+temp_1(sound_half_num+2).name+"\"+temp_1(sound_half_num+2).name+"_"+num+".wav");
            filename_2 = char(file_path+"ch2\"+temp_2(sound_half_num+2).name+"\"+temp_2(sound_half_num+2).name+"_"+num+".wav");
            filename_3 = char(file_path+"ch3\"+temp_3(sound_half_num+2).name+"\"+temp_3(sound_half_num+2).name+"_"+num+".wav");
            filename_4 = char(file_path+"ch4\"+temp_4(sound_half_num+2).name+"\"+temp_4(sound_half_num+2).name+"_"+num+".wav");
            end            
%         end



seg_duration = ssl.time_end(num_all)-ssl.time_init(num_all); % ms

% 根据信号持续时间，划分切割窗口宽度和步长
if seg_duration>=10
    mini_seg_duration = seg_duration/2; % ms;
    mini_seg_stride = seg_duration/15; % ms；
else
    mini_seg_duration = 5; % ms;
    mini_seg_stride = 0.5; % ms；
end

% seg.max_intensity(num_all)

[y_1_all,Fs_1] = audioread(filename_1);
[y_2_all,Fs_2] = audioread(filename_2);
[y_3_all,Fs_3] = audioread(filename_3);
[y_4_all,Fs_4] = audioread(filename_4);

[y_1_1,Fs_1] = audioread(filename_1);

time_init = max(1,(ssl.time_init(num_all)+0)*time_resolution);
time_end = min(length(y_1_1),(ssl.time_end(num_all)-0)*time_resolution);
% samples = [time_init,floor(time_init+(time_end-time_init)*4/8)];
samples = [time_init,time_end];

% [y_1,Fs_1] = audioread(filename_1,samples+0*time_resolution);
% [y_2,Fs_2] = audioread(filename_2,samples+0*time_resolution);
% [y_3,Fs_3] = audioread(filename_3,samples-0*time_resolution);
% [y_4,Fs_4] = audioread(filename_4,samples-0*time_resolution);
[y_1_all,Fs_1] = audioread(filename_1,samples+0*time_resolution);
[y_2_all,Fs_2] = audioread(filename_2,samples+0*time_resolution);
[y_3_all,Fs_3] = audioread(filename_3,samples-0*time_resolution);
[y_4_all,Fs_4] = audioread(filename_4,samples+0*time_resolution);

n_mikes=4;

f_lo = (ssl.freq_min(num_all)-0)*1000;
% f_hi = ssl.freq_max(num)*1000;
f_hi = (ssl.freq_max(num_all)+0)*1000;
% f_hi = (ssl.freq_min(num)+8)*1000;

% dx=250e-6;  % m
dx=1e-3;  % m
xl=[-0.26 +0.26];
yl=[-0.26 +0.26];


% make some grids 
x_line=(xl(1):dx:xl(2))';
y_line=(yl(1):dx:yl(2))';
n_x=length(x_line);
n_y=length(y_line);
x_grid=repmat(x_line ,[1 n_y]);
y_grid=repmat(y_line',[n_x 1]);
% x_grid = x_grid';
% y_grid = y_grid';

in_cage=true(size(x_grid));

% 
for i = 1:length(x_grid)
    for j = 1:length(x_grid)
        if norm([i-round(length(x_grid)/2),j-round(length(x_grid)/2)]*xl(2)/length(x_grid)*2) >= xl(2)-0.00
            in_cage(i,j) = 0;
        end
    end
end


% colors for microphones
% clr_mike=[0 0   1  ; ...
%           0 1 0  ; ...
%           1 0   0  ; ...
%           0.8 0.8 0.8];

source_estimated = cell(ceil((seg_duration-mini_seg_duration)/mini_seg_stride)+1,5);
sample_vec = [1:mini_seg_duration*time_resolution];
      
for i = 1:ceil((seg_duration-mini_seg_duration)/mini_seg_stride)+1
if i <ceil((seg_duration-mini_seg_duration)/mini_seg_stride)+1
    sample_window = sample_vec+round(mini_seg_stride*time_resolution*(i-1));
else
    sample_window = round((length(y_1_all)/time_resolution-mini_seg_duration)*time_resolution):1:length(y_1_all);
end

y_1 = y_1_all(sample_window);
y_2 = y_2_all(sample_window);
y_3 = y_3_all(sample_window);
y_4 = y_4_all(sample_window);

verbosity = 0;
[r_est_1234,r_est_234,r_est_134,r_est_124,r_est_123]= cal5estimates(y_1,y_2,y_3,y_4,Fs,f_lo,f_hi,Temp,x_grid,y_grid,in_cage,rat_nose_height,verbosity);
source_estimated{i,1} = r_est_1234;
source_estimated{i,2} = r_est_234;
source_estimated{i,3} = r_est_134;
source_estimated{i,4} = r_est_124;
source_estimated{i,5} = r_est_123;
end
    
% 对时间窗口做拆分，每5 ms一个窗口，用四个麦克风的信息输出定位结果；
% 如一个信号总时长17 ms，则拆分成4个窗口，0-5,5-10,10-15,12-17，结合总窗口数据一共得到5个定位结果。

source_estimated_all{ii} = source_estimated;
ii
      
    end      

    end
end

%% Confidence evaluation and calculate SSL result
% source_estimated 中包含nX5 个预测位置，根据这些位置，计算SSL置信度；
% 其中第一列为采用4个麦克风的预测结果，后四列均为采用3个麦克风的预测结果；
% 

% Estimate the probability density map
dx=1e-2;  % m
xl=[-0.26 +0.26];
yl=[-0.26 +0.26];
x_line=(xl(1):dx:xl(2))';
y_line=(yl(1):dx:yl(2))';

[x1,x2] = meshgrid(x_line, y_line);
x1 = x1(:);
x2 = x2(:);
xi = [x1 x2];

ssl_position = [];
ssl_confidence = [];

for jj = 1:length(source_estimated_all)
    if ~isempty(source_estimated_all{jj})
source_estimated = source_estimated_all{jj};

% Add Color bar
% cb = colorbar();
% cb.Label.String = 'Probability density estimate';

rng('default')  % For reproducibility
x_input = cell2mat(source_estimated(:,1)')';

% 
x_input_3 = [];
for i = 1:4
    temp = cell2mat(source_estimated(:,i+1)')';
    x_input_3 = [x_input_3;temp];
end
        

[f_3_mics,xxi] = ksdensity(x_input_3,xi,'Bandwidth',[1 1]*0.04);
[f_4_mics,xxi] = ksdensity(x_input,xi,'Bandwidth',[1 1]*0.04*1);

% [xq,yq,z] = computeGrid(xi(:,1),xi(:,2),f);
x = linspace(min(xi(:,1)),max(xi(:,1)));
y = linspace(min(xi(:,2)),max(xi(:,2)));
[xq,yq] = meshgrid(x,y);

% SSL with 3 mics
z = griddata(xi(:,1),xi(:,2),f_3_mics,xq,yq);


% figure
% % surf(axarg{:},xq,yq,z);
% f1 = figure('Color','white');
% % colormap jet
% 
% hold on;
% 
% % surf(z');
% imagesc(z);
% colorbar
% title("SSL with 3 mics");
% axis([ 0 100 0 100]);


% sum(sum(z))
% SSL with 4 mics
z_4 = griddata(xi(:,1),xi(:,2),f_4_mics,xq,yq);
% z_4 = flipud(z_4);

% surf(axarg{:},xq,yq,z);
% f2 = figure('Color','white');
% hold on;
% 
% % surf(z');
% imagesc(z_4);
% colorbar
% title("SSL with 4 mics");
% axis([ 0 100 0 100]);

sum(sum(z_4))

% 
[z_max_x,z_max_y] = find(z_4 == max(max(z_4)));
z_max_value = max(max(z));

ssl_confidence(jj) = z(z_max_x(1),z_max_y(1))/max(max(z));
z_max_value_all(jj) = max(max(z_4));

[z_max_x_3,z_max_y_3] = find(z == max(max(z)));
% [z_max_x_3(1),z_max_y_3(1)];
temp = z_max_x_3(1);
z_max_x_3(1) = z_max_y_3(1);
z_max_y_3(1) = temp;
% [z_max_x(1),z_max_y(1)];
temp = z_max_x(1);
z_max_x(1) = z_max_y(1);
z_max_y(1) = temp;
ssl_position(jj,:) = ([z_max_x(1),z_max_y(1)]+[z_max_x_3(1),z_max_y_3(1)])/2;
    else
        ssl_position(jj,:) = [-260 260];
        ssl_confidence(jj) = 0;
    end
end
ssl_confidence = ssl_confidence';

% ssl_position = flip(ssl_position,2);
% ssl_position(:,1) = 100-ssl_position(:,1);
ssl_position = (ssl_position-[50,50])/(50)*.52/2*1000;
% ssl_position(:,2) = ssl_position(:,2)*-1;
theta = 90/180*pi;
ssl_position = ssl_position*[ cos(theta) -sin(theta);sin(theta) cos(theta)]

ssl_confidence

%% Load rat noses' 3D coordinates reconstructed visually
filename = 'G:\Contributed Papers\To be submitted\9-PNAS\ARBUR_SSL\rats_nose_3d.csv';
filename = 'G:\Contributed Papers\To be submitted\9-PNAS\ARBUR_SSL\rats_nose_3d_final.csv';

delimiter = ',';
formatSpec = '%s%s%s%s%s%s%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
fclose(fileID);
partworld3d = [dataArray{1:end-1}];
clearvars filename delimiter formatSpec fileID dataArray ans;


%% Assigning SSL results based on horizontal information

nose_ = zeros(size(partworld3d,1)-1,7);
for i = 1:size(nose_,1)
    temp = strsplit(partworld3d(i+1,1),'_');
%     nose_(i,1) = str2num(char(temp(4)));
    nose_(i,1) = i;
    if (partworld3d(i+1,2)) ~= "NaN"
        nose_(i,2) = str2num(partworld3d{i+1,2});
        nose_(i,3) = str2num(partworld3d{i+1,3});
        nose_(i,4) = str2num(partworld3d{i+1,4});
    end
    
    if (partworld3d(i+1,5)) ~= "NaN"
        nose_(i,5) = str2num(partworld3d{i+1,5});
        nose_(i,6) = str2num(partworld3d{i+1,6});
        nose_(i,7) = str2num(partworld3d{i+1,7});        
    end    
    
end
% 鼠的鼻尖点的三维坐标
% nose_(1,:) = [];
%
% nose_(find(nose_(:,3)>500),2:4) = 0;
% nose_(find(nose_(:,3)>500),2:4) = 0;
% nose_(find(nose_(:,6)>500),5:6) = 0;

SSL_output = zeros(length(nose_),1);
SSL_threshold = 100; % mm
LCI_threshold = 0.6;


for i = 1:length(nose_)
% two rat noses detected 
% if ssl_confidence(i)> LCI_threshold
if (partworld3d(i+1,2)) ~= "NaN" && (partworld3d(i+1,5)) ~= "NaN"
    if min(norm(ssl_position(nose_(i,1),:)-nose_(i,2:3)),norm(ssl_position(nose_(i,1),:)-nose_(i,5:6)))<SSL_threshold
    if norm(ssl_position(nose_(i,1),:)-nose_(i,2:3))<norm(ssl_position(nose_(i,1),:)-nose_(i,5:6))
        SSL_output(i) = 1;
    else
        SSL_output(i) = 2;
    end
    end
% one rat nose detected    
elseif (partworld3d(i+1,2)) ~= "NaN" 
    if norm(ssl_position(nose_(i,1),:)-nose_(i,2:3))<SSL_threshold
        SSL_output(i) = 1;
    else
        SSL_output(i) = 2;
    end
   
elseif (partworld3d(i+1,5)) ~= "NaN"
    if norm(ssl_position(nose_(i,1),:)-nose_(i,5:6))<SSL_threshold
        SSL_output(i) = 2;
    else
        SSL_output(i) = 1;
    end    
    
else
    % unassigned results
    
% end

end

end


%% 3D assignment for POU and PIN behaviors unassigned based on horizontal information


% 
for i = 1:length(nose_)
if max(norm(ssl_position(nose_(i,1),:)-nose_(i,2:3)),norm(ssl_position(nose_(i,1),:)-nose_(i,5:6)))<SSL_threshold ...
        && (string(BT_temp.SB_label{i,2})== "POU(pouncing)" || string(BT_temp.SB_label{1,2})== "PIN(pinning)")

% unassigned_ind_POU_PIN = (SSL_output==0)&(BT(:,1)== 'POU(pouncing)' || BT(:,2) == 'PIN(pinning)');
unassigned_ind_POU_PIN = [20:25];

for i = unassigned_ind_POU_PIN

% two rat noses detected 
if (partworld3d(i+1,2)) ~= "NaN" && (partworld3d(i+1,5)) ~= "NaN"
    rat_nose_height_1 = nose_(i,4)/1000;
    source_estimated_all = SRP_SSL(i,SSL_ind,rat_nose_height_1);
    [LCI_1,~] = LCI_eval(source_estimated_all);
    rat_nose_height_2 = nose_(i,7)/1000;
    source_estimated_all = SRP_SSL(i,SSL_ind,rat_nose_height_2);
    [LCI_2,~] = LCI_eval(source_estimated_all);
    if LCI_1(end)>LCI_2(end)
        SSL_output(i) = 1;
    else
        SSL_output(i) = 2;
    end
    
% one rat nose detected    
elseif (partworld3d(i+1,2)) ~= "NaN" 
    rat_nose_height_1 = nose_(i,4)/1000;
    source_estimated_all = SRP_SSL(i,SSL_ind,rat_nose_height_1);    
    [LCI_1,~] = LCI_eval(source_estimated_all);
    if rat_nose_height_1 > 5
        rat_nose_height_2 = 0;
    else
        rat_nose_height_2 = rat_nose_height_1+5;
    end
    source_estimated_all = SRP_SSL(i,SSL_ind,rat_nose_height_2);
    [LCI_2,~] = LCI_eval(source_estimated_all);
    if LCI_1(end)>LCI_2(end)
        SSL_output(i) = 1;
    else
        SSL_output(i) = 2;
    end
    
elseif (partworld3d(i+1,5)) ~= "NaN"
    rat_nose_height_2 = nose_(i,7)/1000;
    source_estimated_all = SRP_SSL(i,SSL_ind,rat_nose_height_2);    
    [LCI_2,~] = LCI_eval(source_estimated_all);
    if rat_nose_height_2 > 5
        rat_nose_height_1 = 0;
    else
        rat_nose_height_1 = rat_nose_height_2+5;
    end
    source_estimated_all = SRP_SSL(i,SSL_ind,rat_nose_height_1);
    [LCI_1,~] = LCI_eval(source_estimated_all);
    if LCI_1>LCI_2
        SSL_output(i) = 1;
    else
        SSL_output(i) = 2;
    end    
    
else
    % unassigned results
       
end
    
end

end
end

