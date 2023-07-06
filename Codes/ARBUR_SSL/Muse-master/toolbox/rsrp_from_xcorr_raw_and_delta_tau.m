function [rsrp,rsrp_per_pair]= ...
  rsrp_from_xcorr_raw_and_delta_tau(xcorr_raw_all,tau_line,tau_diff)

% Calculates sum of the upper cross terms in the formula for steered 
% response power (SRP) for a set of time shifts in dt_arr.
% 计算dt_arr中一组时间偏移的转向响应功率（SRP）公式中的上交叉项之和�??
%
% xcorr_raw_all is N x n_pairs, and contains the raw cross-correlation
%         between a pair of signals.  Note that this is unnormalized.
% xcorr_raw_all是N x N _对，包含�?对信号之间的原始互相关�?�请注意，这是非规范化的�?

% tau_line is N x 1, and gives the time lag (in s) for each row of xcorr_raw_all
% tau_line为N x 1，并为每行xcorr_raw_all提供时间延迟（以秒为单位�?

% tau_diff is n_pairs x n_r, and gives the predicted relative time lag for 
%        each pair of signals, in s.  n_r is an arbitrary number.  These
%        lags are used to interpolate into tau_line to get values of xcorr_raw_all at
%        a particular set of lags.
% tau _diff是n对x nr，并给出了每对信号的预测相对滞后时间，单位为s。nr是任意数�?
% 这些滞后用于插�?�到tau_line中，以获取特定滞后集合处的xcorr_raw_all值�??
%
% RSRP, on return, is 1 x n_r, and gives the sum of
% the upper cross terms in the steered response power.  The SRP is a sum
% across all pairs of signals, including self-pairs.  The return value of
% this function excludes the self pairs, and only includes one of (i,j) and
% (j,i) (hence the "upper"). 
% 反过来，RSRP�?1 x n_r，并给出转向响应功率中上交叉项的总和。SRP是所有信号对（包括自对）的�?�和�?
% 此函数的返回�?%不包括自身对，只包括（i，j）和%（j，i）中的一个（因此为�?�上限�?�）�?

% We're using the definition of the SRP given in:
%
% Zhang C, Florencio S, Ba D, Zhang Z (2007) Maximum likelihood sounds
% source localization and beamforming for directional microphone arrays in
% distributed meetings.  If a particular position leads to delayed signals
% x(n,k), where n indexes time points and k indexes signals, the SRP is:
%
%   SRP = sum sum sum x(n,i)*x(n,j)
%          i   j   n
%
% So here we're computing
%
%      sum sum sum x(n,i)*x(n,j)
%       i  j>i  n
%
% we do this fast by interpolating into the pre-computed values in
% xcorr_raw_all 我们通过在xcorr_raw_all中插入预先计算的值来快�?�做到这�?�?

[n_pairs,n_r]=size(tau_diff);
tau0=tau_line(1);
dtau=(tau_line(end)-tau0)/(length(tau_line)-1);
rsrp_per_pair=zeros(n_r,n_pairs);
for i=1:n_r
  for j=1:n_pairs
    k_real=(tau_diff(j,i)-tau0)/dtau+1;
    k_lo=floor(k_real);  
    k_hi=k_lo+1;
    w_hi=k_real-k_lo;
    rsrp_per_pair(i,j)= ...
      (1-w_hi)*xcorr_raw_all(k_lo,j)+w_hi*xcorr_raw_all(k_hi,j);
  end
end
rsrp=sum(rsrp_per_pair,2);  % sum across pairs




end
