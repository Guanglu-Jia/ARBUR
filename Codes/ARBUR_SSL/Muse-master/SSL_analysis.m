%% 置信度计算与评估
% source_estimated 中包含nX5 个预测位置，根据这些位置，计算SSL置信度；
% 其中第一列为采用4个麦克风的预测结果，后四列均为采用3个麦克风的预测结果；
% 

% 估计概率密度
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
    end
end
ssl_confidence = ssl_confidence';

% ssl_position = (ssl_position-[size(z,1),size(z,2)]/2)/(size(z,2)/2)*.52/2;
% ssl_position(:,2) = ssl_position(:,2)*-1;
% ssl_position = ssl_position*[ cos(pi/2) -sin(pi/2);sin(pi/2) cos(pi/2)]*1000;
%%
USV_num_all = [181,2,10,8,8,6,24,32,6,3,13,620,43,8,5,20,4,23,184,96,25,2,6,103,130];
load('SSL_position_17.mat');
ssl_position_temp = ssl_position(ssl_confidence>0.7,:);
% ssl_position_temp_1 = ssl_position;
% ssl_position_temp_1(ssl_confidence==0,:) = [0 0];
% = USV_num_all(1:18))+1:sum(USV_num_all(1:19));
ssl_position_temp = ssl_position(sum(USV_num_all(1:18))+1:sum(USV_num_all(1:19)),:);
ssl_position_temp = ssl_position(sum(USV_num_all(1:2))+1:sum(USV_num_all(1:3)),:);
% ssl_position_temp = ssl_position(sum(USV_num_all(1:15))+1:sum(USV_num_all(1:16)),:);


% ssl_position_temp = [51 80];
ssl_position = flip(ssl_position_temp,2);
% ssl_position(:,1) = 100-ssl_position(:,1);
ssl_position = (ssl_position-[50,50])/(50)*.50/2*1000;
% ssl_position(:,2) = ssl_position(:,2)*-1;
theta = 90/180*pi;
ssl_position = ssl_position*[ cos(theta) -sin(theta);sin(theta) cos(theta)];

figure;
scatter(ssl_position(:,1),ssl_position(:,2));
axis([-260 260 -260 260])

% nose_position = [-81, -100];
nose_position = [50,-220];
% nose_position = [-125,-109];
theta = -00/180*pi;
nose_position = nose_position*[ cos(theta) -sin(theta);sin(theta) cos(theta)];
hold on;
scatter(nose_position(1),nose_position(2));
a_temp = ssl_position-nose_position;
find(sqrt((a_temp(:,1).^2+a_temp(:,2).^2))<50)
%% day 14_01
USV_num_all = [181,2,10,8,8,6,24,32,6,3,13,620,43,8,5,20,4,23,184,96,25,2,6,103,130];
% load('SSL_position_17.mat');
% ssl_position_temp = ssl_position(ssl_confidence>0.7,:);
% ssl_position_temp_1 = ssl_position;
% ssl_position_temp_1(ssl_confidence==0,:) = [0 0];
% = USV_num_all(1:18))+1:sum(USV_num_all(1:19));
% ssl_position_temp = ssl_position(sum(USV_num_all(1:18))+1:sum(USV_num_all(1:19)),:);
% ssl_position_temp = ssl_position(sum(USV_num_all(1:2))+1:sum(USV_num_all(1:4)),:);
% ssl_position_temp = ssl_position(sum(USV_num_all(1:15))+1:sum(USV_num_all(1:16)),:);
% ssl_position = ssl_positionCopy;
ssl_position_temp = ssl_position;

% ssl_position_temp = [51 80];
ssl_position = flip(ssl_position_temp,2);
% ssl_position(:,1) = 100-ssl_position(:,1);
ssl_position = (ssl_position-[50,50])/(50)*.50/2*1000;
% ssl_position(:,2) = ssl_position(:,2)*-1;
theta = 0/180*pi;
ssl_position = ssl_position*[ cos(theta) -sin(theta);sin(theta) cos(theta)];

figure;
scatter(ssl_position(:,1),ssl_position(:,2));
axis([-260 260 -260 260])

