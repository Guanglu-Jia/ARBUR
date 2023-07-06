function SSL_output = SSL_assignment_3d(SSL_output,BT_temp,nose_,ssl_position,ssl_confidence,partworld3d,LCI_threshold,SSL_threshold)

% Description:
% ---------
% Assigning SSL results to the vocal rat based on 3D information
%
% Inputs: 
% ---------
% SSL_output : nx1 vector that denotes the label of the vocal rat
% BT_temp : nx3 matrix that denotes the name, behavior types and confidence of the USVs
% nose_ : indices for the selected rows of the input matrix SSL_ind
% ssl_position : nx2 matrix that stores SSL results for the n USVs
% ssl_confidence : nx1 vector that stores LCIs for the n USVs
% partworld3d : nx7 matrix that stores the 3D coordinates of the noses of the two rats
% LCI_threshold : threshold of localization confidence index
% SSL_threshold : threshold of the distance between the SSL result and the visually reconstrcuted 3D position of the rat noses 
%
% Outputs: 
% ----------
% SSL_output : nx1 vector that denotes the label of the vocal rat
%
% ----------
% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.

for i = 1:size(nose_,1)
if min(norm(ssl_position(nose_(i,1),:)-nose_(i,2:3)),norm(ssl_position(nose_(i,1),:)-nose_(i,5:6)))<SSL_threshold ...
        && (string(BT_temp.SB_label{i,2})== "POU(pouncing)" || string(BT_temp.SB_label{1,2})== "PIN(pinning)")

% unassigned_ind_POU_PIN = (SSL_output==0)&(BT(:,1)== 'POU(pouncing)' || BT(:,2) == 'PIN(pinning)');

% two rat noses detected 
if (partworld3d(i+1,2)) ~= "NaN" && (partworld3d(i+1,5)) ~= "NaN"
    rat_nose_height_1 = nose_(i,4)/1000;
    source_estimated_all = SRP_SSL(i,SSL_ind,rat_nose_height_1,BT_temp.SB_label);
    [LCI_1,~] = LCI_eval(source_estimated_all);
    rat_nose_height_2 = nose_(i,7)/1000;
    source_estimated_all = SRP_SSL(i,SSL_ind,rat_nose_height_2,BT_temp.SB_label);
    [LCI_2,~] = LCI_eval(source_estimated_all);
    if LCI_1(end)>LCI_2(end)
        SSL_output(i) = 1;
    else
        SSL_output(i) = 2;
    end
    
% one rat nose detected    
elseif (partworld3d(i+1,2)) ~= "NaN" 
    rat_nose_height_1 = nose_(i,4)/1000;
    source_estimated_all = SRP_SSL(i,SSL_ind,rat_nose_height_1,BT_temp.SB_label);    
    [LCI_1,~] = LCI_eval(source_estimated_all);
    if rat_nose_height_1 > 5
        rat_nose_height_2 = 0;
    else
        rat_nose_height_2 = rat_nose_height_1+5;
    end
    source_estimated_all = SRP_SSL(i,SSL_ind,rat_nose_height_2,BT_temp.SB_label);
    [LCI_2,~] = LCI_eval(source_estimated_all);
    if LCI_1(end)>LCI_2(end)
        SSL_output(i) = 1;
    else
        SSL_output(i) = 2;
    end
    
elseif (partworld3d(i+1,5)) ~= "NaN"
    rat_nose_height_2 = nose_(i,7)/1000;
    source_estimated_all = SRP_SSL(i,SSL_ind,rat_nose_height_2,BT_temp.SB_label);    
    [LCI_2,~] = LCI_eval(source_estimated_all);
    if rat_nose_height_2 > 5
        rat_nose_height_1 = 0;
    else
        rat_nose_height_1 = rat_nose_height_2+5;
    end
    source_estimated_all = SRP_SSL(i,SSL_ind,rat_nose_height_1,BT_temp.SB_label);
    [LCI_1,~] = LCI_eval(source_estimated_all);
    if LCI_1>LCI_2
        SSL_output(i) = 1;
    else
        SSL_output(i) = 2;
    end    
    
else
    % unassigned results
       
    
end

end
end


end