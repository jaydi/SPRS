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

train_percentage = 0.8;

STATE_FIELDNAMES = {'Moving'; 'RingerMode'; 'HeadsetOn'; 'BTHeadsetOn'; 'WIFI'; 'PlugOn'; 'Phone'; 'Battery'};

for i = 1:length(Extracted_Feature)
    fprintf('**************************\n');
    fprintf('Start Recommending for user %s\n', Extracted_Feature(i).IMEI);
    fprintf('**************************\n\n');
    User(i).IMEI = Extracted_Feature(i).IMEI;
    
    User(i).Label = Extracted_Feature(i).Label;
    
    tmpTime = Extracted_Feature(i).Time;
    
    if isempty(tmpTime)
        count_err = count_err + 1;
        saved_err_i(count_err) = i;
        continue;
    end

    size_log = length(tmpTime);
    
    hour_form = rem(tmpTime, 24*60*60*1000) / (60*60*1000);
    User(i).Feature = [sin(2*pi*(hour_form/24)), cos(2*pi*(hour_form/24))];    
    
    User(i).Feature(:,3:4) = Extracted_Feature(i).Location;
    
    for j = 1:length(STATE_FIELDNAMES)
        cur_fieldname = char(STATE_FIELDNAMES(j));
        User(i).Feature(:,j+4) = Extracted_Feature(i).(cur_fieldname);
        User(i).Gain(j) = get_gain(User(i).Feature(:,j+4), User(i).Label);
    end
    
    
    
    bound = int32(abs(size_log*train_percentage));
    num_test = double(size_log - bound);
    
    User(i).Tree = fitctree(User(i).Feature(1:bound,:), User(i).Label(1:bound));
    User(i).Result = predict(User(i).Tree, User(i).Feature(bound+1:end,:));

    
    User(i).Result(:,2) = User(i).Label(bound+1:end,1);
    User(i).BaseApp = mode(User(i).Label(1:bound));
    
    User(i).BaseAcc = sum(User(i).Result(:,2) == User(i).BaseApp) / num_test;
    
    
    
    hit = 0;
    for k = 1:num_test
        if User(i).Result(k,1) == User(i).Result(k,2)
            hit = hit + 1;
        end
    end
    
    
    User(i).Acc = hit / num_test;
    
    if ~isempty(User(i).Acc)
        weighted_sum = weighted_sum + num_test * [User(i).BaseAcc, User(i).Acc];
        length_sum = length_sum + num_test;

        acc_sum = acc_sum + [User(i).BaseAcc, User(i).Acc];
        user_count = user_count + 1;
    end
    if length_sum ~= 0 || user_count ~= 0
        weighted_acc = weighted_sum / length_sum;
        total_acc = acc_sum / user_count;
    end    
    
    %predict(tree,X)
    if ispc
        save('.\Result_Tree.mat', 'User', 'weighted_acc', 'total_acc');
    else
        save('./Result_Tree.mat', 'User', 'weighted_acc', 'total_acc');
    end    
end