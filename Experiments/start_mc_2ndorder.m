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

train_percentage = 0.9;

for i = 1:length(Extracted_Feature)
    fprintf('**************************\n');
    fprintf('Start Recommending for user %s\n', Extracted_Feature(i).IMEI);
    fprintf('**************************\n\n');
    User(i).IMEI = Extracted_Feature(i).IMEI;
    
    tmpTime = Extracted_Feature(i).Time;
    
    if isempty(tmpTime)
        count_err = count_err + 1;
        saved_err_i(count_err) = i;
        continue;
    end
    
    size_log = length(tmpTime);
    bound = int32(abs(size_log*train_percentage));
    num_test = double(size_log - bound);
    if num_test == 0
        bound = bound - 1;
        num_test = 1;
    end
    
    % STEP 1 : collecting App transition events
    
    %initializing variables%
    total_Transition = 0;
    j=0;
    num_Dimension = 1; % initial # of apps = 1
    
    % initializing transition event storage
    num_Transition = zeros(1);
    
    for b=2:bound
        % collect data until no data is found
        try
            cur_AppID = Extracted_Feature(i).Implicit.Tr_Label(b,2);
        catch error
            break;
        end
        
        old_AppID = Extracted_Feature(i).Implicit.Tr_Label(b,1);
        old2_AppID = Extracted_Feature(i).Implicit.Tr_Label(b-1,1);
        
        %expand the transition kernel if new App detected%
        expand = max(cur_AppID,old_AppID);
        if (expand > num_Dimension)
            num_Transition(expand^2,expand) = 0;
            num_Dimension = expand; % expanding total # of Apps
        end
        
        %add 1 to # of transition that happened%
        cur_index = num_Dimension * (old_AppID - 1) + old2_AppID;
        num_Transition(cur_index,cur_AppID) = num_Transition(cur_index,cur_AppID) + 1;

        %Adding total sum of transitions%
        total_Transition = total_Transition + 1;
    end
    
    User(i).TransitionMatrix = num_Transition / total_Transition;

    User(i).Label = Extracted_Feature(i).Label;
    
    for j = 2:num_test
        cur_App = User(i).Label(bound+j-1,1);
        old_App = User(i).Label(bound+j-2,1);
        if (cur_App <= num_Dimension) && (old_App <= num_Dimension)
            cur_index = num_Dimension * (cur_App - 1) + old_App;
            [tval User(i).Result(j,1)] = max(User(i).TransitionMatrix(cur_index,:));
            if User(i).Result(j,1) == 0
                cur_index = num_Dimension * (cur_App - 1) + 1;
                [tval User(i).Result(j,1)] = max(sum(User(i).TransitionMatrix(cur_index:cur_index+num_Dimension-1,:)));
            end
        else
            User(i).Result(j,1) = User(i).Result(j-1,1);
        end
    end
    
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
        save('.\Result_MC2.mat', 'User', 'weighted_acc', 'total_acc');
    else
        save('./Result_MC2.mat', 'User', 'weighted_acc', 'total_acc');
    end    
end