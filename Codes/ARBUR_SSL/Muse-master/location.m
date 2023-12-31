close all;
clc;
clear;
load('F:\9-PNAS\ssl_1114.mat')

% 将信号按时间分割；每5 ms一段时间，然后输出每小段信号的五个估计位置；
mini_seg_duration = 5; % ms;
mini_seg_stride = 5; % ms；

rat_nose_height = 0.25; % m
% filename_1 = 'Z:\USV_datasets\data10.13\ch1\T0000001.wav';
% filename_2 = 'Z:\USV_datasets\data10.13\ch2\T0000001.wav';
% filename_3 = 'Z:\USV_datasets\data10.13\ch3\T0000001.wav';
% filename_4 = 'Z:\USV_datasets\data10.13\ch4\T0000001.wav';
num = 45;
file_path = 'F:\USV\11.14\seq\ch1\';
if num<10
filename_1 = char("F:\9-PNAS\ch1_2022-11-14_20-48-00_01\ch1_2022-11-14_20-48-00_01_000"+num+".wav");
filename_2 = char("F:\9-PNAS\ch2_2022-11-14_20-48-00_01\ch2_2022-11-14_20-48-00_01_000"+num+".wav");
filename_3 = char("F:\9-PNAS\ch3_2022-11-14_20-48-00_01\ch3_2022-11-14_20-48-00_01_000"+num+".wav");
filename_4 = char("F:\9-PNAS\ch4_2022-11-14_20-48-00_01\ch4_2022-11-14_20-48-00_01_000"+num+".wav");
elseif num<100
filename_1 = char("F:\9-PNAS\ch1_2022-11-14_20-48-00_01\ch1_2022-11-14_20-48-00_01_00"+num+".wav");
filename_2 = char("F:\9-PNAS\ch2_2022-11-14_20-48-00_01\ch2_2022-11-14_20-48-00_01_00"+num+".wav");
filename_3 = char("F:\9-PNAS\ch3_2022-11-14_20-48-00_01\ch3_2022-11-14_20-48-00_01_00"+num+".wav");
filename_4 = char("F:\9-PNAS\ch4_2022-11-14_20-48-00_01\ch4_2022-11-14_20-48-00_01_00"+num+".wav");    
    
end

Fs=250000;  % Hz

time_resolution = Fs/1000;

seg_duration = ssl.time_end(num)-ssl.time_init(num); % ms


[y_1,Fs_1] = audioread(filename_1);
[y_2,Fs_2] = audioread(filename_2);
[y_3,Fs_3] = audioread(filename_3);
[y_4,Fs_4] = audioread(filename_4);

[y_1_1,Fs_1] = audioread(filename_1);
% if length(y_1_1)<=0.05*Fs
%     samples = [max(1/Fs,round(((find(y_1_1==max(y_1_1))/Fs)*1000-5)*Fs/1000)),...
%     min(round(((find(y_1_1==max(y_1_1))/Fs)*1000+5)*Fs/1000),length(y_1_1))];
%     samples = [round(length(y_1_1)/2-750),round(length(y_1_1)/2+750)];
time_init = max(1,(ssl.time_init(num)+0)*time_resolution);
time_end = min(length(y_1),(ssl.time_end(num)-0)*time_resolution);
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

Y_fft_temp = fft(y_1);% 前
Y_fft = abs(Y_fft_temp(1:length(Y_fft_temp)/2)); % 对应 0:125 kHz
per_kHz = length(Y_fft)/125;
freq_resolution = per_kHz;
% 前15 kHz和 100 kHz-125 kHz置为0；
Y_fft(1:15*per_kHz) = 0;
Y_fft(100*per_kHz:end) = 0;
% plot(Z) 
[ma, I]=max(Y_fft);   %ma涓烘暟缁勭殑鏈?澶у?硷紝I涓轰笅鏍囧??
f_max=floor(I/per_kHz*1000);

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
xl=[-0.25 +0.25];
yl=[-0.25 +0.25];

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
R4_z=0.5;

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
      
      
% 对时间窗口做拆分，每5 ms一个窗口，用四个麦克风的信息输出定位结果；
% 如一个信号总时长17 ms，则拆分成4个窗口，0-5,5-10,10-15,12-17，结合总窗口数据一共得到5个定位结果。

      
      
%% 4閫氶亾
v_1234=[y_1,y_2,y_3,y_4];
verbosity=1;
R=[ R1_x R1_y R1_z ; ...
    R2_x R2_y R2_z ; ...
    R3_x R3_y R3_z ; ...
   R4_x R4_y R4_z]';  % m

% estimate the mouse position with the true mic positions
[r_est_1234,rsrp_max_1234,rsrp_grid,a,vel,N_filt,V_filt,V]= ...
  r_est_from_clip_simplified(v_1234,Fs, ...
                             f_lo,f_hi, ...
                             Temp, ...
                             x_grid,y_grid,in_cage, ...
                             R, ...
                             verbosity);

