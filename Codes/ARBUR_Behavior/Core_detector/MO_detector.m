function [behavor_label] = MO_detector(img_left,img_right)
% Description:
% ------------
% MO_ Detector is used to detect moving state behavior.
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

opticFlow = opticalFlowFarneback;
fprintf('detecting MO ...\n');
for i = 1:size(img_left,4)
    [IDleft(:,:,i),IDleft_num(i)] = bwlabel(im2gray(img_left(:,:,:,i)),8);
    [IDright(:,:,i),IDright_num(i)] = bwlabel(im2gray(img_right(:,:,:,i)),8);
end
% filter
filter_h = 0.1;
for f = 1:size(img_left,4)
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

pastleftID = IDleft(:,:,:,1);
pastrightID = IDright(:,:,:,1);
frame_num = size(img_left,4);
label = zeros(frame_num,2);
% AP_FLAG==2  eg: !! -><- !!,!! ->| !!,!! |<- !!
if (IDleft_num(1)==2&&IDleft_num(end)==1)||(IDright_num(1)==2&&IDright_num(end)==1)   
    for i = 1:frame_num-1
        flow_left = estimateFlow(opticFlow,im2gray(img_left(:,:,:,i)));
        flow_left = estimateFlow(opticFlow,im2gray(img_left(:,:,:,i+1)));
        flow_right = estimateFlow(opticFlow,im2gray(img_right(:,:,:,i)));
        flow_right = estimateFlow(opticFlow,im2gray(img_right(:,:,:,i+1)));

        mag_left = flow_left.Magnitude;
        mag_right = flow_right.Magnitude;
        mag_left(mag_left<1)=0;
        mag_right(mag_right<1)=0;

        Vx_left = flow_left.Vx;
        Vy_left = flow_left.Vy;
        Vx_left(im2gray(img_left(:,:,:,i+1))==0) = 0;
        Vy_left(im2gray(img_left(:,:,:,i+1))==0) = 0;
        Vx_right = flow_right.Vx;
        Vy_right = flow_right.Vy;
        Vx_right(im2gray(img_right(:,:,:,i+1))==0) = 0;
        Vy_right(im2gray(img_right(:,:,:,i+1))==0) = 0;
        % optical flow segmentation
        seg_leftflow=opticalFlow(Vx_left,Vy_left);
        seg_rightflow=opticalFlow(Vx_right,Vy_right);
        % Estimated current id
        curleftID = zeros(384,384);
        currightID = zeros(384,384);
        for row = 1:384
            for col = 1:384
                if Vx_left(row,col) ~= 0
                    pastleft_x = round(col-Vx_left(row,col));
                    pastleft_y = round(row-Vy_left(row,col));
                    if pastleft_x > 384
                        pastleft_x = 384;
                    elseif pastleft_x < 1
                        pastleft_x = 1;
                    end
                    if pastleft_y > 384
                        pastleft_y = 384;
                    elseif pastleft_y < 1
                        pastleft_y = 1;
                    end
                    if pastleftID(pastleft_y,pastleft_x) == 1
                        curleftID(row,col) = 1;
                    elseif pastleftID(pastleft_y,pastleft_x) == 2
                        curleftID(row,col) = 2;
                    end
                end
                if Vx_right(row,col) ~= 0
                    pastright_x = round(col-Vx_right(row,col));
                    pastright_y = round(row-Vy_right(row,col));
                    if pastrightID(pastright_y,pastright_x) == 1
                        currightID(row,col) = 1;
                    elseif pastrightID(pastright_y,pastright_x) == 2
                        currightID(row,col) = 2;
                    end
                end
            end
        end
        pastleftID = curleftID;
        pastrightID = currightID;         
        % combine
        OF_left_ori1 = atan2(-sum(Vy_left(curleftID==1)),sum(Vx_left(curleftID==1)));
        OF_left_ori2 = atan2(-sum(Vy_left(curleftID==2)),sum(Vx_left(curleftID==2)));
        OF_right_ori1 = atan2(-sum(Vy_right(currightID==1)),sum(Vx_right(currightID==1)));
        OF_right_ori2 = atan2(-sum(Vy_right(currightID==2)),sum(Vx_right(currightID==2)));
        
        if (OF_left_ori1<pi/2) && (OF_left_ori1>-pi/2)
            if (OF_left_ori2>pi/2) || (OF_left_ori2<-pi/2)
                label(i,1) = 2;
            end
        end
        if (OF_right_ori1<pi/2) && (OF_right_ori1>-pi/2)
            if (OF_right_ori2>pi/2) || (OF_right_ori2<-pi/2)
                label(i,2) = 2;
            end
        end
    end
    Confidence = 1;
    if Confidence>=0.5
        behavor_label{1} = 'AP(approaching)';
        behavor_label{2} = Confidence;
    else
        behavor_label{1} = 'Next';
        behavor_label{2} = 0;
    end
