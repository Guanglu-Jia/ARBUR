function [SSL_ind, BT_temp] = SSL_input(filename1,filename2)

% Description:
% ---------
% load the indices of the USVs to be analysed
%
% Inputs: 
% ---------
% filename1 : the file that stores the name information and 3D coordinates of the USVs
% filename2 : the file that stores the detected behavioral types of the USVs, one of the outputs of ARBUR:Behavior
%
% Outputs: 
% ----------
% SSL_ind : nx4 matrix that denotes the position of the n USVs
% BT_temp : nx3 matrix that denotes the name, behavior types and confidence of the USVs
%
% ----------
% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.

delimiter = ',';
formatSpec = '%s%s%s%s%s%s%s%[^\n\r]';

fileID = fopen(filename1,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
fclose(fileID);
rats_nose_3d = [dataArray{1:end-1}];
clearvars filename delimiter formatSpec fileID dataArray ans;
rats_nose_3d(1,:) = [];


USV_day_14 = [0,2118,358,1402,545,6,511,1808,176,1847,837,161,1112,2213,1065,41,1151,82,7,35,103,20,21,80,467,10];
USV_day_16 = [0,3370,203,2850,1481,1367,661,676,216,75,26,1628,1802,1109,244,1472,575,1089,158,410,208,80,32,1272,469,637,223];
USV_day_17 = [0,181,2,10,8,8,6,24,32,6,3,13,620,43,8,5,20,4,23,184,96,25,2,6,103,130];
USV_day_18 = [0,1264,856,10,4,12,4,14,6,1,13,63,230,4,7,1,39,11,496,1,28,50,14,85,12,8,53];
USV_day_{1} = USV_day_14;
USV_day_{2} = USV_day_16;
USV_day_{3} = USV_day_17;
USV_day_{4} = USV_day_18;

day_flag_vec = 20+15+24+[0 24 48 72];
day_flag_vec_2 = [14 16 17 18];
SSL_ind = [];
day_num = [];
seg_num = [];
USV_num = [];
USV_all = [];
for i = 1:size(rats_nose_3d,1)
    a_temp = strsplit(rats_nose_3d(i,1),'-');
    b_temp = strsplit(a_temp(2),'_');
    day_flag = (str2double(b_temp(1))-14)*24+str2double(b_temp(2));
    day_num(i) = day_flag_vec_2(find(day_flag<day_flag_vec,1));
    a_temp = strsplit(rats_nose_3d(i,1),'_');
    seg_num(i) = str2double(a_temp(3));
    USV_num(i) = str2double(a_temp(4));
    USV_all(i) = USV_num(i)+sum(USV_day_{find(day_flag<day_flag_vec,1)}(1:seg_num(i)));
end

SSL_ind = [day_num',seg_num',USV_all',USV_num'];
BT_temp = load(filename2);

end