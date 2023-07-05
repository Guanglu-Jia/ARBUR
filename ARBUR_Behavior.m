% Main script for behavior detection 
%
% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.

clear
%% 
save_name = 'Results\demo_behavior_label';
imgleft_data = imageDatastore('DemoData\Image\Left');
imgright_data = imageDatastore('DemoData\Image\Right');

load POU_PIN_SVMModel.mat;
load POU_SNC_SVMModel.mat;
load SNC_PIN_SVMModel.mat;

%% 
numImages = length(imgleft_data.Files);
fileleft_path = split(imgleft_data.Files(1),'\');
fileleft_name = split(fileleft_path(end),'_');
numlast = str2num(cell2mat(fileleft_name(4)));
label_num = 1;
k = 1; 
for i = 1:numImages
%     fprintf('i1: %d\n',i);
    fileleft_path = split(imgleft_data.Files(i),'\');
    fileleft_name = split(fileleft_path(end),'_');
    fileright_path = split(imgright_data.Files(i),'\');
    fileright_name = split(fileright_path(end),'_');

    if cell2mat(fileleft_name(5)) == cell2mat(fileright_name(5))
        numcur = str2num(cell2mat(fileleft_name(4)));
        if i == numImages
            %             fprintf('i2: %d\n',i);
            numlast = numlast+1;
        end
        if numcur == numlast
            imageleft(:,:,:,k) = readimage(imgleft_data,i);
            imageright(:,:,:,k) = readimage(imgright_data,i);
            k = k+1;
            numlast = numcur;
        else
            fprintf('part: %d\n',numlast);
            label = SI_detector(imageleft,imageright);
            if cell2mat(label(2)) == 1
                SB_label{label_num,1} = last_filename(1);
                SB_label{label_num,2} = label(1);
                SB_label{label_num,3} = cell2mat(label(2));
            else
                label = SO_detector(imageleft,imageright);
                if cell2mat(label(2)) == 1 || isnan(cell2mat(label(2)))
                    SB_label{label_num,1} = last_filename(1);
                    SB_label{label_num,2} = label(1);
                    SB_label{label_num,3} = cell2mat(label(2));
                else
                    label = MO_detector(imageleft,imageright);
                    if cell2mat(label(2)) == 0
                        label = IN_detector(imageleft,imageright,SNC_PIN_SVMModel,POU_SNC_SVMModel,POU_PIN_SVMModel);
                        SB_label{label_num,1} = last_filename(1);
                        SB_label{label_num,2} = label(1);
                        SB_label{label_num,3} = cell2mat(label(2));
                    else
                        SB_label{label_num,1} = last_filename(1);
                        SB_label{label_num,2} = label(1);
                        SB_label{label_num,3} = cell2mat(label(2));
                    end
                end
            end
            
            k = 1;
            imageleft = [];
            imageright = [];
            imageleft(:,:,:,k) = readimage(imgleft_data,i);
            imageright(:,:,:,k) = readimage(imgright_data,i);
            k = k+1;
            label_num = label_num+1;
        end
        numlast = numcur;
        last_filepath =  split(imgleft_data.Files(i),'\');
        last_filename =  split(last_filepath(end),'_left.png');
    end
end

 
save(save_name,"SB_label")