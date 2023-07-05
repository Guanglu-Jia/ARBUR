% Main script for ARBUR
%
% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.

clear;
%%  
Func_Path = 'Codes\';
addpath(Func_Path);
subFunc_Path = genpath(Func_Path);
addpath(subFunc_Path);
addpath('Icon\')
%% 
ARBUR_USV;
%% 
close all;
ARBUR_Behavior;
%% 
close all;
ARBUR_SSL;
%% 
close all;
ARBUR_v1;
%% 
