function  [nose_ ,partworld3d]= SSL_load_noses(filename)

% Description:
% ---------
% Load rat noses' 3D coordinates reconstructed visually
%
% Inputs: 
% ---------
% filename : the file that stores the name information and 3D coordinates of the USVs
%
% Outputs: 
% ----------
% nose_ : nx7 vector that stores the 3D coordinates of the two rat noses for n USVs
%
% ----------
% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.

delimiter = ',';
formatSpec = '%s%s%s%s%s%s%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
fclose(fileID);
partworld3d = [dataArray{1:end-1}];
clearvars filename delimiter formatSpec fileID dataArray ans;


nose_ = zeros(size(partworld3d,1)-1,7);
for i = 1:size(nose_,1)
    temp = strsplit(partworld3d(i+1,1),'_');
%     nose_(i,1) = str2num(char(temp(4)));
    nose_(i,1) = i;
    if (partworld3d(i+1,2)) ~= "NaN"
        nose_(i,2) = str2num(partworld3d{i+1,2});
        nose_(i,3) = str2num(partworld3d{i+1,3});
        nose_(i,4) = str2num(partworld3d{i+1,4});
    end
    
    if (partworld3d(i+1,5)) ~= "NaN"
        nose_(i,5) = str2num(partworld3d{i+1,5});
        nose_(i,6) = str2num(partworld3d{i+1,6});
        nose_(i,7) = str2num(partworld3d{i+1,7});        
    end    
    
end

end