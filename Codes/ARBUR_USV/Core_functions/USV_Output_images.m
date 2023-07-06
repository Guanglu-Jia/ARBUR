function USV_Output_images(seg,num)
x_gap = 0.005;
y_gap = 0.01;
time_resolution = .5;
save_name = 'Results\demo_USV_label';
load record_name

USV_14 = [2118,358,1402,545,6,511,1808,176,1847,837,161,1112,2213,1065,41,1151,82,7,35,103,20,21,80,467,10];
USV_16 = [3370,203,2850,1481,1367,661,676,216,75,26,1628,1802,1109,244,1472,575,1089,158,410,208,80,32,1272,469,637,223];
USV_17 = [181,2,10,8,8,6,24,32,6,3,13,620,43,8,5,20,4,23,184,96,25,2,6,103,130];
USV_18 = [1264,856,10,4,12,4,14,6,1,13,63,230,4,7,1,39,11,496,1,28,50,14,85,12,8,53];
vec_1 = string([14 16 17 18]);
USV_all = [USV_14,USV_16,USV_17,USV_18];

for i = 1:length(USV_all)
   USV_sum(i) = sum(USV_all(1:i));
end

USV_temp = [length(USV_14),length(USV_16),length(USV_17),length(USV_18)];
for i = 1:4
   USV_day(i) = sum(USV_all(1:sum(USV_temp(1:i))));
   USV_temp_day(i) = sum(USV_temp(1:i));
end


colormap jet;
f = figure("color","white");
% f.InnerPosition = [217   622   313   197];
for i = 1:num
    if seg.cluster(i)>0
       seg.data_processed{i}=medfilt2(seg.data{i},[3,5]);
%        seg.data_processed{num_plot(i,j)}((seg.data_processed{num_plot(i,j)}<10)) = 0;
       seg.data_processed{i}= medfilt2(seg.data_processed{i},[3,5]);
       seg.data_processed{i} = seg.data_processed{i}(:,seg.time_min(i)/time_resolution-2:(seg.duration(i)*2+seg.time_min(i)/time_resolution+2));
%        seg.data_processed{num_plot(i,j)} = seg.data_processed{num_plot(i,j)}(:,20:end-20);
%        temp = seg.data_processed{num_plot(i,j)}(double(seg.freq_min(num_plot(i,j)))*2-double(seg.freq_range(num_plot(i,j)))*2-5:double(seg.freq_min(num_plot(i,j)))*2+15,:);
%         temp = seg.data_processed{i}(round(256-seg.freq_min(num_plot(i,j))*2-seg.freq_range(num_plot(i,j))*2)-5:round(256-seg.freq_min(num_plot(i,j))*2)+5,:);
        
        % 22kHz
        if seg.cluster(i)>60
            temp = seg.data_processed{i}(256-40*2.14:end,:);
        % 50kHz non-step
        elseif seg.cluster(i)<=10 || (seg.cluster(i)>=36 && seg.cluster(i)<=45)
            temp = seg.data_processed{i}(round(256-seg.mean_freq(i)*2.14)-20*2.14:round(256-seg.mean_freq(i)*2.14)+20*2.14,:);
        % 50kHz step
        else
            temp = seg.data_processed{i}(round(256-seg.mean_freq(i)*2.14)-20*2.14:round(256-seg.mean_freq(i)*2.14)+20*2.14,:);
        end
%         temp = seg.data_processed{i}(round(256-seg.mean_freq(i)*2.14)-15*2.14:round(256-seg.mean_freq(i)*2.14)+25*2.14,:);
        colormap jet;
       imagesc(temp);
       axis off
%        
       width_ = size(temp,2);
       height_ = size(temp,1);
       tt = text((4/100*width_),(10/100*height_),string(seg.cluster(i)),'horiz','left','color','w','fontsize',30);
       tt2 = text((98/100*width_),(90/100*height_),string(width_/2)+" ms",'horiz','right','color','w','fontsize',30); 
       ax = gca;
       ax.Position = [0, 0, ...
           1, 1 ];
       
       
       pause(0.5);
       day_= find(i<=USV_day,1);
       seg_num = find(i<=USV_sum,1)-sum(USV_temp(1:day_-1));

       file_name = "Results\USV\"+string(record_name{seg_num,day_})+"_"+num2str(i,'%04d')+"_usv.jpg";
       saveas(f, char(file_name));
       USV_label(i,1) = string(record_name{seg_num,day_})+"_"+num2str(i,'%04d');
       USV_label(i,2) = seg.cluster(i);

       
    end
       
end
save(save_name,"USV_label")
