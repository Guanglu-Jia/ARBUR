% close all;
% clc;
% clear;
close all;
load('ssl_1114.mat');

% 将信号按时间分割；每5 ms一段时间，然后输出每小段信号的五个估计位置；
mini_seg_duration = 7; % ms;
mini_seg_stride = 1; % ms；

file_path = 'Z:\USV_datasets\voice-image\1114\seq01.12\seq\';

rat_nose_height = 0.0; % m
% filename_1 = 'Z:\USV_datasets\data10.13\ch1\T0000001.wav';
% filename_2 = 'Z:\USV_datasets\data10.13\ch2\T0000001.wav';
% filename_3 = 'Z:\USV_datasets\data10.13\ch3\T0000001.wav';
% filename_4 = 'Z:\USV_datasets\data10.13\ch4\T0000001.wav';
% num = 57;
for num =  6
    for rat_nose_height = 0.02
if num<10
filename_1 = char(file_path+"ch1\ch1_2022-11-14_20-48-00_01\ch1_2022-11-14_20-48-00_01_000"+num+".wav");
filename_2 = char(file_path+"ch2\ch2_2022-11-14_20-48-00_01\ch2_2022-11-14_20-48-00_01_000"+num+".wav");
filename_3 = char(file_path+"ch3\ch3_2022-11-14_20-48-00_01\ch3_2022-11-14_20-48-00_01_000"+num+".wav");
filename_4 = char(file_path+"ch4\ch4_2022-11-14_20-48-00_01\ch4_2022-11-14_20-48-00_01_000"+num+".wav");
elseif num<100
filename_1 = char(file_path+"ch1\ch1_2022-11-14_20-48-00_01\ch1_2022-11-14_20-48-00_01_00"+num+".wav");
filename_2 = char(file_path+"ch2\ch2_2022-11-14_20-48-00_01\ch2_2022-11-14_20-48-00_01_00"+num+".wav");
filename_3 = char(file_path+"ch3\ch3_2022-11-14_20-48-00_01\ch3_2022-11-14_20-48-00_01_00"+num+".wav");
filename_4 = char(file_path+"ch4\ch4_2022-11-14_20-48-00_01\ch4_2022-11-14_20-48-00_01_00"+num+".wav");
elseif num<1000
filename_1 = char(file_path+"ch1\ch1_2022-11-14_20-48-00_01\ch1_2022-11-14_20-48-00_01_0"+num+".wav");
filename_2 = char(file_path+"ch2\ch2_2022-11-14_20-48-00_01\ch2_2022-11-14_20-48-00_01_0"+num+".wav");
filename_3 = char(file_path+"ch3\ch3_2022-11-14_20-48-00_01\ch3_2022-11-14_20-48-00_01_0"+num+".wav");
filename_4 = char(file_path+"ch4\ch4_2022-11-14_20-48-00_01\ch4_2022-11-14_20-48-00_01_0"+num+".wav");    
elseif num<10000
filename_1 = char(file_path+"ch1\ch1_2022-11-14_20-48-00_01\ch1_2022-11-14_20-48-00_01_"+num+".wav");
filename_2 = char(file_path+"ch2\ch2_2022-11-14_20-48-00_01\ch2_2022-11-14_20-48-00_01_"+num+".wav");
filename_3 = char(file_path+"ch3\ch3_2022-11-14_20-48-00_01\ch3_2022-11-14_20-48-00_01_"+num+".wav");
filename_4 = char(file_path+"ch4\ch4_2022-11-14_20-48-00_01\ch4_2022-11-14_20-48-00_01_"+num+".wav");   
end

Fs=250000;  % Hz

time_resolution = Fs/1000;

seg_duration = ssl.time_end(num)-ssl.time_init(num); % ms


[y_1_all,Fs_1] = audioread(filename_1);
[y_2_all,Fs_2] = audioread(filename_2);
[y_3_all,Fs_3] = audioread(filename_3);
[y_4_all,Fs_4] = audioread(filename_4);

