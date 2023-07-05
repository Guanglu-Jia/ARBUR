% Main script for sound source localization 
%
% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.

clear
%% load the indices of the USVs to be analysed
filename1 = 'DemoData\3D_position\world3d.csv';
filename2 = 'Results\demo_behavior_label.mat';
[SSL_ind, BT_temp] = SSL_input(filename1,filename2);
%% Steered response power-based sound source localization
% based on data augmentation
source_estimated_all = SRP_SSL([1:size(SSL_ind,1)],SSL_ind,NaN,BT_temp.SB_label);  

%% Evaluate localization confidence index and
%  Estimate the SSL result
[ssl_confidence,ssl_position] = LCI_eval(source_estimated_all);

%% Load rat noses' 3D coordinates reconstructed visually
[nose_,partworld3d] = SSL_load_noses(filename1);
%% Assigning SSL results to the vocal rat based on horizontal information
SSL_output = zeros(length(nose_),1);
SSL_threshold = 100; % mm
LCI_threshold = 0.6; 
SSL_output = SSL_assignment_2d(nose_,ssl_position,ssl_confidence,partworld3d,LCI_threshold,SSL_threshold);

%% Assigning SSL results to the vocal rat based on 3D information
SSL_output = SSL_assignment_3d(SSL_output,BT_temp,nose_,ssl_position,ssl_confidence,partworld3d,LCI_threshold,SSL_threshold);
save('Results\demo_SSL_label.mat','SSL_output');  

