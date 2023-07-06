function [behavor_label] = SO_detector(img_left,img_right)
% Description:
% ------------
% SO_ Detector is used to detect solitary state behavior.
%
% Inputs: 
% -------
% img_left         : Left image of the current frame
% img_right        : Right image of the current fram

% Outputs: 
% -----
% behavor_label    : The behavior category and confidence of the 
%                    current frame

% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.

% SO_FLAG==1
likehood_k = 30;
fprintf('detecting SO ...\n');
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

if (length(find(IDright_num(:)==2)) == frame_num) || (length(find(IDleft_num(:)==2)) == frame_num)
    cerID_leftb = zeros(2,2);
    cerID_rightb = zeros(2,2);
    cerID_lefte = zeros(2,2);
    cerID_righte = zeros(2,2);
    for row = 1:384
        for col = 1:384
            if IDleft(row,col,1) == 1
                cerID_leftb(1,1) = cerID_leftb(1,1) + col*1;
                cerID_leftb(1,2) = cerID_leftb(1,2) + row*1;
            elseif IDleft(row,col,1) == 2
                cerID_leftb(2,1) = cerID_leftb(1,1) + col*1;
                cerID_leftb(2,2) = cerID_leftb(1,2) + row*1;
            end

            if IDright(row,col,1) == 1
                cerID_rightb(1,1) = cerID_rightb(1,1) + col*1;
                cerID_rightb(1,2) = cerID_rightb(1,2) + row*1;
            elseif IDright(row,col,1) == 2
                cerID_rightb(2,1) = cerID_rightb(1,1) + col*1;
                cerID_rightb(2,2) = cerID_rightb(1,2) + row*1;
            end

            if IDleft(row,col,end) == 1
                cerID_lefte(1,1) = cerID_lefte(1,1) + col*1;
                cerID_lefte(1,2) = cerID_lefte(1,2) + row*1;
            elseif IDleft(row,col,end) == 2
                cerID_lefte(2,1) = cerID_lefte(1,1) + col*1;
                cerID_lefte(2,2) = cerID_lefte(1,2) + row*1;
            end

            if IDright(row,col,end) == 1
                cerID_righte(1,1) = cerID_righte(1,1) + col*1;
                cerID_righte(1,2) = cerID_righte(1,2) + row*1;
            elseif IDright(row,col,end) == 2
                cerID_righte(2,1) = cerID_righte(1,1) + col*1;
                cerID_righte(2,2) = cerID_righte(1,2) + row*1;
            end
        end
    end
    cerxleft_bpos(1,1) = cerID_leftb(1,1)/sum(sum(IDleft(:,:,1) == 1));
    cerxleft_bpos(2,1) = cerID_leftb(2,1)/sum(sum(IDleft(:,:,1) == 2));
    cerxright_bpos(1,1) = cerID_rightb(1,1)/sum(sum(IDright(:,:,1) == 1));
    cerxright_bpos(2,1) = cerID_rightb(2,1)/sum(sum(IDright(:,:,1) == 2));


    cerxleft_epos(1,1) = cerID_lefte(1,1)/sum(sum(IDleft(:,:,end) == 1));
    cerxleft_epos(2,1) = cerID_lefte(2,1)/sum(sum(IDleft(:,:,end) == 2));
    cerxright_epos(1,1) = cerID_righte(1,1)/sum(sum(IDright(:,:,end) == 1));
    cerxright_epos(2,1) = cerID_righte(2,1)/sum(sum(IDright(:,:,end) == 2));

    if (abs(cerxleft_epos(1,1)-cerxleft_bpos(1,1)) < likehood_k) || (abs(cerxleft_epos(2,1)-cerxleft_bpos(2,1)) < likehood_k)
        behavor_label{1} = 'SO(solitary)';
        behavor_label{2} = 1;
    elseif (abs(cerxright_epos(1,1)-cerxright_bpos(1,1)) < likehood_k) || (abs(cerxright_epos(2,1)-cerxright_bpos(2,1)) < likehood_k)
        behavor_label{1} = 'SO(solitary)';
        behavor_label{2} = 1;
    else
        behavor_label{1} = 'Next';
        behavor_label{2} = 0;
    end
% Unlabeled 
elseif length(find(IDright_num(:)>2)) > 1||length(find(IDleft_num(:)>2)) > 1
    behavor_label{1} = 'Unlabeled';
    behavor_label{2} = NaN;
else
    behavor_label{1} = 'Next';
    behavor_label{2} = 0;
end

end