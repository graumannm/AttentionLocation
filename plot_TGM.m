function plot_TGM(sbj)

load(sprintf('./Results/EEG/s%.2d_EEG.mat',sbj));

% TGM: cat x cat x time x time x bg x bg x att x att
RDM = permute(TGM,[ 3 4 5 6 7 8 1 2]); % put category in the back
% --> time x time x bg x bg x att x att x cat x cat
ssTGM = nanmean(RDM(:,:,:,:,:,:,eye(2,2)==0),7); % extract location across categories
% --> time x time x bg x bg x att x att

% define condition indices
nocl    = 1; % no clutter
hicl    = 2; % high clutter
objects = 1; % periphery attention
digits  = 2; % fixation attention
% extract location across category

lowbound   = timepoints(timewindow(1));
upperbound = timepoints(timewindow(end));

figure;
% no clutter, periphery attention
subplot(2,2,1)
imagesc(timepoints(timewindow),timepoints(timewindow),squeeze(ssTGM(:,:,nocl,nocl,objects,objects))); 
title('S05: no clutter, peripheral attention')
axis square
axis xy
line([lowbound upperbound],[lowbound upperbound],'Color','k','Linewidth',1); % line through diagonal
hold on
line([0 0],[lowbound upperbound],'Color','k','Linewidth',1); % vertical stimulus onset
hold on
line([lowbound upperbound],[0 0],'Color','k','Linewidth',1); % horizontal stimulus onset

% no clutter, fixation attention
subplot(2,2,2)
imagesc(timepoints(timewindow),timepoints(timewindow),squeeze(ssTGM(:,:,nocl,nocl,digits,digits))); 
title('S05: no clutter, fixation attention')
axis square
axis xy
line([lowbound upperbound],[lowbound upperbound],'Color','k','Linewidth',1); % line through diagonal
hold on
line([0 0],[lowbound upperbound],'Color','k','Linewidth',1); % vertical stimulus onset
hold on
line([lowbound upperbound],[0 0],'Color','k','Linewidth',1); % horizontal stimulus onset

% high clutter, periphery attention
subplot(2,2,3)
imagesc(timepoints(timewindow),timepoints(timewindow),squeeze(ssTGM(:,:,hicl,hicl,objects,objects))); 
title('S05: high clutter, peripheral attention')
axis square
axis xy
line([lowbound upperbound],[lowbound upperbound],'Color','k','Linewidth',1); % line through diagonal
hold on
line([0 0],[lowbound upperbound],'Color','k','Linewidth',1); % vertical stimulus onset
hold on
line([lowbound upperbound],[0 0],'Color','k','Linewidth',1); % horizontal stimulus onset

% high clutter, fixation attention
subplot(2,2,4)
imagesc(timepoints(timewindow),timepoints(timewindow),squeeze(ssTGM(:,:,hicl,hicl,digits,digits))); 
title('S05: high clutter, fixation attention')
axis square
axis xy
line([lowbound upperbound],[lowbound upperbound],'Color','k','Linewidth',1); % line through diagonal
hold on
line([0 0],[lowbound upperbound],'Color','k','Linewidth',1); % vertical stimulus onset
hold on
line([lowbound upperbound],[0 0],'Color','k','Linewidth',1); % horizontal stimulus onset