% nose_position = [-81, -100];
nose_position = [50,-220];
% nose_position = [-125,-109];
theta = -90/180*pi;
nose_position = nose_position*[ cos(theta) -sin(theta);sin(theta) cos(theta)];
hold on;
scatter(nose_position(1),nose_position(2));
a_temp = ssl_position-nose_position;
find(sqrt((a_temp(:,1).^2+a_temp(:,2).^2))<50)
%% 
filename = 'G:\Contributed Papers\To be submitted\9-PNAS\ARBUR_SSL\1114-part-world3d.csv';
filename = 'Z:\USV_datasets\voice-image\1114\seq01.12\match_point\current\01\world3d-111401-one.csv';
filename = 'Z:\USV_datasets\voice-image\1114\seq01.12\match_point\current\03\world3d-111403-one.csv';
filename = 'Z:\USV_datasets\voice-image\1114\seq01.12\match_point\current\07\world3d-111407-one.csv';
filename = 'Z:\USV_datasets\voice-image\1114\seq01.12\match_point\current\09\world3d-111409-one.csv';

delimiter = ',';
formatSpec = '%s%s%s%s%s%s%s%[^\n\r]';

fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
fclose(fileID);
partworld3d = [dataArray{1:end-1}];
clearvars filename delimiter formatSpec fileID dataArray ans;

nose_ = zeros(size(partworld3d,1)-1,7);
for i = 1:size(nose_,1)
    temp = strsplit(partworld3d(i+1,1),'_');
    nose_(i+1,1) = str2num(char(temp(4)));
    if (partworld3d(i+1,2)) ~= "NaN"
        nose_(i+1,2) = str2num(partworld3d{i+1,2});
        nose_(i+1,3) = str2num(partworld3d{i+1,3});
        nose_(i+1,4) = str2num(partworld3d{i+1,4});
    end
    
    if (partworld3d(i+1,5)) ~= "NaN"
        nose_(i+1,5) = str2num(partworld3d{i+1,5});
        nose_(i+1,6) = str2num(partworld3d{i+1,6});
        nose_(i+1,7) = str2num(partworld3d{i+1,7});        
    end    
    
end
% 鼠的鼻尖点的三维坐标
nose_(1,:) = [];

nose_(find(nose_(:,3)>500),2:4) = 0;
nose_(find(nose_(:,3)>500),2:4) = 0;
nose_(find(nose_(:,6)>500),5:6) = 0;
%%
% 计算估计的点与实际鼻尖点的距离
distance_1 = 0;
for i = 1:size(nose_,1)
    if sum(nose_(i,2:4))~=0
        distance_1(i) = norm(ssl_position(i,:)-nose_(i,2:3));
        if sum(nose_(i,5:7))~=0
            distance_2(i) = norm(ssl_position(i,:)-nose_(i,5:6));
            
            distance_1(i) = min(distance_1(i),distance_2(i));
        end
    elseif sum(nose_(i,5:7))~=0
        distance_1(i) = norm(ssl_position(i,:)-nose_(i,5:6));
    end
    
end

figure;
histogram(distance_1);

ssl_ind = find(distance_1<70);

temp_ = ssl_ind(find(ssl_confidence(ssl_ind)>0.6));
ssl_ind_output = nose_(temp_,1);

distance_1(find(nose_(:,1)==1793))
%% 
% PDF vs. CI
f = figure("Color","white");
ssl_confidence_temp = ssl_confidence(ssl_confidence>0);
h = histogram(ssl_confidence_temp,'binwidth',0.05,'Normalization','pdf');
xlabel("Confidence Index");

sum(ssl_confidence>0.70)/sum(ssl_confidence>0)
sum(ssl_confidence(seg.max_intensity(1:length(source_estimated_all))>25)>0.70)/sum(ssl_confidence(seg.max_intensity(1:length(source_estimated_all))>25)>0)
f = figure("Color","white");
f = figure("Color","White");
% f.InnerPosition = [201   711   809   219];
% plot(((1:length(line_e_10))-.5)/bin_num,line_e_10);
hold on;
line_e_10 = h.Values;
for i = 1:length(line_e_10)
    if ~isnan(line_e_10(i))
%     fi = fill(([0.5 1.5 1.5 0.5]+i-1.5),[0 0 line_e_10(i) line_e_10(i)],confusion_cm(round(line_e_10(i)*101),:));
    fi = fill(([0.5 1.5 1.5 0.5]+i-1.5),[0 0 line_e_10(i) line_e_10(i)],confusion_cm(i*5,:));
    fi.FaceAlpha = .8;
    end
end
ax = gca;
ax.TickDir = 'out';
 box off
ax2 = axes('Position',get(gca,'Position'),...
           'XAxisLocation','top',...
           'YAxisLocation','right',...
           'Color','none',...
           'XColor','k','YColor','k');
