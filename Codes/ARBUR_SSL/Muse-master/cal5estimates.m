function [r_est_1234,r_est_234,r_est_134,r_est_124,r_est_123]= cal5estimates(y_1,y_2,y_3,y_4,Fs,f_lo,f_hi,Temp,x_grid,y_grid,in_cage,rat_nose_height,verbosity)
v_1234=[y_1,y_2,y_3,y_4];
% verbosity=1;
R1_x=+0.2025;
R1_y=0;
R1_z=0.5-rat_nose_height;

R2_x=0;
R2_y=-0.2025;
R2_z=0.5-rat_nose_height;

R3_x=-0.2025;
R3_y=0;
R3_z=0.5-rat_nose_height;

R4_x=0;
R4_y=+0.2025;
R4_z=0.5-rat_nose_height;

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
% [fig_h,axes_h,axes_cb_h]= ...
%   figure_objective_map(x_grid,y_grid,rsrp_grid, ...
%                        'jet', ...
%                        [], ...
%                        'Estimate with true mic positions', ...
%                        'RSRP (V^2)', ...
%                        clr_mike, ...
%                        [1 1 1], ...
%                        r_est_1234,[], ...
%                        R,r_est_1234,r_est_1234+[-0.08 0]');

%% 3_1通道-234
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
% [fig_h,axes_h,axes_cb_h]= ...
%   figure_objective_map(x_grid,y_grid,rsrp_grid, ...
%                        'jet', ...
%                        [], ...
%                        'Estimate with true mic positions', ...
%                        'RSRP (V^2)', ...
%                        clr_mike, ...
%                        [1 1 1], ...
%                        r_est_234,[], ...
%                        R,r_est_234,r_est_234+[-0.08 0]');
%% 3_2通道-134
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
% [fig_h,axes_h,axes_cb_h]= ...
%   figure_objective_map(x_grid,y_grid,rsrp_grid, ...
%                        'jet', ...
%                        [], ...
%                        'Estimate with true mic positions', ...
%                        'RSRP (V^2)', ...
%                        clr_mike, ...
%                        [1 1 1], ...
%                        r_est_134,[], ...
%                        R,r_est_134,r_est_134+[-0.08 0]');
%% 3_3通道-124
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
% [fig_h,axes_h,axes_cb_h]= ...
%   figure_objective_map(x_grid,y_grid,rsrp_grid, ...
%                        'jet', ...
%                        [], ...
%                        'Estimate with true mic positions', ...
%                        'RSRP (V^2)', ...
%                        clr_mike, ...
%                        [1 1 1], ...
%                        r_est_124,[], ...
%                        R,r_est_124,r_est_124+[-0.08 0]');
%% 3_4通道-123
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
% [fig_h,axes_h,axes_cb_h]= ...
%   figure_objective_map(x_grid,y_grid,rsrp_grid, ...
%                        'jet', ...
%                        [], ...
%                        'Estimate with true mic positions', ...
%                        'RSRP (V^2)', ...
%                        clr_mike, ...
%                        [1 1 1], ...
%                        r_est_123,[], ...
%                        R,r_est_123,r_est_123+[-0.08 0]');