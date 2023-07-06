function [r_est,rsrp_max,rsrp_grid,a,vel,N_filt,V_filt,V,rsrp_per_pair_grid]= ...
  r_est_from_clip_simplified(v,fs, ...
                             f_lo,f_hi, ...
                             Temp, ...
                             x_grid,y_grid,in_cage, ...
                             R, ...
                             verbosity)

% r_est_from_clip_simplified --- Estimate sound source location from microphone array data
%
%   This is the core function of Muse.  It takes the voltage signals from the
%   microphone array, and outputs an estimated sound source location.
%
%   [r_est,rsrp_max,rsrp_grid,a,vel,N_filt,V_filt,V,rsrp_per_pair_grid]= ...
%       r_est_from_clip_simplified(v,fs, ...
%                                  f_lo,f_hi, ...
%                                  Temp, ...
%                                  x_grid,y_grid,in_cage, ...
%                                  R, ...
%                                  verbosity)
%
%   Inputs:
%       v: An N x K array of microphone signals, N the number of time
%          points, K the number of microphones.
%       fs: The sampling frequency of the audio data, in Hz.
%       f_lo: The lower bound of the frequency band used for analysis, in
%             Hz.  Frequency compenents outside this band are zeroed after
%             the data is intially FFT'ed.用于分析的频带下限，单位为Hz�?
%       f_hi: The upper bound of the frequency band used for analysis, in
%             Hz.用于分析的频带上限，
%       Temp: The ambient temperature at which data was taken, in degrees
%             celsius.
%       x_grid: The reduced steered response power (RSRP) is calculated at
%               every point on a grid.  This gives the x-coordinate of each
%               point on the grid.  It is a 2D array.
%               �?化的导向响应功率(RSRP)在网格上的每�?点上计算。这给出了网格上每个点的x坐标。它是一�?2D数组�?
%       y_grid: A 2D array of the same shape as x_grid, giving the
%               y-coordinate of each point at which RSRP is to be
%               calculated.  The points indicated by x_grid and y_grid are
%               assumed to be in a Cartesian coordinate system.
%       in_cage: A logical array of the same size as x_grid, indicating
%                which grid points are in the interior of the cage.  In
%                theory, the RSRP would only be calculated at these points.
%                In reality, this argument is not used.
%       R: The microphone positions in 3D space, a 3 x K array, in meters,
%          in a standard right-handed Cartesian coordinate system. Positive
%          z coordinates are assumed to be above the plane of the x_grid,
%          y_grid points.
%          麦克风的位置�?3D空间中，�?�?3 x K阵列，单位为米，在一个标准的右手笛卡尔坐标系中�?�正z坐标假设在x_grid, y_grid点的平面之上�?
%       verbosity: An integer indicating how much information about
%                  intermediate computations should be output to the
%                  console and/or figures.  A value of 0 indicates no
%                  output, higher values indicate more output.
%
%   Outputs:
%       r_est: A 2 x 1 array giving the estimated position of the sound
%              source.提供声源估计位置�?2 x 1阵列
%       rsrp_max: The value of the RSRP at r_est.  This will have units of
%                 arbs^2, if v is in arbs.r_est处的RSRP值�?�如果v在arbs中，则其单位为arbs ^2�?
%       rsrp_grid: A 2D array of the same shape as x_grid, giving the RSRP
%                  at every point in the grid.  rsrp_max gives the largest
%                  value in rsrp_grid, and r_est the (x,y) point at which
%                  this value occurs.  This will have units of
%                 arbs^2, if v is in arbs.
%与x_grid形状相同�?2D数组，给出网格中每个点的RSRP。rsrpmax给出了rsrpgrid中的�?大�?�，rest是该值出现的（x，y）点�?
%       a: A 1 x K array of values that estimates the gain of each
%          microphone, in same units as v.�?�?1 x K值数组，估计每个%麦克风的增益，单位与v相同�?
%       vel: The speed of sound in air used in the calculation, as computed
%            from Temp.  In m/s.计算中使用的空气中的声�?�，根据温度（单位：m/s）计�?%
%       N_filt: The number of frequency values in the passband of the
%               band-pass filter, given f_lo, f_hi, and (implicit) spacing
%               between frequency samples used.
%给定f_lo、f_hi和所用频率样本之间的（隐式）间隔，带通滤波器通带中的频率值数目�??
%       V_filt: The FFT of the values in v, after band-pass filtering, in
%               the same units as v.带�?�滤波后，v值的FFT，单�?%与v相同�?
%       V: The FFT of the values in v, *before* band-pass filtering, in the
%          same units as v.带�?�滤波前，v中的值的FFT，单位与v相同�?
%       rsrp_per_pair_grid: A 3D array, Nx x Ny x Npairs, where Nx x Ny is
%                           the size of x_grid, and Npairs is the number of
%                           unordered pairs of microphones, not including
%                           self-pairs (K*(K-1)/2).  This contains the RSRP
%                           calculated for each microphone pair.  Summing
%                           rsrp_per_pair_grid across pages yields
%                           rsrp_grid.  This will have units of arbs^2, if
%                           v is in arbs.  The function
%                           mixing_matrix_from_n_mics(K) can be used to
%                           determine which pair corresponds to which
%                           microphones.
%3D阵列，Nx x Ny x N对，其中Nx x N是x_grid的大小，N对是无序话筒对的数量，不包括自对（K*（K-1�?/2）�??
% 其中包含为每对话筒计算的RSRP。对页面上的rsrp_per_pair_grid求和得到rsrp_grid�?
% 如果v在arbs中，则其单位为arbs ^2�?
% mixing_matrix_from_n_mics（K）函数可用于确定哪对话筒对应哪一对话筒�??
% calculate SSE at each grid point                
[rsrp_grid,a,vel,N_filt,V_filt,V,rsrp_per_pair_grid]= ...
  rsrp_grid_from_clip_and_xy_grids(v,fs, ...
                                   f_lo,f_hi, ...
                                   Temp, ...
                                   x_grid,y_grid, ...
                                   R, ...
                                   verbosity);
                               
rsrp_grid = rsrp_grid.*in_cage;
% rsrp_grid=medfilt2(rsrp_grid,round(size(x_grid)/10));
% find the min-sse point within the cage bounds在cage边界内找到min-sse�?
%[r_est,sse_min]=argmin_grid(x_grid,y_grid,sse_grid,in_cage);
[r_est,rsrp_max]=argmax_grid(x_grid,y_grid,rsrp_grid);  
%返回网格上目标函数最大化的点
  % ignore cage bounds, b/c sometimes they don't help, they hurt忽略笼子界限，b/c有时它们没有帮助，它们会伤害

end