[y_1_1,Fs_1] = audioread(filename_1);
% if length(y_1_1)<=0.05*Fs
%     samples = [max(1/Fs,round(((find(y_1_1==max(y_1_1))/Fs)*1000-5)*Fs/1000)),...
%     min(round(((find(y_1_1==max(y_1_1))/Fs)*1000+5)*Fs/1000),length(y_1_1))];
%     samples = [round(length(y_1_1)/2-750),round(length(y_1_1)/2+750)];
time_init = max(1,(ssl.time_init(num)+0)*time_resolution);
time_end = min(length(y_1_1),(ssl.time_end(num)-0)*time_resolution);
% samples = [time_init,floor(time_init+(time_end-time_init)*4/8)];
samples = [time_init,time_end];
% samples = [40,50]/2*time_resolution;
% samples = [floor(time_init+(time_end-time_init)*4/8),time_end];
% %     else
% %     samples = [3750,length(y_1_1)-3750];
% % end
% % samples = [3750,length(y_1_1)-3750];
[y_1,Fs_1] = audioread(filename_1,samples+0*time_resolution);
[y_2,Fs_2] = audioread(filename_2,samples+0*time_resolution);
[y_3,Fs_3] = audioread(filename_3,samples-0*time_resolution);
[y_4,Fs_4] = audioread(filename_4,samples-0*time_resolution);
[y_1_all,Fs_1] = audioread(filename_1,samples+0*time_resolution);
[y_2_all,Fs_2] = audioread(filename_2,samples+0*time_resolution);
[y_3_all,Fs_3] = audioread(filename_3,samples-0*time_resolution);
[y_4_all,Fs_4] = audioread(filename_4,samples-0*time_resolution);

% Y_fft_temp = fft(y_1);% 前
% Y_fft = abs(Y_fft_temp(1:length(Y_fft_temp)/2)); % 对应 0:125 kHz
% per_kHz = length(Y_fft)/125;
% freq_resolution = per_kHz;
% % 前15 kHz和 100 kHz-125 kHz置为0；
% Y_fft(1:15*per_kHz) = 0;
% Y_fft(100*per_kHz:end) = 0;
% % plot(Z) 
% [ma, I]=max(Y_fft);   %ma涓烘暟缁勭殑鏈?澶у?硷紝I涓轰笅鏍囧??
% f_max=floor(I/per_kHz*1000);

% fprintf(1, '淇″彿棰戠巼鏈?寮哄鐨勯鐜囧??=%f\n',floor(I/length(Z)*Fs));
n_mikes=4;
% fs=250000;  % Hz
% f_lo=max(15000,f_max-15000);  % Hz
% f_lo = f_max-20000;
% f_lo=15000;
% f_hi=inf;  % Hz
% f_hi = f_max+5000;
f_lo = (ssl.freq_min(num)+0)*1000;
% f_hi = ssl.freq_max(num)*1000;
f_hi = (ssl.freq_max(num)-0)*1000;
% f_hi = (ssl.freq_min(num)+8)*1000;
Temp=25;  % C
% dx=250e-6;  % m
dx=1e-3;  % m
xl=[-0.26 +0.26];
yl=[-0.26 +0.26];

R1_x=+0.1925;
R1_y=0;
R1_z=0.5-rat_nose_height;

R2_x=0;
R2_y=-0.1925;
R2_z=0.5-rat_nose_height;

R3_x=-0.1925;
R3_y=0;
R3_z=0.5-rat_nose_height;

R4_x=0;
R4_y=+0.1925;
R4_z=0.5-rat_nose_height;

