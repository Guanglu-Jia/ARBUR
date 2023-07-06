function SSL_output = SSL_assignment_2d(nose_,ssl_position,ssl_confidence,partworld3d,LCI_threshold,SSL_threshold)

% Description:
% ---------
% Assigning SSL results to the vocal rat based on horizontal information
%
% Inputs: 
% ---------
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

if nargin < 5
    LCI_threshold = 0.6;
end

if nargin <6
    SSL_threshold = 100; % mm
end

for i = 1:length(nose_)
% two rat noses detected 
 if ssl_confidence(i)> LCI_threshold
if (partworld3d(i+1,2)) ~= "NaN" && (partworld3d(i+1,5)) ~= "NaN"
    if min(norm(ssl_position(nose_(i,1),:)-nose_(i,2:3)),norm(ssl_position(nose_(i,1),:)-nose_(i,5:6)))<SSL_threshold
    if norm(ssl_position(nose_(i,1),:)-nose_(i,2:3))<norm(ssl_position(nose_(i,1),:)-nose_(i,5:6))
        SSL_output(i) = 1;
    else
        SSL_output(i) = 2;
    end
    end
% one rat nose detected    
elseif (partworld3d(i+1,2)) ~= "NaN" 
    if norm(ssl_position(nose_(i,1),:)-nose_(i,2:3))<SSL_threshold
        SSL_output(i) = 1;
    else
        SSL_output(i) = 2;
    end
   
elseif (partworld3d(i+1,5)) ~= "NaN"
    if norm(ssl_position(nose_(i,1),:)-nose_(i,5:6))<SSL_threshold
        SSL_output(i) = 2;
    else
        SSL_output(i) = 1;
    end    
    
else
    % unassigned results
    
 end

end

end

end