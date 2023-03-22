function plot_fMRI_result(iROI)
% Input:
%   iROI: integer

ROIs         = {'V1' 'V2' 'V3' 'V4' 'LOC' 'IPS0' 'IPS1' 'IPS2' 'SPL'};
subjects     = [1:3 5:9 11:16 18:23];
bg           = 2;
att          = 2;
data         = nan(length(subjects),bg*att); % dim: subjects x [2bg*ROIs]
ylimit       = [-8 30];
alpha        = 0.05;
C            =  {[0.2 0.2 0.2],[0.6,0.6,0.6],[0,0,1],[0.4,0.7,0.9]};
legend_label = {'Objects no clutter','Digits no clutter',...
                'Objects high clutter','Digits high clutter'};
roiname        = ROIs{iROI};

% rearrange data dimensions for plotting
for s = 1:length(subjects)
    
    load(['./Results/fMRI/s' sprintf('%.2d',subjects(s)) '_ROI.mat' ]);
    % dims: rois x attention x background
    
    data(s,:) = squeeze(ROI.results(iROI,:)); % subj x [ObjNo,DigNo,ObjHigh,DigHigh]
end

% test ROI condition against chance
for itest = 1:size(data,2)
    
    [p_rois(itest), h(itest)] = signrank(data(:,itest)); % subjects x conditions per roi
    [mask, crit_p, adj_ci_cvrg, adj_p] = fdr_bh(p_rois,alpha,'pdep');
    
end

% plot result
plot_single_ROI(data,mask,legend_label,roiname,ylimit,C);
