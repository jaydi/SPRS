clear; clc;
if ispc
    load('..\Result2.mat', '-mat');
else
    load('../Result2.mat', '-mat');
end

count_err = 0;
weighted_sum = zeros(1, 2);
acc_sum = zeros(1, 2);
length_sum = 0;
user_count = 0;
weighted_acc = zeros(1, 2);
total_acc = zeros(1, 2);

feature_list = {'RingerMode'; 'HeadsetOn'; 'BTHeadsetOn'; 'WIFI'; 'PlugOn'; 'Phone'};

train_percentage = 0.9;

for i=1:length(feature_list) + 1
    if i == 1
        Result(i,1) = RunMC(Extracted_Feature);
    else
        cur_feature = char(feature_list(i-1));
        Result(i,1) = RunMC(Extracted_Feature, cur_feature);
    end
end

% Result = RunMC(Extracted_Feature);

if ispc
    save('.\Result_MC_t.mat', 'Result');
else
    save('./Result_MC_t.mat', 'Result');
end