end
% FO_FLAG==3  eg: !! ->-> !!,!!  <-<- !!
likehood_k = 30;
if (IDleft_num(1)==2&&IDleft_num(end)==2)||(IDright_num(1)==2&&IDright_num(end)==2)
    for i = 1:frame_num-1
        flow_left = estimateFlow(opticFlow,im2gray(img_left(:,:,:,i)));
        flow_left = estimateFlow(opticFlow,im2gray(img_left(:,:,:,i+1)));
        flow_right = estimateFlow(opticFlow,im2gray(img_right(:,:,:,i)));
        flow_right = estimateFlow(opticFlow,im2gray(img_right(:,:,:,i+1)));

        mag_left = flow_left.Magnitude;
        mag_right = flow_right.Magnitude;
        mag_left(mag_left<1)=0;
        mag_right(mag_right<1)=0;

        Vx_left = flow_left.Vx;
        Vy_left = flow_left.Vy;
        Vx_left(im2gray(img_left(:,:,:,i+1))==0) = 0;
        Vy_left(im2gray(img_left(:,:,:,i+1))==0) = 0;
        Vx_right = flow_right.Vx;
        Vy_right = flow_right.Vy;
        Vx_right(im2gray(img_right(:,:,:,i+1))==0) = 0;
        Vy_right(im2gray(img_right(:,:,:,i+1))==0) = 0;

        % combine
        OF_left_ori1 = atan2(-sum(Vy_left(IDleft(:,:,i+1)==1)),sum(Vx_left(IDleft(:,:,i+1)==1)));
        OF_left_ori2 = atan2(-sum(Vy_left(IDleft(:,:,i+1)==2)),sum(Vx_left(IDleft(:,:,i+1)==2)));
        OF_right_ori1 = atan2(-sum(Vy_right(IDright(:,:,i+1)==1)),sum(Vx_right(IDright(:,:,i+1)==1)));
        OF_right_ori2 = atan2(-sum(Vy_right(IDright(:,:,i+1)==2)),sum(Vx_right(IDright(:,:,i+1)==2)));

        if (OF_left_ori1<pi/2) && (OF_left_ori1>-pi/2)
            if (OF_left_ori2<pi/2) && (OF_left_ori2>-pi/2)
                label(i,1) = 3;
            end
        else
            if (OF_left_ori2>pi/2) || (OF_left_ori2<-pi/2)
                label(i,1) = 3;
            end
        end
        if (OF_right_ori1<pi/2) && (OF_right_ori1>-pi/2)
            if (OF_right_ori2<pi/2) && (OF_right_ori2>-pi/2)
                label(i,2) = 3;
            end
        else
            if (OF_right_ori2>pi/2) || (OF_right_ori2<-pi/2)
                label(i,2) = 3;
            end
        end
    end
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

    Confidence = 1;
    if Confidence>=0.5
        if (abs(cerxleft_epos(1,1)-cerxleft_bpos(1,1)) >= likehood_k) && (abs(cerxleft_epos(2,1)-cerxleft_bpos(2,1)) >= likehood_k)
            behavor_label{1} = 'FO(following)';
            behavor_label{2} = Confidence;
        end
        if (abs(cerxright_epos(1,1)-cerxright_bpos(1,1)) >= likehood_k) && (abs(cerxright_epos(2,1)-cerxright_bpos(2,1)) >= likehood_k)
            behavor_label{1} = 'FO(following)';
            behavor_label{2} = Confidence;
        end
    else
        behavor_label{1} = 'Next';
        behavor_label{2} = 0;
    end

