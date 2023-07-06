function seg = fine_clustering_22(seg,cluster_num_22)

% Description:
% ---------
% Fine clustering for 22-kHz USVs
%
% Inputs: 
% ---------
% seg : a struct containing the in-process variables
% cluster_num_22 : number of clusters to be categorized
%
% Outputs: 
% ----------
% seg : a struct containing the in-process variables
% ----------
% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.


count = 0;
seg.features_ind_5 = [];
seg.features_good_5 = [];
for i = seg.ind_below_32
    if seg.mean_freq(1,i)>0 && seg.mean_freq(1,i)< 32 && seg.contour_num(i) >0 && seg.duration(i)>5 && seg.double_rats(i) ==0 ...
            && ~sum(i == seg.features_ind_1_to_4)
    count = count+1;
    seg.features_ind_5(count) = i;
    seg.features_good_5(1,count) = (seg.duration(i)-5)/(max(seg.duration)-5);
    seg.features_good_5(2,count) = (seg.mean_freq(i)-13)/(30-13);
%    ~isempty(seg.features{8})
    end
end
% a = unique(seg.features);

G5 = kmean(seg.features_good_5, cluster_num_22);
% G0 = kmean(Poses(:,1:3000), 30);
% G0 = kmean(reduction', 30);
L5 = G2L(G5);
seg.L5 = L5;

end