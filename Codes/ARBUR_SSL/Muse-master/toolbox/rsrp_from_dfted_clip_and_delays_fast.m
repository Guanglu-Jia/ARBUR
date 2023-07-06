function [rsrp,a,rsrp_per_pair]=rsrp_from_dfted_clip_and_delays_fast(V,dt,tau,verbosity)

% V_clip is N x K, K the number of mikes
% tau is K x n_pts, and tau(:,i) is the i'th delay 
%        vector at which SSE is to be computed

% get dimensions
[N,K]=size(V);
[~,n_pts]=size(tau);%tua n_mike x n_r

% compute delta_tau from tau
% Specify the mixing matrix  
% First time difference is between mikes 1 and 2, with the sign 
% convention that a positive dt means that the sound arrived at mike 1
% _after_ mike 2, therefore travel time to mike 1 is greater than travel
% time to mike 2.  Generally, a positive dt means the sound arrived at the
% lower-numbered mike _after_ the higher-numbered mike.
M=mixing_matrix_from_n_mics(K);
% fprintf('%d\n',M);
tau_diff=M*tau;% 6 x n_mike * n_mike x n_r

% estimate gain for each mic估计每个麦克风的增益
V_ss_per_mike=sum(abs(V).^2,1);  % 1 x K, sum of squares应该是求振幅
a=sqrt(V_ss_per_mike)/N;  % volts, gain estimate, proportional to RMS
                          % amp (in time domain)电压，增益估计，与RMS安培成比例（时域）

% calculate the unnormalized cross-correlation between all mic pairs计算所有麦克风对之间的非标准化互相关
[xcorr_raw,tau_line]=xcorr_raw_from_dfted_clip(V,dt,M,verbosity);

% check that the clip is long enough, given the time differences考虑到时间差异，检查剪辑是否足够长
% if not, set mse to nan
tau_diff_max=max(max(tau_diff));
tau_diff_min=min(min(tau_diff));
if (tau_diff_min<tau_line(1)) || (tau_line(end)<tau_diff_max)
  rsrp=nan(1,n_pts);
  return
end

% calculate the reduced steered response power for each time difference
% vector计算每个时间差矢量的减小转向响应功率
[rsrp,rsrp_per_pair]=rsrp_from_xcorr_raw_and_delta_tau(xcorr_raw,tau_line,tau_diff);

% % convert the RSRPs to MSEs
% mse=mse_from_rsrp(rsrp,V_ss_per_mike,N,a);

end
