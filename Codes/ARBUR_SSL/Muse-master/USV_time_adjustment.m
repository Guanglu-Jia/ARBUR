%% 调整14号的USV发生时间
% 根据超声记录的dropout发生时间，对实际USV发生时间做纠正
% 假设：在一段（1800s）记录时间内，每个dropout丢失的时间一致
% 根据该USV的发生时间之前发生的dropout次数，将该发生时间往后顺延
% 输入：channel 1的log文件，每一段检测到的USV发声时间csv文件

% clear;
% clc

% 导入channel 1的log文件
load('ch1_log_14.mat');
ch1(length(ch1),:) = [];
dropout_ind = find(ch1(:,3) == 'dropout');
dropout_else_ind = find(ch1(:,3) ~= 'dropout');
time_str = ch1(:,2);
time_vec = zeros(length(time_str),1);
for i = 1:length(time_str)
    temp = double(strsplit(time_str(i),':'));
        if temp(1)<16
        temp(1) = temp(1) + 24;
        end
    time_vec(i) = temp(1)*3600+temp(2)*60+temp(3);
end
time_onset = time_vec(dropout_else_ind(2));
time_vec = time_vec - time_onset;

% 本段记录延迟的时间；
for i = 1:24
delay(i,1) = time_vec(dropout_else_ind(i+2))-time_vec(dropout_else_ind(i+1))-1800;
end
delay(25,1) = time_vec(dropout_else_ind(27))-time_vec(dropout_else_ind(26))-554;
delay(delay<0) = 0;

delay_init = 3.1;

