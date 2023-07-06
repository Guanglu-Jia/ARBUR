function phi = phi_base(N)

% Generates a frequency line to go with an N-point fft.  Frequencies are in
% cycles per sample, i.e. they go from about -1/2 to about 1/2.
% 生成要使用N点fft的频率线。频率以每个样本的周期为单位，即从约-1/2到约1/2。

dphi=1/N;

hi_freq_sample_index=ceil(N/2);%CEIL（X）将X的元素四舍五入到接近无穷大的整数。
phi_pos=dphi*linspace(0,hi_freq_sample_index-1,hi_freq_sample_index)';
%LINSPACE（X1，X2，N）在X1和X2之间生成N个点。
phi_neg=dphi*linspace(-(N-hi_freq_sample_index),...
                      -1,...
                      N-hi_freq_sample_index)';
phi=[phi_pos ; phi_neg];

end
