% Run Analysis

%% fMRI decoding
% whole sample
% should take a few seconds

subjects = [1:3 5:9 11:16 18:23];

% takes a few seconds
for isub = 1:length(subjects)
    ROI_decoding(subjects(isub));
end

% plot all ROIs
ROIs = {'V1' 'V2' 'V3' 'V4' 'LOC' 'IPS0' 'IPS1' 'IPS2' 'SPL'};
for iroi = 1:length(ROIs)
    plot_fMRI_result(iroi);
end

%% EEG decoding 
% for single example subject
% Duration: ~1h 15 min for 10 permutations

steps        = 20; % downsample time in 20 ms steps for speed. 
% Original parameters in manuscript: 
%       1 ms for time-resolved analysis
%       10 ms for time-generalization analysis
permutations = 5; % for speed. Original: 100 permutations
sbj          = 5;

% run classification analysis for this subject
EEG_decoding(steps,permutations,sbj);

% plot time-generalization results
plot_TGM(sbj);

% plot time-resolved results
plot_timecourse(sbj);




