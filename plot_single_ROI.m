function plot_single_ROI(myData,mask,legend_labels,roiname,yl,C)

nbg = 2;
att = 2;

%% Figure Setup
hf = figure('position',[1,1,500, 750], 'unit','pixel');
set(gcf,'PaperUnits','centimeters','PaperSize',[30,60],'PaperPosition',[0,0,30,60]);
colordef white
set(0,'DefaultAxesFontName', 'Helvetica')
set(0,'DefaultTextFontname', 'Helvetica')
set(0,'DefaultAxesFontSize',15)
set(0,'DefaultTextFontSize',15)
set(gcf,'Color','w')

%% Barplot

hold on

%fake bars (for legend)
h=bar(0,0);
set(h,'facecolor',C{1});
set(h,'linewidth',3);
h=bar(0,0);
set(h,'facecolor',C{2});
set(h,'linewidth',3);
h=bar(0,0);
set(h,'facecolor',C{3});
set(h,'linewidth',3);
h=bar(0,0);
set(h,'facecolor',C{4});
set(h,'linewidth',3);

%means
means = mean(myData);

xb        = nan(nbg,att); % vector containing bar positions
space_vec = [3:2:(nbg*att)-1];
xb(1,1)=1.05;
for j = 2:length(means) % rois x bgs
    
    if ismember(j,space_vec) % big step before new ROI
        xb(j)=xb(j-1)+1.3;
    else
        xb(j)=xb(j-1)+0.85; % small step between bgs
    end
    
end
xb = xb(:); % straighten bar positions
se = std(myData)/sqrt(size(myData,1));

% plot
for ibar=1:length(means) % rois x bgs
    
    % plot the bar
    h = bar(xb(ibar),means(ibar)); % xb says where m(i) what
    set(h,'facecolor',C{ibar});
    set(h,'linewidth',3);
    
    % plot the error bars
    hl = line([xb(ibar),xb(ibar)],[means(ibar)-se(ibar),means(ibar)+se(ibar)]);
    set(hl,'linewidth',3);
    set(hl,'color','k');
    
    % Significance Marker
    if mask(ibar)==1
        
        h=text(xb(ibar)-0.15,(means(ibar)+se(ibar)+0.05),'*');
        set(h,'fontsize',36);
    end
    
end

% Legend
L=legend(legend_labels);
set(L,'box','off');

% other plot properties
ylabel('Classification accuracy - chance-level (%)');
set(gca,'linewidth',3);
set(gca,'xtick',median(reshape(xb,[nbg,att]))); % where to put labels
set(gca,'xticklabel',{'No clutter','High clutter'});
axis tight
ylim(yl);
xlim([0.2 length(means)+1]);
set(gca,'ticklength',2*get(gca,'ticklength'))
title([roiname])

