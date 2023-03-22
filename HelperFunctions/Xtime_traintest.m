function [time_vec] = Xtime_traintest(trainA,trainB,testA,testB,labels_train,labels_test)
% cross decode between condtions and across time.
% train on timepoint t and test on all other timepoints

% train
time_vec   = nan(1,size(testA,2));
train_data = [squeeze(trainA); squeeze(trainB)];
model      = libsvmtrain(labels_train, train_data,'-s 0 -t 0 -q');

% test
for iTime = 1:length(time_vec) % size of data
    
    test_data = [squeeze(testA(:,iTime))' ; squeeze(testB(:,iTime))' ]; % 2x63
    [predicted_label, l_accuracy, decision_values] = libsvmpredict(labels_test, test_data, model);
    time_vec(iTime) = [l_accuracy(1)]; clear predicted_label l_accuracy decision_values
    
end
end



