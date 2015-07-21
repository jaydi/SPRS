clear; clc;

load('..\Result3.mat');
STATE_NAMES = {'Moving', 'RingerMode', 'BTHeadsetOn', 'HeadsetOn', 'WIFI', 'PlugOn', 'Phone'};

nUser = length(Calculated_Feature);
nState = length(STATE_NAMES);

Score = zeros(nUser, nState);
Bins = zeros(nUser, nState);
for i = 1:nUser
    fprintf('\nUser %d : ', i);
    Label = Calculated_Feature(i).Label;
    nBin = 10;
    for j = 1:nState
        cur_feature = Calculated_Feature(i).(STATE_NAMES{j});
        
        if isempty(cur_feature)
            Score(i, j) = -10;
            continue;
        end
        
        [Score(i, j), Bins(i, j)] = getNormEntropy(cur_feature, Label, nBin, 1);
    end
end

cScore = zeros(nUser, 1);
fprintf('\n\nTime :\n');
for i = 1:nUser
    fprintf('\nUser %d : ', i);
    Label = Calculated_Feature(i).Label;
    cur_feature = Calculated_Feature(i).Time;
    if isempty(cur_feature)
        cScore(i) = -10;
        continue;
    end
    hour_form = rem(cur_feature, 24*60*60*1000) / (60*60*1000);
    cScore(i) = getNormEntropy(hour_form, Label, 24, 0);
end