% make some grids and stuff鍋氱綉缁滄牸
x_line=(xl(1):dx:xl(2))';
y_line=(yl(1):dx:yl(2))';
n_x=length(x_line);
n_y=length(y_line);
x_grid=repmat(x_line ,[1 n_y]);
y_grid=repmat(y_line',[n_x 1]);
% x_grid = x_grid';
% y_grid = y_grid';

% everything in the cage
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
clr_mike=[0 0   1  ; ...
          0 1 0  ; ...
          1 0   0  ; ...
          0.8 0.8 0.8];

source_estimated = cell(ceil((seg_duration-mini_seg_duration)/mini_seg_stride)+1,5);
sample_vec = [1:mini_seg_duration*time_resolution];
      
for i = 1:ceil((seg_duration-mini_seg_duration)/mini_seg_stride)+1
if i <ceil((seg_duration-mini_seg_duration)/mini_seg_stride)+1
    sample_window = sample_vec+mini_seg_stride*time_resolution*(i-1);
else
    sample_window = round((length(y_1_all)/time_resolution-mini_seg_duration)*time_resolution):1:length(y_1_all);
end

y_1 = y_1_all(sample_window);
y_2 = y_2_all(sample_window);
y_3 = y_3_all(sample_window);
y_4 = y_4_all(sample_window);

[r_est_1234,r_est_234,r_est_134,r_est_124,r_est_123]= cal5estimates(y_1,y_2,y_3,y_4,Fs,f_lo,f_hi,Temp,x_grid,y_grid,in_cage,rat_nose_height);
source_estimated{i,1} = r_est_1234;
source_estimated{i,2} = r_est_234;
source_estimated{i,3} = r_est_134;
source_estimated{i,4} = r_est_124;
source_estimated{i,5} = r_est_123;
end
% 对时间窗口做拆分，每5 ms一个窗口，用四个麦克风的信息输出定位结果；
% 如一个信号总时长17 ms，则拆分成4个窗口，0-5,5-10,10-15,12-17，结合总窗口数据一共得到5个定位结果。

      
      

%% 绂荤兢鐐?
% point_all=[r_est_1234,r_est_234,r_est_134,r_est_124,r_est_123];
% dis_1234=sqrt(r_est_1234(1)^2+r_est_1234(2)^2);
% dis_234=sqrt(r_est_234(1)^2+r_est_234(2)^2);
% dis_134=sqrt(r_est_134(1)^2+r_est_134(2)^2);
% dis_124=sqrt(r_est_124(1)^2+r_est_124(2)^2);
% dis_123=sqrt(r_est_123(1)^2+r_est_123(2)^2);
% dis=[dis_1234,dis_234,dis_134,dis_124,dis_123];
% % TF = isoutlier(dis,"median","ThresholdFactor",3);
% figure;
% x = 1:5;
% [TF,L,U,C] = isoutlier(dis,'quartiles',"ThresholdFactor",1.5);
% plot(x,dis,x(TF),dis(TF),'x',x,L*ones(1,5),x,U*ones(1,5),x,C*ones(1,5))
% legend('Original Data','Outlier','Lower Threshold','Upper Threshold','Center Value')



%%
R=[ R1_x R1_y R1_z ; ...
    R2_x R2_y R2_z ; ...
    R3_x R3_y R3_z ; ...
   R4_x R4_y R4_z]'; 
f = figure('color','w');
hold on;
scatter(R(1,:),R(2,:),'o','k','filled');

for i = 1:size(source_estimated,1)
    estimates_temp = cell2mat(source_estimated(i,:));
    scatter(estimates_temp(1,2:end),estimates_temp(2,2:end));
    scatter(estimates_temp(1,1),estimates_temp(2,1),'o','r','filled');
    
end

axis([-0.27 0.27 -0.27 .27]);
title("SSL results from seg: "+ num+"; Rat nose height: "+rat_nose_height*100+" cm;"...
    +" Time: "+samples(1)/time_resolution+"-"+samples(2)/time_resolution+ "ms");
f.InnerPosition = [785.0000  289.8000  560.0000  484.0000];
ax = gca;
ax.Position = [0.1500    0.1100    0.7    0.8];
% 画圆形边框；
circle_center = [0 0];
R = 0.265;
t = 0:0.01:2*pi+0.01;
x = R*cos(t);
y = R*sin(t);
plot(x,y,'k','LineWidth',2);
% pause();
    end
end