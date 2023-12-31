function [seg, KP] = segIniP(K, para)
% Initalize segmentation based on non-tempo-warping clustering.
% 基于非动态时间规整的聚类（谱聚类）用于初始化分割
%
% Input
%   K       -  frame similarity matrix, n x n
%   para    -  segmentation parameter
%
% Output
%   seg     -  segmentation result
%   KP      -  similarity matrix used by initalization, n x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-26-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

% progative similarity matrix
KP = conPropSim(K, para.nMa);

% spectral clustering
I = cluSc(KP, para.k);

% obtain the class labels for segments
seg = mergeDP(I, para);
% seg = mergeI2H(I, para);

% randomly initalize when some cluster is empty
if cluEmp(seg.G)
    seg = segIniR(K, para);
    warning('a:b', 'empty class in prop init, use rand init instead\n');
end
