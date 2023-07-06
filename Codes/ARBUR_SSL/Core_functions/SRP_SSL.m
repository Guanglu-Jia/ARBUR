function  source_estimated_all = SRP_SSL(i_input,SSL_ind,rat_nose_height_input,SB_label)

% Description:
% ---------
% Steered response power-based sound source localization
%
% Inputs:
% ---------
% i_input : indices for the selected rows of the input matrix SSL_ind
% SSL_ind : nx4 matrix that denotes the position of the n USVs
% rat_nose_height_input : the height of the rat nose detected and reconstructed visually
%
% Outputs:
% ----------
% source_estimated_all : 1xn cells that stores the estimated sound sources for n USVs;
% 						 each cell contains 9x5 2D points (possible sound sources)
%
% ----------
% Copyright (c) 2023 Beijing Institute of Technology (BIT), China.
% All rights reserved.



% default nose height
if isnan(rat_nose_height_input)
    rat_nose_height_input = 0.05;
end

Fs=250000;  % Hz
time_resolution = Fs/1000;
Temp=25;  % Degrees centigrade

source_estimated_all = [];

for ii = i_input%1:size(SSL_ind,1)

    % mini_seg_duration = 15; % ms;
    % mini_seg_stride = 3; % ms£»

    day_ = SSL_ind(ii,1);

    if day_ == 14
        load('ssl_1114.mat');
        file_path = 'DemoData\USV\USV_seq\';
        USV_num_all = [2118,358,1402,545,6,511,1808,176,1847,837,161,1112,2213,1065,41,1151,82,7,35,103,20,21,80,467,10];
    elseif day_ == 16
        load('ssl_1116.mat');
        file_path = 'DemoData\USV\USV_seq\';
        USV_num_all = [3370,203,2850,1481,1367,661,676,216,75,26,1628,1802,1109,244,1472,575,1089,158,410,208,80,32,1272,469,637,223];
    elseif day_ == 17
        load('ssl_1117.mat');
        file_path = 'DemoData\USV\USV_seq\';
        USV_num_all = [181,2,10,8,8,6,24,32,6,3,13,620,43,8,5,20,4,23,184,96,25,2,6,103,130];
    elseif day_ == 18
        load('ssl_1118.mat');
        file_path = 'DemoData\USV\USV_seq\';
        USV_num_all = [1264,856,10,4,12,4,14,6,1,13,63,230,4,7,1,39,11,496,1,28,50,14,85,12,8,53];
    end


    % sound_half_num = 1;




    % num = 57;
    % Data augmentation and steered response power-based SSL
    % for all segments of audio data
    input_index = [];
    sound_half_num = SSL_ind(ii,2);
    num_all = SSL_ind(ii,3);
    num = SSL_ind(ii,4);

    %     for half_i = 1:length(USV_num_all)-1
    %         if  num_all <= sum(USV_num_all(1))
    %             sound_half_num = 1;
    %         elseif num_all > sum(USV_num_all(1:half_i)) &&  num_all <= sum(USV_num_all(1:half_i+1))
    %             sound_half_num = half_i+1;
    %         end
    %     end
    %     if sound_half_num > 1
    %         num = num_all - sum(USV_num_all(1:sound_half_num-1));
    %     else
    %         num = num_all;
    %     end

    if ssl.freq_min(num_all)> 0
        for rat_nose_height = rat_nose_height_input %0.13

            usv_name = cell2mat(SB_label{ii,1});
            spname = split(usv_name,'_');
            new_name= [cell2mat(spname(1)),'_',cell2mat(spname(2)),'_',cell2mat(spname(3)),'_',cell2mat(spname(4))];

            filename_1 = char(file_path+"ch1\"+"ch1_2022-"+new_name+".wav");
            filename_2 = char(file_path+"ch2\"+"ch2_2022-"+new_name+".wav");
            filename_3 = char(file_path+"ch3\"+"ch3_2022-"+new_name+".wav");
            filename_4 = char(file_path+"ch4\"+"ch4_2022-"+new_name+".wav");
            disp(filename_1)
            disp(filename_2)
            disp(filename_3)
            disp(filename_4)
            %         end
            seg_duration = ssl.time_end(num_all)-ssl.time_init(num_all); % ms


            if seg_duration>=10
                mini_seg_duration = seg_duration/2; % ms;
                mini_seg_stride = seg_duration/15; % ms£»
            else
                mini_seg_duration = 5; % ms;
                mini_seg_stride = 0.5; % ms£»
            end

            % seg.max_intensity(num_all)

            [y_1_1,~] = audioread(filename_1);

            time_init = max(1,(ssl.time_init(num_all)+0)*time_resolution);
            time_end = min(length(y_1_1),(ssl.time_end(num_all)-0)*time_resolution);
            % samples = [time_init,floor(time_init+(time_end-time_init)*4/8)];
            samples = [time_init,time_end];

            [y_1_all,~] = audioread(filename_1,samples);
            [y_2_all,~] = audioread(filename_2,samples);
            [y_3_all,~] = audioread(filename_3,samples);
            [y_4_all,~] = audioread(filename_4,samples);

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

            source_estimated_all{ii} = source_estimated;

        end
    end
end