set(ax2,'YTick', []);
set(ax2,'XTick', []);
box on

%% 绘制累计概率曲线
h = histogram(ssl_confidence_temp,'binwidth',0.01,'Normalization','pdf');
probability = zeros(1,length(h.BinCounts));
h.BinCounts = flip(h.BinCounts);
for i = 1:length(h.BinCounts)
    probability(i) = sum(h.BinCounts(1:i))/sum(h.BinCounts);
end
f = figure("Color","white");
f.InnerPosition = [212   555   393   312];
plot(0:0.01:1,[0,probability],'LineWidth',2,'Color',[0 0 0]);
ax = gca;
ax.XTickLabel = 1:-0.2:0;
xlabel("Confidence Index");
ylabel("Cumulative probability");
hold on;
plot([.4 .4],[0 .761],'r','LineWidth',2);
plot([0 .4],[.761 .761],'r','LineWidth',2);
ax = gca;
ax.TickDir = 'out';
 box off
ax2 = axes('Position',get(gca,'Position'),...
           'XAxisLocation','top',...
           'YAxisLocation','right',...
           'Color','none',...
           'XColor','k','YColor','k');
set(ax2,'YTick', []);
set(ax2,'XTick', []);
box on

%% USV maximum intensity vs. CI
% 制作colormap confusion_cm;
cm_top = [9 49 108];
cm_down = [200 150 220];
cm_num = 100;
confusion_cm = round([cm_down(1):-((cm_down(1)-cm_top(1))/cm_num):cm_top(1);cm_down(2):-((cm_down(2)-cm_top(2))/cm_num):cm_top(2);...
                cm_down(3):-((cm_down(3)-cm_top(3))/cm_num):cm_top(3);]')/255;
            
f = figure("Color","white");
colormap(confusion_cm);

ssl_confidence_temp = ssl_confidence(ssl_confidence>0);

[a b] = sort(seg.max_intensity(1:length(source_estimated_all)));
[a b] = sort(ssl_confidence_temp);
temp = seg.max_intensity(1:length(source_estimated_all))+rand(1,length(source_estimated_all))'-0.5;
temp = temp(ssl_confidence>0)';
[a b] = sort(temp);
c = linspace(1,length(temp),length(temp));
scatter(temp(b),ssl_confidence_temp(b),100,c,'.');
box on;
% scatter(rand(181,1),rand(181,1),[],c,'.');
xlabel("USV maximum intensity");
ylabel("Confidence Index");

%% CI > 0.6 (%) vs. USV max intensity
bin_num = 13;
bin_res = 65/bin_num;
line_e_10 = zeros(bin_num,1);
for i = 1:length(line_e_10)
    line_e_10(i) = sum(ssl_confidence_temp>0.6 & temp>i*bin_res-bin_res & temp<i*bin_res) ...
        /sum(temp>i*bin_res-bin_res & temp<i*bin_res);
end
f = figure("Color","White");
f.InnerPosition = [201   711   809   219];
% plot(((1:length(line_e_10))-.5)/bin_num,line_e_10);
hold on;
for i = 1:length(line_e_10)
    if ~isnan(line_e_10(i))
%     fi = fill(([0.5 1.5 1.5 0.5]+i-1.5),[0 0 line_e_10(i) line_e_10(i)],confusion_cm(round(line_e_10(i)*101),:));
    fi = fill(([0.5 1.5 1.5 0.5]+i-1.5),[0 0 line_e_10(i) line_e_10(i)],confusion_cm(i*6,:));
    fi.FaceAlpha = .8;
    end
end
xlabel("USV maximum intensity");
ylabel("CI > 0.6 (%)");
box on;
axis([3 13 0 1]);

%%  histogram: 最大信号强度
h = histogram(seg.max_intensity,'Normalization','pdf');
f = figure("Color","White");
% f.InnerPosition = [201   711   809   219];
% plot(((1:length(line_e_10))-.5)/bin_num,line_e_10);
hold on;
line_e_10 = h.Values;
for i = 1:length(line_e_10)
    if ~isnan(line_e_10(i))
%     fi = fill(([0.5 1.5 1.5 0.5]+i-1.5),[0 0 line_e_10(i) line_e_10(i)],confusion_cm(round(line_e_10(i)*101),:));
    fi = fill(([0.5 1.5 1.5 0.5]+i-1.5),[0 0 line_e_10(i) line_e_10(i)],confusion_cm(i*5,:));
    fi.FaceAlpha = .8;
    end
end
box on;
axis([-1 19 0 0.035]);
%%
f = figure("Color","white");
z_max_value_all_temp = z_max_value_all(ssl_confidence>0);
h = histogram(z_max_value_all_temp,'binwidth',5,'Normalization','pdf');
xlabel("USV maximum probability density");
axis([10 100 0 .03]);

f = figure("Color","White");
% f.InnerPosition = [201   711   809   219];
% plot(((1:length(line_e_10))-.5)/bin_num,line_e_10);
hold on;
line_e_10 = h.Values;
for i = 1:length(line_e_10)
    if ~isnan(line_e_10(i))
%     fi = fill(([0.5 1.5 1.5 0.5]+i-1.5),[0 0 line_e_10(i) line_e_10(i)],confusion_cm(round(line_e_10(i)*101),:));
    fi = fill(([0.5 1.5 1.5 0.5]+i-1.5),[0 0 line_e_10(i) line_e_10(i)],confusion_cm(i*6,:));
    fi.FaceAlpha = .8;
    end
end
box on;
% axis([0 16 0 210]);

%% Maximum probability density vs. CI
f = figure("Color","white");
[a b] = sort(seg.max_intensity(1:length(source_estimated_all)));
[a b] = sort(z_max_value_all_temp);
% [a b] = sort(ssl_confidence_temp);
colormap(confusion_cm);
scatter(z_max_value_all_temp(b),ssl_confidence_temp(b),100,c,'.');
xlabel("Maximum probability density");
ylabel("Confidence Index");
box on;

%% CI > 0.6 (%) vs. Max probability density
bin_num = 9;
bin_res = 90/bin_num;
line_e_10 = zeros(bin_num,1);
for i = 1:length(line_e_10)
    line_e_10(i) = sum(ssl_confidence_temp>0.6 & z_max_value_all_temp>i*bin_res-bin_res & z_max_value_all_temp<i*bin_res) ...
        /sum(z_max_value_all_temp>i*bin_res-bin_res & z_max_value_all_temp<i*bin_res);
end
f = figure("Color","White");
f.InnerPosition = [201   711   809   219];
% plot(((1:length(line_e_10))-.5)/bin_num,line_e_10);
hold on;
for i = 1:length(line_e_10)
    fi = fill(([0.5 1.5 1.5 0.5]+i-1.5),[0 0 line_e_10(i) line_e_10(i)],confusion_cm(i*11,:));
    fi.FaceAlpha = .8;
end
xlabel("Max probability density");
ylabel("CI > 0.6 (%)");
box on;
axis([1 9 0 1]);
%%
[a b] = sort(z_max_value_all_temp);
f = figure("Color","white");
colormap(confusion_cm);
scatter(temp(b),z_max_value_all_temp(b),100,c,'.');

%%

%% 绘制SSL估计结果的概率分布密度图
% figure
% surf(axarg{:},xq,yq,z);
% [z_max_x_3(1),z_max_y_3(1)];
% temp = z_max_x_3(1);
% z_max_x_3(1) = z_max_y_3(1);
% z_max_y_3(1) = temp;
% [z_max_x(1),z_max_y(1)];
% temp = z_max_x(1);
% z_max_x(1) = z_max_y(1);
% z_max_y(1) = temp;

f1 = figure('Color','white');
% colormap jet

hold on;

% surf(z');
im = imagesc(z);
% im.AlphaData = .5;
% im2 = imagesc(z_4);
% im2.AlphaData = .5;
colorbar
title("SSL with 3 mics");
axis([ 0 100 0 100]);
plot([z_max_x_3(1)-10,z_max_x_3(1)+10],[z_max_y_3(1),z_max_y_3(1)],'r','LineWidth',2);
plot([z_max_x_3(1),z_max_x_3(1)],[z_max_y_3(1)-10,z_max_y_3(1)+10],'r','LineWidth',2);

f2 = figure('Color','white');
hold on;

% surf(z');
imagesc(z_4);

plot([z_max_x(1)-10,z_max_x(1)+10],[z_max_y(1),z_max_y(1)],'r','LineWidth',2);
plot([z_max_x(1),z_max_x(1)],[z_max_y(1)-10,z_max_y(1)+10],'r','LineWidth',2);

colorbar
title("SSL with 4 mics");
axis([ 0 100 0 100]);