end
% MA_FLAG==4  eg: !! <--> !!
if (IDleft_num(1)==1&&IDleft_num(end)==2)||(IDright_num(1)==1&&IDright_num(end)==2)
    for i = 1:frame_num-1
        flow_left = estimateFlow(opticFlow,im2gray(img_left(:,:,:,i)));
        flow_left = estimateFlow(opticFlow,im2gray(img_left(:,:,:,i+1)));
        flow_right = estimateFlow(opticFlow,im2gray(img_right(:,:,:,i)));
        flow_right = estimateFlow(opticFlow,im2gray(img_right(:,:,:,i+1)));

        mag_left = flow_left.Magnitude;
        mag_right = flow_right.Magnitude;
        mag_left(mag_left<1)=0;
        mag_right(mag_right<1)=0;

        Vx_left = flow_left.Vx;
        Vy_left = flow_left.Vy;
        Vx_left(im2gray(img_left(:,:,:,i+1))==0) = 0;
        Vy_left(im2gray(img_left(:,:,:,i+1))==0) = 0;
        Vx_right = flow_right.Vx;
        Vy_right = flow_right.Vy;
        Vx_right(im2gray(img_right(:,:,:,i+1))==0) = 0;
        Vy_right(im2gray(img_right(:,:,:,i+1))==0) = 0;
        % optical flow segmentation
        seg_leftflow=opticalFlow(Vx_left,Vy_left);
        seg_rightflow=opticalFlow(Vx_right,Vy_right);
        % optical flow orientation
        degimg_left = seg_leftflow.Orientation;
        degimg_right = seg_rightflow.Orientation;
        cerID_left = zeros(2,2);
        cerID_right = zeros(2,2);
        ID_left_abssumUy = zeros(2,1);
        ID_right_abssumUy = zeros(2,1);
        ID_left_sum= zeros(2,2);
        ID_right_sum= zeros(2,2);

        for row = 1:384
            for col = 1:384
                if degimg_left(row,col)<-pi/2||degimg_left(row,col)>pi/2
                    ID_left_sum(1,1) = ID_left_sum(1,1)+seg_leftflow.Vx(row,col);
                    ID_left_sum(1,2) = ID_left_sum(1,2)+seg_leftflow.Vy(row,col);
                    ID_left_abssumUy(1,1) = ID_left_abssumUy(1,1)+abs(seg_leftflow.Vy(row,col));
                    cerID_left(1,1) = cerID_left(1,1) + col*seg_leftflow.Vx(row,col);
                    cerID_left(1,2) = cerID_left(1,2) + row*abs(seg_leftflow.Vy(row,col));
                else
                    ID_left_sum(2,1) = ID_left_sum(2,1)+seg_leftflow.Vx(row,col);
                    ID_left_sum(2,2) = ID_left_sum(2,2)+seg_leftflow.Vy(row,col);
                    ID_left_abssumUy(2,1) = ID_left_abssumUy(2,1)+abs(seg_leftflow.Vy(row,col));
                    cerID_left(2,1) = cerID_left(2,1) + col*seg_leftflow.Vx(row,col);
                    cerID_left(2,2) = cerID_left(2,2) + row*abs(seg_leftflow.Vy(row,col));
                end
                if degimg_right(row,col)<-pi/2||degimg_right(row,col)>pi/2
                    ID_right_sum(1,1) = ID_right_sum(1,1)+seg_rightflow.Vx(row,col);
                    ID_right_sum(1,2) = ID_right_sum(1,2)+seg_rightflow.Vy(row,col);
                    ID_right_abssumUy(1,1) = ID_right_abssumUy(1,1)+abs(seg_rightflow.Vy(row,col));
                    cerID_right(1,1) = cerID_right(1,1) + col*seg_rightflow.Vx(row,col);
                    cerID_right(1,2) = cerID_right(1,2) + row*abs(seg_rightflow.Vy(row,col));
                else
                    ID_right_sum(2,1) = ID_right_sum(2,1)+seg_rightflow.Vx(row,col);
                    ID_right_sum(2,2) = ID_right_sum(2,2)+seg_rightflow.Vy(row,col);
                    ID_right_abssumUy(2,1) = ID_right_abssumUy(2,1)+abs(seg_rightflow.Vy(row,col));
                    cerID_right(2,1) = cerID_right(2,1) + col*seg_rightflow.Vx(row,col);
                    cerID_right(2,2) = cerID_right(2,2) + row*abs(seg_rightflow.Vy(row,col));
                end
            end
        end
        % focus
        cerxleft_pos(1,1) = cerID_left(1,1)/ID_left_sum(1,1);
        cerxleft_pos(1,2) = cerID_left(1,2)/ID_left_abssumUy(1,1);
        cerxleft_pos(2,1) = cerID_left(2,1)/ID_left_sum(2,1);
        cerxleft_pos(2,2) = cerID_left(2,2)/ID_left_abssumUy(2,1);
        cerxright_pos(1,1) = cerID_right(1,1)/ID_right_sum(1,1);
        cerxright_pos(1,2) = cerID_right(1,2)/ID_right_abssumUy(1,1);
        cerxright_pos(2,1) = cerID_right(2,1)/ID_right_sum(2,1);
        cerxright_pos(2,2) = cerID_right(2,2)/ID_right_abssumUy(2,1);
        % combine
        OF_left_ori1 = atan2(-ID_left_sum(1,2),ID_left_sum(1,1));
        OF_left_ori2 = atan2(-ID_left_sum(2,2),ID_left_sum(2,1));
        OF_right_ori1 = atan2(-ID_right_sum(1,2),ID_right_sum(1,1));
        OF_right_ori2 = atan2(-ID_right_sum(2,2),ID_right_sum(2,1));

        if (OF_left_ori1<pi/2) && (OF_left_ori1>-pi/2)
            if ((OF_left_ori2>pi/2) || (OF_left_ori2<-pi/2))&&(cerxleft_pos(1,1)-cerxleft_pos(2,1)>0)
                label(i,1) = 4;
            end
        else
            if ((OF_left_ori2<pi/2) && (OF_left_ori2>-pi/2))&&(cerxleft_pos(1,1)-cerxleft_pos(2,1)<0)
                label(i,1) = 4;
            end
        end
        if (OF_right_ori1<pi/2) && (OF_right_ori1>-pi/2)
            if ((OF_right_ori2>pi/2) || (OF_right_ori2<-pi/2))&&(cerxright_pos(1,1)-cerxright_pos(2,1)>0)
                label(i,2) = 4;
            end
        else
            if ((OF_right_ori2<pi/2) && (OF_right_ori2>-pi/2))&&(cerxright_pos(1,1)-cerxright_pos(2,1)<0)
                label(i,2) = 4;
            end
        end
    end
    Confidence = 1;
    if Confidence>=0.5
        behavor_label{1} = 'MA(moving away)';
        behavor_label{2} = Confidence;
    else
        behavor_label{1} = 'Next';
        behavor_label{2} = 0;
    end
end

if ~exist('behavor_label','var')
    behavor_label{1} = 'Next';
    behavor_label{2} = 0;   
end

end