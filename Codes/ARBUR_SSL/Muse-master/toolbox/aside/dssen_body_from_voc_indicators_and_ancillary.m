function dssen_body= ...
  dssen_body_from_voc_indicators_and_ancillary(...
    base_dir_name,date_str,letter_str, ...
    R, Temp, ...
    dx,x_grid,y_grid,in_cage, ...
    i_syl,i_start,i_end,...
    f_lo,f_hi,...
    r_head,r_tail, ...
    verbosity)

% deal with args
if nargin<17 || isempty(verbosity)
  verbosity=0;
end

% check for a memoized version of the objective map
memo_base_dir_name=fullfile(fileparts(mfilename('fullpath')),'..');
memo_dir_name=fullfile(memo_base_dir_name,sprintf('memos_%06d_um',round(1e6*dx)));
memo_file_name= ...
  fullfile(memo_dir_name, ...
           sprintf('grid_%s_%s_%03d.mat', ...
                   date_str,letter_str,i_syl));

% read the grid from the file, or compute it                 
if exist(memo_file_name,'file')
%if false
  load(memo_file_name);
else                 
  % load the audio data for one vocalization
  exp_dir_name=sprintf('%s/sys_test_%s',base_dir_name,date_str);
  [v_clip,~,fs]= ...
    read_voc_audio_trace(exp_dir_name, ...
                         letter_str, ...
                         i_start, ...
                         i_end);
    % v_clip in V, t_clip in s, fs in Hz                 

  % estimate the position, and get the SSE grid also
  [r_est,sse_min,sse_grid]= ...
    r_est_from_clip(v_clip,fs, ...
                    f_lo,f_hi, ...
                    Temp, ...
                    x_grid,y_grid,in_cage, ...
                    R, ...
                    verbosity);
                  
  % save the memo file
  if ~exist(memo_dir_name,'dir')
    mkdir(memo_dir_name);
  end
  [N,K]=size(v_clip);
  save(memo_file_name,'fs','r_est','sse_min','sse_grid','N','K');
end

% if strcmp(date_str,'06062012') && strcmp(letter_str,'E') && i_syl==284
%   drawnow;
% end

% if close to center, return nan, which means to ignore it
R_mean=mean(R,2);
if (norm(r_est-R_mean(1:2))<0.025)
  dssen_body=nan;
  return;
end

% Calculate ssen grid, dssen grid
% ssen stands for SSE normalized
ssen_grid=sse_grid/sse_min;
dssen_grid=ssen_grid-1;

% Determine dssen at the body, approximating the body as an ellipse
r_center=(r_head+r_tail)/2;
a_vec=r_head-r_center;  % vector
b=norm(a_vec)/3;  % scalar, and a guess at the half-width of the mouse
in_body=in_ellipse(x_grid,y_grid,r_center,a_vec,b);  % boolean mask
dssen_in_body=dssen_grid(in_body);
x_in_body=x_grid(in_body);
y_in_body=y_grid(in_body);
[dssen_body,i]=min(dssen_in_body);
r_est_in_body=[x_in_body(i);y_in_body(i)];

% plot the dF map
if verbosity>=1
  title_str=sprintf('%s %s %03d', ...
                    date_str,letter_str,i_syl);
  clr_mike=[1 0 0 ; ...
            0 0.7 0 ; ...
            0 0 1 ; ...
            0 1 1 ];
%   figure_objective_map(x_grid,y_grid,in_body, ...
%                        @gray, ...
%                        [], ...
%                        title_str, ...
%                        'In body?', ...
%                        clr_mike, ...
%                        r_est,[], ...
%                        R,r_head,r_tail);
  figure_objective_map(x_grid,y_grid,dssen_grid, ...
                       @jet, ...
                       [], ...
                       title_str, ...
                       '\DeltaSSEN (pure)', ...
                       clr_mike, ...
                       [], ...
                       r_est,[], ...
                       R,r_head,r_tail);
  r_poly=polygon_from_ellipse(r_center,a_vec,b);
  line(100*r_poly(1,:),100*r_poly(2,:),'color','w');
  line(100*r_est_in_body(1),100*r_est_in_body(2),0, ...
       'marker','o','linestyle','none','color','w', ...
       'markersize',6);
  
  drawnow;                   
end
  
end

