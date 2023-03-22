function ROI_decoding(sbj)
% classification of location across category in fMRI experiment for all ROIs 
% in single subject.

% Duration: 6 seconds

% Input:
%   sbj: string

tic

addpath('./HelperFunctions');
addpath('./LibsvmFunctions');
savepath   = './Results/fMRI/';
if ~isdir(savepath); mkdir(savepath); end
filename   = ['s' sprintf('%.2d',sbj) '_ROI'];
ROIs       = {'V1' 'V2' 'V3' 'V4' 'LO' 'IPS0' 'IPS1' 'IPS2' 'SPL'};
ROI.labels = ROIs;

% define classification parameters
runs         = 10; % number of fMRI runs
attentions   = 2; % n attention conditions
bg           = 2; % n background conditions
locations    = 2; % n locations
categories   = 2; % n categories
bins         = 2;
result       = nan(length(ROIs),attentions,bg); % pre-allocate results matrix
chance_level = 50;

%% SVM classification

% loop through ROI's
for iROI = 1:length(ROIs)
    
    % load data. Dimensions: 10 runs x 2 attention x 2 backgrounds x 2
    % locations x 2 categories x voxels
    load(sprintf(['./Data/fMRI/s%.2d/s%.2d_' ROIs{iROI} '.mat'],sbj,sbj));
    
    % randomize and average in bins of 2 to decode on 5 pseudo-runs
    data = data(randperm(size(data,1)),:,:,:,:,:); % randomize runs
    data = reshape(data,[bins (runs/bins) attentions bg locations categories size(data,6)]);
    data = squeeze(nanmean(data,1)); % average trials in bins to get new pseudo-trials
    
    % set the labels for SVM
    labels_train   = [ones(1,(size(data,1))-1) 2*ones(1,(size(data,1))-1)]; % labels for training
    labels_test    = [1 2]; % labels for the left out run
    
    % preallocate
    RDM = nan(size(data,1),attentions,bg,locations,locations,categories,categories);
    
    for iRun = 1:size(data,1)
        
        iTrainRun = find([1:size(data,1)]~=iRun);  % index to runs for training (all except one)
        iTestRun  = iRun;                          % index to run for testing (the one left out)
        
        for iAtt = 1:attentions
            
            for iBG = 1:bg
                
                for LocationA = 1:locations
                    for LocationB = 1:locations
                        
                        for CatA = 1:categories
                            for CatB = 1:categories
                                
                                data_train = [squeeze(data(iTrainRun,iAtt,iBG,LocationA,CatA,:));...
                                                squeeze(data(iTrainRun,iAtt,iBG,LocationB,CatA,:))];
                                
                                data_test  = [squeeze(data(iTestRun,iAtt,iBG,LocationA,CatB,:))';...
                                                squeeze(data(iTestRun,iAtt,iBG,LocationB,CatB,:))'];
                                
                                model = libsvmtrain(labels_train',data_train,'-s 0 -t 0 -q');
                                
                                [predicted_label, accuracy, decision_values] = libsvmpredict(labels_test', data_test, model);
                                
                                RDM(iRun,iAtt,iBG,LocationA,LocationB,CatA,CatB) = accuracy(1); % save accuracy
                                
                            end
                        end
                    end
                end
            end
        end
        
    end
    
    % average across runs
    % runs x att x bg x loc x loc x cat x cat
    temp                      = squeeze(nanmean(RDM,1))-chance_level;
    ROI.RDM(iROI,:,:,:,:,:,:) = temp; clear RDM % mean across runs
    %--> % att x bg x loc x loc x cat x cat
    
    % put location in the back
    results = permute(temp,[5 6 1 2 3 4]); clear temp
    %--> cat x cat x att x bg x loc x loc
    
    % average across upper off-diagonal, which is location decoding
    results = results(:,:,:,:,triu(ones(2,2),1)>0);
    % --> cat x cat x att x bg
    
    % put category in the back to take across cateroy
    results = permute(results,[3 4 1 2]);
    % --> att x bg x cat x cat
    
    ROI.results(iROI,:,:) = squeeze(nanmean(results(:,:,eye(2,2)==0),3)); clear results
    
end

duration = toc;

% save
save([savepath filename  '.mat'],'ROI','duration');
