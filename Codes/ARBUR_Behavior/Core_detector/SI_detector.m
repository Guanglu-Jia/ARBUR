function [behavor_label] = SI_detector(img_left,img_right)
% Description:
% ------------
% SI_ Detector is used to detect sleeping state behavior.
%
% Inputs: 
% -------
% img_left         : Left image of the current frame
% img_right        : Right image of the current frame

% Outputs: 
% -----
% behavor_label    : The behavior category and confidence of the 
%                    current frame

% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.

% SO_FLAG==1
likehood_k = 1;
fprintf('detecting SI ...\n');
frame_num = size(img_left,4);
for i = 1:frame_num
    [IDleft(:,:,i),IDleft_num(i)] = bwlabel(im2gray(img_left(:,:,:,i)),8);
    [IDright(:,:,i),IDright_num(i)] = bwlabel(im2gray(img_right(:,:,:,i)),8);
end
% filter
filter_h = 0.1;
for f = 1:frame_num
    if IDleft_num(f) >= 2
        leftarea_num = IDleft_num(f);
        transleft = IDleft(:,:,f);
        for e = 1:leftarea_num
            ID_larea(e) = sum(sum(IDleft(:,:,f) == e));
        end
        for e = 1:leftarea_num
            if ID_larea(e) <= max(ID_larea)*filter_h
                transleft(transleft==e) = 0;
                IDleft(:,:,f) = transleft;
                IDleft_num(f) = IDleft_num(f) - 1;
            end
        end
    end
    if IDright_num(f) >= 2
        riightarea_num = IDright_num(f);
        transright = IDright(:,:,f);
        for e = 1:riightarea_num
            ID_rarea(e) = sum(sum(IDright(:,:,f) == e));
        end
        for e = 1:riightarea_num
            if ID_rarea(e) <= max(ID_rarea)*filter_h
                transright(transright==e) = 0;
                IDright(:,:,f) = transright;
                IDright_num(f) = IDright_num(f) - 1;
            end
        end
    end
end

cerID_left = zeros(frame_num,2);
cerID_right = zeros(frame_num,2);
move_pix = zeros(frame_num-1,2);
for nf = 1:frame_num
    for row = 1:384
        for col = 1:384
            if ~IDleft(row,col,1) == 0
                cerID_left(nf,1) = cerID_left(nf,1) + col*1;
                cerID_left(nf,2) = cerID_left(nf,2) + row*1;
            end
            if ~IDright(row,col,1) == 0
                cerID_right(nf,1) = cerID_right(nf,1) + col*1;
                cerID_right(nf,2) = cerID_right(nf,2) + row*1;
            end
        end
    end
    cerxleftpos(nf,1) = cerID_left(nf,1)/sum(sum(IDleft(:,:,nf) ~= 0));
    cerxleftpos(nf,2) = cerID_left(nf,2)/sum(sum(IDleft(:,:,nf) ~= 0));
    cerxright_pos(nf,1) = cerID_right(nf,1)/sum(sum(IDright(:,:,nf) ~= 0));
    cerxright_pos(nf,2) = cerID_right(nf,2)/sum(sum(IDright(:,:,nf) ~= 0));
end
for m = 1:frame_num-1
    move_pix(m,1) = norm([abs(cerxleftpos(m+1,1)-cerxleftpos(m,1)),abs(cerxleftpos(m+1,2)-cerxleftpos(m,2))]);
    move_pix(m,2) = norm([abs(cerxright_pos(m+1,1)-cerxright_pos(m,1)),abs(cerxright_pos(m+1,2)-cerxright_pos(m,2))]);
end
mean_x = max(mean(move_pix,1));

if mean_x < likehood_k
    behavor_label{1} = 'SL(sleep)';
    behavor_label{2} = 1;
else
    behavor_label{1} = 'Next';
    behavor_label{2} = 0;
end

end