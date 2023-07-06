function [ssl_confidence,ssl_position] = LCI_eval(source_estimated_all)

% Description:
% ---------
% Visualizing spectrograms within each clusters
%
% Inputs: 
% ---------
% source_estimated_all : 1xn cells that stores the estimated sound sources for n USVs;
% 						 each cell contains 9x5 2D points (possible sound sources)
%
% Outputs: 
% ----------
% ssl_confidence : nx1 vector that stores LCIs for the n USVs
% ssl_position : nx2 matrix that stores SSL results for the n USVs
%
% ----------
% Copyright (c) 2023 Beijing Institute of Technology (BIT), China. 
% All rights reserved.



% Estimate the probability density map
dx=1e-2;  % m
xl=[-0.26 +0.26];
yl=[-0.26 +0.26];
x_line=(xl(1):dx:xl(2))';
y_line=(yl(1):dx:yl(2))';

[x1,x2] = meshgrid(x_line, y_line);
x1 = x1(:);
x2 = x2(:);
xi = [x1 x2];

ssl_position = [];
ssl_confidence = [];

for jj = 1:length(source_estimated_all)
    if ~isempty(source_estimated_all{jj})
source_estimated = source_estimated_all{jj};

% Add Color bar
% cb = colorbar();
% cb.Label.String = 'Probability density estimate';

rng('default')  % For reproducibility
x_input = cell2mat(source_estimated(:,1)')';

% 
x_input_3 = [];
for i = 1:4
    temp = cell2mat(source_estimated(:,i+1)')';
    x_input_3 = [x_input_3;temp];
end
        

[f_3_mics,xxi] = ksdensity(x_input_3,xi,'Bandwidth',[1 1]*0.04);
[f_4_mics,xxi] = ksdensity(x_input,xi,'Bandwidth',[1 1]*0.04*1);

% [xq,yq,z] = computeGrid(xi(:,1),xi(:,2),f);
x = linspace(min(xi(:,1)),max(xi(:,1)));
y = linspace(min(xi(:,2)),max(xi(:,2)));
[xq,yq] = meshgrid(x,y);

% SSL with 3 mics
z = griddata(xi(:,1),xi(:,2),f_3_mics,xq,yq);


% figure
% % surf(axarg{:},xq,yq,z);
% f1 = figure('Color','white');
% % colormap jet
% 
% hold on;
% 
% % surf(z');
% imagesc(z);
% colorbar
% title("SSL with 3 mics");
% axis([ 0 100 0 100]);


% sum(sum(z))
% SSL with 4 mics
z_4 = griddata(xi(:,1),xi(:,2),f_4_mics,xq,yq);
% z_4 = flipud(z_4);

% surf(axarg{:},xq,yq,z);
% f2 = figure('Color','white');
% hold on;
% 
% % surf(z');
% imagesc(z_4);
% colorbar
% title("SSL with 4 mics");
% axis([ 0 100 0 100]);

sum(sum(z_4))

% 
[z_max_x,z_max_y] = find(z_4 == max(max(z_4)));
z_max_value = max(max(z));

ssl_confidence(jj) = z(z_max_x(1),z_max_y(1))/max(max(z));
z_max_value_all(jj) = max(max(z_4));

[z_max_x_3,z_max_y_3] = find(z == max(max(z)));
% [z_max_x_3(1),z_max_y_3(1)];
temp = z_max_x_3(1);
z_max_x_3(1) = z_max_y_3(1);
z_max_y_3(1) = temp;
% [z_max_x(1),z_max_y(1)];
temp = z_max_x(1);
z_max_x(1) = z_max_y(1);
z_max_y(1) = temp;
ssl_position(jj,:) = ([z_max_x(1),z_max_y(1)]+[z_max_x_3(1),z_max_y_3(1)])/2;

    else
        ssl_position(jj,:) = [-260 260];
        ssl_confidence(jj) = 0;
    end
end
ssl_confidence = ssl_confidence';

% ssl_position = flip(ssl_position,2);
% ssl_position(:,1) = 100-ssl_position(:,1);
ssl_position = (ssl_position-[50,50])/(50)*.52/2*1000;
% ssl_position(:,2) = ssl_position(:,2)*-1;
theta = 90/180*pi;
ssl_position = ssl_position*[ cos(theta) -sin(theta);sin(theta) cos(theta)];








end