file_path = "Z:\USV_datasets\voice-image\1114\seq01.12\ch1\Offset_with_dropouts\";
folder_all = dir(char(file_path+"Before\"));
folder_all(1:2,:) = [];
% 对每个csv文件进行修正
for i = 1:25
    file_path_ = file_path+"Before\"+string(folder_all(i).name);
    time_temp = csvread(char(file_path_),1,1);
    time_temp = time_temp(:,1:2);
    file_path_store = file_path+"After2\"+string(folder_all(i).name);
    dropout_time_temp = time_vec(dropout_else_ind(i)+1:dropout_else_ind(i+1)-1);
    offset_per_dropout = delay(i)/length(dropout_time_temp);
    time_temp_updated = time_temp;
    for j = 1:length(time_temp)
        time_temp_updated(j,:) = time_temp(j,:)+offset_per_dropout*sum(time_temp(j,1)>dropout_time_temp);
    end
    
    time_temp_updated = [(1:length(time_temp_updated))',time_temp_updated];
%     csvwrite(char(file_path_store),time_temp_updated,1,0);
%     writeMatrix(time_temp_updated,char(file_path_store));
    name_tempt = string(folder_all(i).name);
    a_tempt = strsplit(name_tempt,'_');
    a_tempt_1 = strsplit(a_tempt(2),'-');
    a_tempt_2 = double(strsplit(a_tempt(3),'-'));
    time_start(1) = double(a_tempt_1(3));
    a_tempt_2(3) = a_tempt_2(3)+delay_init;
    if a_tempt_2(3)>=60
       a_tempt_2(3) = a_tempt_2(3)-60;
       a_tempt_2(2) = a_tempt_2(2)+1;
    end
    if a_tempt_2(2)>=60
        a_tempt_2(2) = a_tempt_2(2)-60;
        a_tempt_2(1) = a_tempt_2(1)+1;
    end
    if a_tempt_2(1)>=24
        a_tempt_2(1) = a_tempt_2(1)-24;
        time_start(1) = time_start(1)+1;
    end
    time_start(2:4) = a_tempt_2;
    dlmwrite(char(file_path_store),[time_start],'delimiter',',','precision',8);
    dlmwrite(char(file_path_store),time_temp_updated,'delimiter',',','precision',8,'roffset',0,'-append');
    
end


%% 调整16号的USV发生时间
% 根据超声记录的dropout发生时间，对实际USV发生时间做纠正
% 假设：在一段（1800s）记录时间内，每个dropout丢失的时间一致
% 根据该USV的发生时间之前发生的dropout次数，将该发生时间往后顺延
% 输入：channel 1的log文件，每一段检测到的USV发声时间csv文件

% clear;
% clc

% 导入channel 1的log文件
load('ch1_log_16.mat');

USV_num_all = [3370,203,2850,1481,1367,661,676,216,75,26,1628,1802,1109,244,1472,575,1089,158,410,208,80,32,1272,469,637,223];

ch1(length(ch1),:) = [];
dropout_ind = find(ch1(:,3) == 'dropout');
dropout_else_ind = find(ch1(:,3) ~= 'dropout');
time_str = ch1(:,2);
time_vec = zeros(length(time_str),1);
for i = 1:length(time_str)
    temp = double(strsplit(time_str(i),':'));
        if temp(1)<16
        temp(1) = temp(1) + 24;
        end
    time_vec(i) = temp(1)*3600+temp(2)*60+temp(3);
end
time_onset = time_vec(dropout_else_ind(2));
time_vec = time_vec - time_onset;

% 本段记录延迟的时间；
for i = 1:26
delay(i,1) = time_vec(dropout_else_ind(i+2))-time_vec(dropout_else_ind(i+1))-1800;
end
% delay(25,1) = time_vec(dropout_else_ind(27))-time_vec(dropout_else_ind(26))-554;
% delay(delay<0) = 0;

delay_init = 2.5;

file_path = "Z:\USV_datasets\voice-image\1116\seq01.12\ch1\Offset_with_dropouts\";
folder_all = dir(char(file_path+"Before\"));
folder_all(1:2,:) = [];
% 对每个csv文件进行修正
for i = 1:26
    file_path_ = file_path+"Before\"+string(folder_all(i).name);
    time_temp = csvread(char(file_path_),1,1);
    time_temp = time_temp(:,1:2);
    file_path_store = file_path+"After2\"+string(folder_all(i).name);
    dropout_time_temp = time_vec(dropout_else_ind(i)+1:dropout_else_ind(i+1)-1);
    offset_per_dropout = delay(i)/length(dropout_time_temp);
    time_temp_updated = time_temp;
    for j = 1:length(time_temp)
        time_temp_updated(j,:) = time_temp(j,:)+offset_per_dropout*sum(time_temp(j,1)>dropout_time_temp);
    end
    
    time_temp_updated = [(1:length(time_temp_updated))',time_temp_updated];
%     csvwrite(char(file_path_store),time_temp_updated,1,0);
%     writeMatrix(time_temp_updated,char(file_path_store));
    name_tempt = string(folder_all(i).name);
    a_tempt = strsplit(name_tempt,'_');
    a_tempt_1 = strsplit(a_tempt(2),'-');
    a_tempt_2 = double(strsplit(a_tempt(3),'-'));
    time_start(1) = double(a_tempt_1(3));
    a_tempt_2(3) = a_tempt_2(3)+delay_init;
    if i== 1
        a_tempt_2(3)  = a_tempt_2(3) +1;
    end
    if a_tempt_2(3)>=60
       a_tempt_2(3) = a_tempt_2(3)-60;
       a_tempt_2(2) = a_tempt_2(2)+1;
    end
    if a_tempt_2(2)>=60
        a_tempt_2(2) = a_tempt_2(2)-60;
        a_tempt_2(1) = a_tempt_2(1)+1;
    end
    if a_tempt_2(1)>=24
        a_tempt_2(1) = a_tempt_2(1)-24;
        time_start(1) = time_start(1)+1;
    end
    time_start(2:4) = a_tempt_2;

    
    dlmwrite(char(file_path_store),[time_start],'delimiter',',','precision',8);
    dlmwrite(char(file_path_store),time_temp_updated,'delimiter',',','precision',8,'roffset',0,'-append');
    
end

%% 调整17号的USV发生时间
% 根据超声记录的dropout发生时间，对实际USV发生时间做纠正
% 假设：在一段（1800s）记录时间内，每个dropout丢失的时间一致
% 根据该USV的发生时间之前发生的dropout次数，将该发生时间往后顺延
% 输入：channel 1的log文件，每一段检测到的USV发声时间csv文件

% clear;
% clc

% 导入channel 1的log文件
load('ch1_log_17.mat');
ch1(length(ch1),:) = [];
dropout_ind = find(ch1(:,3) == 'dropout');
dropout_else_ind = find(ch1(:,3) ~= 'dropout');
time_str = ch1(:,2);
time_vec = zeros(length(time_str),1);
for i = 1:length(time_str)
    temp = double(strsplit(time_str(i),':'));
        if temp(1)<16
        temp(1) = temp(1) + 24;
        end
    time_vec(i) = temp(1)*3600+temp(2)*60+temp(3);
end
time_onset = time_vec(dropout_else_ind(2));
time_vec = time_vec - time_onset;

% 本段记录延迟的时间；
for i = 1:25
delay(i,1) = time_vec(dropout_else_ind(i+2))-time_vec(dropout_else_ind(i+1))-1800;
end
% delay(26,1) = time_vec(dropout_else_ind(27))-time_vec(dropout_else_ind(26))-14.7;
delay(delay<0) = 0;

delay_init = 1.76;

file_path = "Z:\USV_datasets\voice-image\1117\seq01.12\ch1\Offset_with_dropouts\";
folder_all = dir(char(file_path+"Before\"));
folder_all(1:2,:) = [];
% 对每个csv文件进行修正
for i = 1:25
    file_path_ = file_path+"Before\"+string(folder_all(i).name);
    time_temp = csvread(char(file_path_),1,1);
    time_temp = time_temp(:,1:2);
    file_path_store = file_path+"After2\"+string(folder_all(i).name);
    dropout_time_temp = time_vec(dropout_else_ind(i)+1:dropout_else_ind(i+1)-1);
    offset_per_dropout = delay(i)/length(dropout_time_temp);
    time_temp_updated = time_temp;
    for j = 1:size(time_temp,1)
        time_temp_updated(j,:) = time_temp(j,:)+offset_per_dropout*sum(time_temp(j,1)>dropout_time_temp);
    end
    
    time_temp_updated = [(1:length(time_temp_updated))',time_temp_updated];
%     csvwrite(char(file_path_store),time_temp_updated,1,0);
%     writeMatrix(time_temp_updated,char(file_path_store));
    name_tempt = string(folder_all(i).name);
    a_tempt = strsplit(name_tempt,'_');
    a_tempt_1 = strsplit(a_tempt(2),'-');
    a_tempt_2 = double(strsplit(a_tempt(3),'-'));
    time_start(1) = double(a_tempt_1(3));
    a_tempt_2(3) = a_tempt_2(3)+delay_init;
    if a_tempt_2(3)>=60
       a_tempt_2(3) = a_tempt_2(3)-60;
       a_tempt_2(2) = a_tempt_2(2)+1;
    end
    if a_tempt_2(2)>=60
        a_tempt_2(2) = a_tempt_2(2)-60;
        a_tempt_2(1) = a_tempt_2(1)+1;
    end
    if a_tempt_2(1)>=24
        a_tempt_2(1) = a_tempt_2(1)-24;
        time_start(1) = time_start(1)+1;
    end
    time_start(2:4) = a_tempt_2;
    dlmwrite(char(file_path_store),[time_start],'delimiter',',','precision',8);
    dlmwrite(char(file_path_store),time_temp_updated,'delimiter',',','precision',8,'roffset',0,'-append');
    
end

%% 调整18号的USV发生时间
% 根据超声记录的dropout发生时间，对实际USV发生时间做纠正
% 假设：在一段（1800s）记录时间内，每个dropout丢失的时间一致
% 根据该USV的发生时间之前发生的dropout次数，将该发生时间往后顺延
% 输入：channel 1的log文件，每一段检测到的USV发声时间csv文件

% clear;
% clc

% 导入channel 1的log文件
load('ch1_log_18.mat');

USV_num_all = [1264,856,10,4,12,4,14,6,1,13,63,230,4,7,1,39,11,496,1,28,50,14,85,12,8,53];

ch1(length(ch1),:) = [];
dropout_ind = find(ch1(:,3) == 'dropout');
dropout_else_ind = find(ch1(:,3) ~= 'dropout');
time_str = ch1(:,2);
time_vec = zeros(length(time_str),1);
for i = 1:length(time_str)
    temp = double(strsplit(time_str(i),':'));
        if temp(1)<16
        temp(1) = temp(1) + 24;
        end
    time_vec(i) = temp(1)*3600+temp(2)*60+temp(3);
end
time_onset = time_vec(dropout_else_ind(2));
time_vec = time_vec - time_onset;

% 本段记录延迟的时间；
for i = 1:25
delay(i,1) = time_vec(dropout_else_ind(i+2))-time_vec(dropout_else_ind(i+1))-1800;
end
delay(26,1) = time_vec(dropout_else_ind(28))-time_vec(dropout_else_ind(27))-1174.9;
delay(delay<0) = 0;

delay_init = 6.22;

file_path = "Z:\USV_datasets\voice-image\1118\seq01.12\ch1\Offset_with_dropouts\";
folder_all = dir(char(file_path+"Before\"));
folder_all(1:2,:) = [];
% 对每个csv文件进行修正
for i = 1:26
    file_path_ = file_path+"Before\"+string(folder_all(i).name);
    time_temp = csvread(char(file_path_),1,1);
    time_temp = time_temp(:,1:2);
    file_path_store = file_path+"After2\"+string(folder_all(i).name);
    dropout_time_temp = time_vec(dropout_else_ind(i)+1:dropout_else_ind(i+1)-1);
    offset_per_dropout = delay(i)/length(dropout_time_temp);
    time_temp_updated = time_temp;
    for j = 1:size(time_temp,1)
        time_temp_updated(j,:) = time_temp(j,:)+offset_per_dropout*sum(time_temp(j,1)>dropout_time_temp);
    end
    
    time_temp_updated = [(1:size(time_temp,1))',time_temp_updated];
%     csvwrite(char(file_path_store),time_temp_updated,1,0);
%     writeMatrix(time_temp_updated,char(file_path_store));
    name_tempt = string(folder_all(i).name);
    a_tempt = strsplit(name_tempt,'_');
    a_tempt_1 = strsplit(a_tempt(2),'-');
    a_tempt_2 = double(strsplit(a_tempt(3),'-'));
    time_start(1) = double(a_tempt_1(3));
    a_tempt_2(3) = a_tempt_2(3)+delay_init;
    if a_tempt_2(3)>=60
       a_tempt_2(3) = a_tempt_2(3)-60;
       a_tempt_2(2) = a_tempt_2(2)+1;
    end
    if a_tempt_2(2)>=60
        a_tempt_2(2) = a_tempt_2(2)-60;
        a_tempt_2(1) = a_tempt_2(1)+1;
    end
    if a_tempt_2(1)>=24
        a_tempt_2(1) = a_tempt_2(1)-24;
        time_start(1) = time_start(1)+1;
    end
    time_start(2:4) = a_tempt_2;

    
    dlmwrite(char(file_path_store),[time_start],'delimiter',',','precision',8);
    dlmwrite(char(file_path_store),time_temp_updated,'delimiter',',','precision',8,'roffset',0,'-append');
    
end