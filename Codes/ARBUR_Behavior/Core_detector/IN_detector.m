function [behavor_label] = IN_detector(img_left,img_right,SNC_PIN_SVMModel,POU_SNC_SVMModel,POU_PIN_SVMModel)
% Description:
% ------------
% IN_ Detector is used to detect social state behavior.
%
% Inputs: 
% -------
% img_left         : Left image of the current frame
% img_right        : Right image of the current frame
% SNC_PIN_SVMModel : A trained SVM model for detecting SNC and PIN
%                    behavior
% POU_SNC_SVMModel : A trained SVM model for detecting POU and SNC
%                    behavior
% POU_PIN_SVMModel : A trained SVM model for detecting POU and PIN
%                    behavior

% Outputs: 
% -----
% behavor_label    : The behavior category and confidence of the 
%                    current frame

% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.

frame_num = size(img_left,4);
label = zeros(frame_num,2);
likehood_Il = 0.80;

cellsize = 8;
blocksize  = 2;
% PIN_FLAG==5
% POU_FLAG==6
% SNC_FLAG==7
% Other_FLAG==0
fprintf('detecting IN ...\n');
for i = 1:frame_num
    left_HOG_feature = extractHOGFeatures(img_left(:,:,:,i),'CellSize',[cellsize cellsize],'BlockSize',[blocksize blocksize]);
    right_HOG_feature = extractHOGFeatures(img_right(:,:,:,i),'CellSize',[cellsize cellsize],'BlockSize',[blocksize blocksize]);
    
    left_label = behavior_predict(left_HOG_feature,SNC_PIN_SVMModel,POU_SNC_SVMModel,POU_PIN_SVMModel);
    right_label = behavior_predict(right_HOG_feature,SNC_PIN_SVMModel,POU_SNC_SVMModel,POU_PIN_SVMModel);

    if left_label(1) == right_label(1)
        if  left_label(2)>=likehood_Il || right_label(2)>=likehood_Il
            label(i,1) = left_label(1);
            label(i,2) = right_label(1);
        end
    else
        if isnan(left_label(2))&&isnan(right_label(2))
            label(i,1) = NaN;
            label(i,2) = NaN;
        end
        if isnan(left_label(2))&&right_label(2)>=likehood_Il
            label(i,1) = NaN;
            label(i,2) = right_label(1);
        end
        if isnan(right_label(2))&&left_label(2)>=likehood_Il
            label(i,1) = left_label(1);
            label(i,2) = NaN;
        end
        if not(isnan(left_label(2))&&isnan(right_label(2)))
            if left_label(2) >= likehood_Il || right_label(2) >= likehood_Il
                if left_label(2) > right_label(2)
                    label(i,1) = left_label(1);
                    label(i,2) = NaN;
                else
                    label(i,1) = NaN;
                    label(i,2) = right_label(1);
                end
            else
                label(i,1) = NaN;
                label(i,2) = NaN;
            end
        end
    end
end
PIN_Confidence = sum(label(:)==5)/(frame_num*2);
POU_Confidence = sum(label(:)==6)/(frame_num*2);
SNC_Confidence = sum(label(:)==7)/(frame_num*2);
[Confidence,Confidence_pos] = max([PIN_Confidence,POU_Confidence,SNC_Confidence]);

if Confidence>=0.5
    switch Confidence_pos
        case 1
            behavor_label{1} = 'PIN(pining)';
            behavor_label{2} = Confidence;
        case 2
            behavor_label{1} = 'POU(poucing)';
            behavor_label{2} = Confidence;
        case 3
            behavor_label{1} = 'SNC(social nose contact)';
            behavor_label{2} = Confidence;
    end
else
    behavor_label{1} = 'Unlabeled';
    behavor_label{2} = NaN;
end
%%filter
if strcmp(cell2mat(behavor_label(1)),'PIN(pining)')
    if frame_num < 3
        if Confidence < 1
            [Confidence_filter,Confidence_pos_filter] = max([POU_Confidence,SNC_Confidence]);
            if Confidence_filter > 0 
                switch Confidence_pos_filter
                    case 1
                        behavor_label{1} = 'POU(poucing)';
                        behavor_label{2} = Confidence_filter;
                    case 2
                        behavor_label{1} = 'SNC(social nose contact)';
                        behavor_label{2} = Confidence_filter;
                end
            else
                behavor_label{1} = 'Unlabeled';
                behavor_label{2} = NaN;
            end
        end
    end
end



    function label_cur = behavior_predict(HOG_feature,SNC_PIN_SVMModel,POU_SNC_SVMModel,POU_PIN_SVMModel)
    [SNC_PIN_predict,SNC_PIN_score] = predict(SNC_PIN_SVMModel,HOG_feature);
    [POU_SNC_predict,POU_SNC_score] = predict(POU_SNC_SVMModel,HOG_feature);
    [POU_PIN_predict,POU_PIN_score] = predict(POU_PIN_SVMModel,HOG_feature);

    % left predict
    PIN_votes = 0;
    POU_votes = 0;
    SNC_votes = 0;
    if string(SNC_PIN_predict) == 'SNC(social nose contact)'
        SNC_votes = SNC_votes + 1;
    else
        PIN_votes = PIN_votes + 1;
    end
    if string(POU_SNC_predict) == 'POU(pouncing)'
        POU_votes = POU_votes + 1;
    else
        SNC_votes = SNC_votes + 1;
    end
    if string(POU_PIN_predict) == 'PIN(pining)'
        PIN_votes = PIN_votes + 1;
    else
        POU_votes = POU_votes + 1;
    end

    [label_votes,pos] = max([PIN_votes,POU_votes,SNC_votes]);
    if label_votes == 2
        switch pos
            case 1
                label_cur(1) = 5;
                label_cur(2) = max([max(SNC_PIN_score),max(POU_PIN_score)]);
            case 2
                label_cur(1) = 6;
                label_cur(2) = max([max(POU_SNC_score),max(POU_PIN_score)]);
            case 3
                label_cur(1) = 7;
                label_cur(2) = max([max(SNC_PIN_score),max(POU_SNC_score)]);
        end
    else
        [~, behavor_pos]= max([max(SNC_PIN_score),max(POU_SNC_score),max(POU_PIN_score)]);
        switch behavor_pos
            case 1
                label_cur(1) = 57;
                label_cur(2) = NaN;
            case 2
                label_cur(1) = 67;
                label_cur(2) = NaN;
            case 3
                label_cur(1) = 56;
                label_cur(2) = NaN;
        end
    end
    end

end