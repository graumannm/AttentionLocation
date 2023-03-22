function plot_timecourse(sbj)

load(sprintf('./Results/EEG/s%.2d_EEG.mat',sbj));

% TGM: cat x cat x time x time x bg x bg x att x att
RDM = permute(TGM,[ 3 4 5 6 7 8 1 2]); % put category in the back
% --> time x time x bg x bg x att x att x cat x cat
ssTGM = nanmean(RDM(:,:,:,:,:,:,eye(2,2)==0),7); % extract location across categories
% --> time x time x bg x bg x att x att

% % figure settings
hf=figure('position',[1,1,750, 750], 'unit','pixel');
set(gcf,'PaperUnits','centimeters','PaperSize',[20,20],'PaperPosition',[0,0,20,20]);
colordef white
set(0,'DefaultAxesFontName', 'Helvetica')
set(0,'DefaultTextFontname', 'Helvetica')
set(0,'DefaultAxesFontSize',15)
set(0,'DefaultTextFontSize',15)
set(gcf,'Color','w')
set(gca,'linewidth',3);

% define condition indices
nocl    = 1; % no clutter
hicl    = 2; % high clutter
objects = 1; % periphery attention
digits  = 2; % fixation attention
% extract location across category

% line colors
colors = [[0 0 0];[0.6,0.6,0.6];[0,0,1];[0.4,0.7,0.9]];
ylimlow    = -15;
ylimup     = 45;
chance     = 0;
lowbound   = timepoints(timewindow(1));
upperbound = timepoints(timewindow(end));
ylabel     = 'Train time (ms)';
xlabel     = 'Test time (ms)';
t          = timepoints(timewindow);

h1=plot(t,diag(squeeze(ssTGM(:,:,nocl,nocl,objects,objects))),'color',colors(1,:),'linewidth',3 )
hold on
h2=plot(t,diag(squeeze(ssTGM(:,:,nocl,nocl,digits,digits))),'color',colors(2,:),'linewidth',3 )
hold on
h3=plot(t,diag(squeeze(ssTGM(:,:,hicl,hicl,objects,objects))),'color',colors(3,:),'linewidth',3 )
hold on
h4=plot(t,diag(squeeze(ssTGM(:,:,hicl,hicl,digits,digits))),'color',colors(4,:),'linewidth',3 )

l = legend([h1 h2 h3 h4],{'no clutter periphery','no clutter fixation',...
                        'high clutter periphery','high clutter fixation'}, 'AutoUpdate','off')
set(l,'box','off');
% stimulus onset
plot([0 0],[ylimlow ylimup],'k--','linewidth',3);
hold on
% chance line
plot(t,chance*ones(length(timewindow),1),'k--','linewidth',3)
axis([timepoints(1) timepoints(end) ylimlow ylimup])