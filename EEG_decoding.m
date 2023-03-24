function EEG_decoding(steps,permutations,sbj)
% Time-resolved- and generalized EEG cross-decoding of object location
% across categories.

% Input:
%       steps: time steps to analyze, integer. 1= 1 ms resolution. Use steps=10 to
%       downsample to 10 ms resolution to make script run faster
%       permutations: how many permutations, integer, 25 recommended
%       sbj: subject's number, integer
tic

% add & define paths
addpath('./HelperFunctions');
addpath('./LibsvmFunctions');
savepath   = './Results/EEG/';
sourcepath = './Data/EEG/';
if ~isdir(savepath); mkdir(savepath); end
filename   = ['EEG' ];
chance     = 50; % subtract this later
chan_idx   = [7 9:24 40 42:55 57]; % mid- and posteror channels
% load data. Dimensions: 64 conditions x 60 trials x 63 channels x 1100 time points
load(sprintf([sourcepath 's%.2d_EEG.mat'],sbj));

% define which time points to analyze
timewindow = 1:steps:length(timepoints);

% subsample timepoints from data (if steps>1, otherwise will take all) and
% take electrodes to look at
data = data(:,:,chan_idx,timewindow);

% coding of conditions in design matrix
object       = 1; % for indexing
digit        = 2;
bins         = 4;
binsize      = round(size(data,2)/bins);
locations    = 4;
categories   = 4;
nobg         = 1; % for indexing
bg           = 2;
train_col    = 1:bins-1;
test_col     = bins;
labels_train = vertcat(ones(length(train_col),1),2*ones(length(train_col),1) );
labels_test  = vertcat(ones(length(test_col),1),2*ones(length(test_col),1));

% load design matrix
% dimensions: categories x locations x background x attention
load('DesignMatrix_64x4.mat');

% preallocate results RDM
RDM = single(nan(permutations,bg,bg,digit,digit,locations,locations,categories,categories,length(timewindow),length(timewindow)));

for iperm = 1:permutations
    
    % print progress
    sprintf('Permutation #%d',iperm)
    
    % before each permutation, bin the data with random assignment of trials to bins
    perm_data   = data(:,randperm(size(data,2)),:,:);
    binned_data = reshape(perm_data, [size(perm_data,1) binsize bins size(perm_data,3) size(perm_data,4)] ); clear perm_data
    binned_data = squeeze(nanmean(binned_data,2)); % average trials in bins to get new pseudo-trials
    
    % multivariate noise normalization and whitening
    [white_data] = mvnn_whitening(binned_data,1:bins-1); clear binned_data
    
    % now perform pairwise cross-decoding of all location pairs, across and within 
    % all combinations of backgrounds, attention conditions, categories and
    % time points
    
    for bgA = 1:bg
        for bgB = 1:bg
            
            for attA = 1:digit
                for attB = 1:digit
                    
                    for locationA = 1:locations
                        for locationB = 1:locations
                            
                            for catA = 1:categories
                                for catB = 1:categories
                                    
                                    % get conditions for this iteration
                                    trainA = find(DM(:,1)==catA & DM(:,2)==locationA & DM(:,3)==bgA-1 & DM(:,4)==attA);
                                    trainB = find(DM(:,1)==catA & DM(:,2)==locationB & DM(:,3)==bgA-1 & DM(:,4)==attA);
                                    
                                    testA  = find(DM(:,1)==catB & DM(:,2)==locationA & DM(:,3)==bgB-1 & DM(:,4)==attB);
                                    testB  = find(DM(:,1)==catB & DM(:,2)==locationB & DM(:,3)==bgB-1 & DM(:,4)==attB);
                                    
                                    for iTime = 1:length(timewindow)
                                        
                                        % extract conditions for training and
                                        % testing set
                                        traindataA = squeeze(white_data(trainA,train_col,:,iTime));
                                        traindataB = squeeze(white_data(trainB,train_col,:,iTime));
                                        
                                        testdataA = squeeze(white_data(testA,test_col,:,:));
                                        testdataB = squeeze(white_data(testB,test_col,:,:));
                                        
                                        % for current location pair, cross-decode at all timepoints
                                        [RDM(iperm,bgA,bgB,attA,attB,locationA,locationB,catA,catB,iTime,:)] = ...
                                         Xtime_traintest(traindataA,traindataB,testdataA,testdataB,labels_train,labels_test);
                                    end
                                    
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

duration = toc;

%% arrange RDM for extracting results
% average RDM across permutations
TGM.RDM = squeeze(nanmean(RDM,1))-chance; clear RDM

% prepare location across backgrounds, within attention
% put location in the back
% bg x bg x att x att x loc x loc x cat x cat x time x time
temp = permute(TGM.RDM,[7 8 9 10 1 2 3 4 5 6 ]);

% now its cat x cat x time x time x bg x bg x att x att loc x loc
% average across upper off diagonal which is location decoding
TGM =  squeeze(nanmean(temp(:,:,:,:,:,:,:,:,triu(ones(4,4),1)>0),9));

duration = toc;

% save result
save([savepath 's' sprintf('%.2d',sbj) '_' filename '.mat' ],'TGM','timepoints','timewindow','duration','-v7.3');
end