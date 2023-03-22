% Run Analysis

%% fMRI decoding
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


