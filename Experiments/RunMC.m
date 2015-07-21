function [ Result ] = RunMC( Extracted_Feature, feature )

count_err = 0;
weighted_sum = zeros(1, 2);
acc_sum = zeros(1, 2);
length_sum = 0;
user_count = 0;

train_percentage = 0.9;

for i = 1:length(Extracted_Feature)
    if ~exist('feature','var')
        MODE = 0;
        num_slot = 1;
        feat = 'N/A';
    else
        MODE = 1;
        feat = feature;
        cur_feature = Extracted_Feature(i).(feature);
        cur_feature_member = unique(cur_feature);
        num_slot = length(cur_feature_member);
    end
    
    fprintf('**************************\n');
    fprintf('Start Recommending for user %s\n', Extracted_Feature(i).IMEI);
    fprintf('**************************\n\n');
    Result.IMEI{i} = Extracted_Feature(i).IMEI;
    
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
    num_Dimension = 1; % initial # of apps = 1
    
    % initializing transition event storage
    num_Transition = cell(num_slot,1);
    TransitionMatrix = cell(num_slot,1);
    for k=1:num_slot
        num_Transition{k} = zeros(1);
    end
    
    for b=1:bound
        % collect data until no data is found
        try
            cur_AppID = Extracted_Feature(i).Implicit.Tr_Label(b,2);
        catch 
            break;
        end
        
        old_AppID = Extracted_Feature(i).Implicit.Tr_Label(b,1);
        
        %expand the transition kernel if new App detected%
        expand = max(cur_AppID,old_AppID);
        if (expand > num_Dimension)
            for k=1:num_slot
                num_Transition{k}(expand,expand) = 0;
            end
            num_Dimension = size(num_Transition{1},1); % expanding total # of Apps
        end
        
        %add 1 to # of transition that happened%
        if MODE == 0
            num_Transition{1}(old_AppID,cur_AppID) = num_Transition{1}(old_AppID,cur_AppID) + 1;
        else
            cur_slot = (cur_feature_member == cur_feature(b));
            num_Transition{cur_slot}(old_AppID,cur_AppID) = num_Transition{cur_slot}(old_AppID,cur_AppID) + 1;
        end
%         num_Transition(old_AppID,cur_AppID) = num_Transition(old_AppID,cur_AppID) + 1;

        %Adding total sum of transitions%
        total_Transition = total_Transition + 1;
    end
    
    for k=1:num_slot
        TransitionMatrix{k} = num_Transition{k} / total_Transition;
    end    
    Result.TransitionMatrix{i} = TransitionMatrix;
    
    Labels = Extracted_Feature(i).Label;
    Result.Label{i} = Labels;
    
    Recommend = zeros(1);
    
    for j = 1:num_test
        cur_App = Labels(bound+j-1,1);
        if cur_App <= num_Dimension
            if MODE == 0
                cur_Tr = TransitionMatrix{1}(cur_App,:);
            else
                cur_slot = (cur_feature_member == cur_feature(bound+j-1));
                if max(cur_slot) ~= 0
                    cur_Tr = TransitionMatrix{cur_slot}(cur_App,:);
                else
                    cur_Tr = zeros(num_Dimension,1);
                    for m = 1:num_slot
                        cur_Tr = cur_Tr + TransitionMatrix{m};
                    end
                    cur_Tr = cur_Tr(cur_App,:);
                end
            end
            [tval, Recommend(j,1)] = max(cur_Tr);
        else
            Recommend(j,1) = Recommend(j-1,1);
        end
    end
    
    Recommend(:,2) = Labels(bound+1:end,1);
    
    Result.BaseApp{i} = mode(Labels(1:bound));
    
    Result.BaseAcc{i} = sum(Recommend(:,2) == Result.BaseApp{i}) / num_test;
    
    hit = 0;
    for k = 1:num_test
        if Recommend(k,1) == Recommend(k,2)
            hit = hit + 1;
        end
    end
    
    Result.Recommend{i} = Recommend;
    
    Result.Acc{i} = hit / num_test;
    
    if ~isempty(Result.Acc{i})
        weighted_sum = weighted_sum + num_test * [Result.BaseAcc{i}, Result.Acc{i}];
        length_sum = length_sum + num_test;

        acc_sum = acc_sum + [Result.BaseAcc{i}, Result.Acc{i}];
        user_count = user_count + 1;
    end
    if length_sum ~= 0 || user_count ~= 0
        weighted_acc = weighted_sum / length_sum;
        total_acc = acc_sum / user_count;
    end    
     
end

Result.wacc = weighted_acc;
Result.acc = total_acc;

Result.Errors.num = count_err;
Result.Errors.where = saved_err_i;

Result.Feature = feat;
end