% make a figure of that
[fig_h,axes_h,axes_cb_h]= ...
  figure_objective_map(x_grid,y_grid,rsrp_grid, ...
                       'jet', ...
                       [], ...
                       'Estimate with true mic positions', ...
                       'RSRP (V^2)', ...
                       clr_mike, ...
                       [1 1 1], ...
                       r_est_1234,[], ...
                       R,r_est_1234,r_est_1234+[-0.08 0]');

%% 3_1閫氶亾-234
v_234=[y_2,y_3,y_4];
verbosity=0;
R=[ 
    R2_x R2_y R2_z ; ...
    R3_x R3_y R3_z ; ...
   R4_x R4_y R4_z]';  % m

% estimate the mouse position with the true mic positions
[r_est_234,rsrp_max_234,rsrp_grid,a,vel,N_filt,V_filt,V]= ...
  r_est_from_clip_simplified(v_234,Fs, ...
                             f_lo,f_hi, ...
                             Temp, ...
                             x_grid,y_grid,in_cage, ...
                             R, ...
                             verbosity);

% make a figure of that
[fig_h,axes_h,axes_cb_h]= ...
  figure_objective_map(x_grid,y_grid,rsrp_grid, ...
                       'jet', ...
                       [], ...
                       'Estimate with true mic positions', ...
                       'RSRP (V^2)', ...
                       clr_mike, ...
                       [1 1 1], ...
                       r_est_234,[], ...
                       R,r_est_234,r_est_234+[-0.08 0]');
%% 3_2閫氶亾-134
v_134=[y_1,y_3,y_4];
verbosity=0;
R=[ 
    R1_x R1_y R1_z ; ...
    R3_x R3_y R3_z ; ...
   R4_x R4_y R4_z]';  % m

% estimate the mouse position with the true mic positions
[r_est_134,rsrp_max_134,rsrp_grid,a,vel,N_filt,V_filt,V]= ...
  r_est_from_clip_simplified(v_134,Fs, ...
                             f_lo,f_hi, ...
                             Temp, ...
                             x_grid,y_grid,in_cage, ...
                             R, ...
                             verbosity);

% make a figure of that
[fig_h,axes_h,axes_cb_h]= ...
  figure_objective_map(x_grid,y_grid,rsrp_grid, ...
                       'jet', ...
                       [], ...
                       'Estimate with true mic positions', ...
                       'RSRP (V^2)', ...
                       clr_mike, ...
                       [1 1 1], ...
                       r_est_134,[], ...
                       R,r_est_134,r_est_134+[-0.08 0]');
%% 3_3閫氶亾-124
v_124=[y_1,y_2,y_4];
verbosity=0;
R=[ R1_x R1_y R1_z ; ...
    R2_x R2_y R2_z ; ...
   R4_x R4_y R4_z]';  % m

% estimate the mouse position with the true mic positions
[r_est_124,rsrp_max_124,rsrp_grid,a,vel,N_filt,V_filt,V]= ...
  r_est_from_clip_simplified(v_124,Fs, ...
                             f_lo,f_hi, ...
                             Temp, ...
                             x_grid,y_grid,in_cage, ...
                             R, ...
                             verbosity);

% make a figure of that
[fig_h,axes_h,axes_cb_h]= ...
  figure_objective_map(x_grid,y_grid,rsrp_grid, ...
                       'jet', ...
                       [], ...
                       'Estimate with true mic positions', ...
                       'RSRP (V^2)', ...
                       clr_mike, ...
                       [1 1 1], ...
                       r_est_124,[], ...
                       R,r_est_124,r_est_124+[-0.08 0]');
%% 3_4閫氶亾-123
v_123=[y_1,y_2,y_3];
verbosity=0;
R=[ R1_x R1_y R1_z ; ...
    R2_x R2_y R2_z ; ...
   R3_x R3_y R3_z]';  % m

% estimate the mouse position with the true mic positions
[r_est_123,rsrp_max_123,rsrp_grid,a,vel,N_filt,V_filt,V]= ...
  r_est_from_clip_simplified(v_123,Fs, ...
                             f_lo,f_hi, ...
                             Temp, ...
                             x_grid,y_grid,in_cage, ...
                             R, ...
                             verbosity);

% make a figure of that
[fig_h,axes_h,axes_cb_h]= ...
  figure_objective_map(x_grid,y_grid,rsrp_grid, ...
                       'jet', ...
                       [], ...
                       'Estimate with true mic positions', ...
                       'RSRP (V^2)', ...
                       clr_mike, ...
                       [1 1 1], ...
                       r_est_123,[], ...
                       R,r_est_123,r_est_123+[-0.08 0]');
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
scatter(r_est_1234(1),r_est_1234(2),'o','r','filled');
scatter(r_est_234(1),r_est_234(2),'o','filled');
scatter(r_est_134(1),r_est_134(2),'o','filled');
scatter(r_est_124(1),r_est_124(2),'o','filled');
scatter(r_est_123(1),r_est_123(2),'o','filled');
scatter(R(1,:),R(2,:),'o','k','filled');
axis([-0.27 0.27 -0.27 .27]);
title("SSL results from seg: "+ num+"; Rat nose height: "+rat_nose_height*100+" cm;"...
    +" Time: "+samples(1)/time_resolution+"-"+samples(2)/time_resolution+ "ms");
f.InnerPosition = [785.0000  289.8000  560.0000  484.0000];
ax = gca;
ax.Position = [0.1500    0.1100    0.7    0.8];
% 画圆形边框；
circle_center = [0 0];
R = 0.255;
t = 0:0.01:2*pi+0.01;
x = R*cos(t);
y = R*sin(t);
plot(x,y,'k','LineWidth',2);

