function [ feature ] = pickout( rec, hashtable )

task_id = 38; % CURRENT_TASK_ACTIVITY
loc_id = 25; % LOCATION
scr_id = 39; % SCREEN_ON

ring_id = 4; % RINGER MODE
headset_id = 5; % IS_WIRED_HEADSET_ON
bluehs_id = 6; % IS_BLUETOOTH_HEADSET_ON
wifi_id = 31; % WIFI_STATE
plug_id = 37; % BATTERY_PLUG_MODE
battery_id = 46; % BATTERY_LEVEL
phone_id = 7; % PHONE_STATE
access_id = 62; % ACCESSIBILITY_EVENT


feature.IMEI = rec.IMEI;

% Get information
task_str = rec.Data(task_id).String;

% loc_double = rec.Data(loc_id).Double;
% loc_time = rec.Data(loc_id).Time;
% latitude = loc_double(2, :);
% longitude = loc_double(3, :);


len_feature = size(task_str, 2);


% Feature Field 1 : Time (2)
feature.Time = rec.Data(task_id).Time';


% Feature Field 2 : Location (2)
feature.Location.Double = [];
if ~isempty(rec.Data(loc_id).Double)
    feature.Location.Double = rec.Data(loc_id).Double(2:3, :)';
end
feature.Location.Time = rec.Data(loc_id).Time';

% for i = 1:len_feature
%     % find the best location index
%     [~, loc_index] = min(abs(loc_time - task_time(i)));
%     
%     feature.Location(i, 1) = latitude(loc_index);
%     feature.Location(i, 2) = longitude(loc_index);
% end


% Feature Field 3 : Screen On (1)
feature.ScreenOn.Integer = int8(rec.Data(scr_id).Integer');
feature.ScreenOn.Time = rec.Data(scr_id).Time';


% Feature Field 4 : Ringer Mode (1)
feature.RingerMode.Integer = int8(rec.Data(ring_id).Integer');
feature.RingerMode.Time = rec.Data(ring_id).Time';



% Feature Field 5 : Headset On (1)
feature.HeadsetOn.Integer = int8(rec.Data(headset_id).Integer');
feature.HeadsetOn.Time = rec.Data(headset_id).Time';


% Feature Field 6 : Bluetooth Headset On (1)
feature.BTHeadsetOn.Integer = int8(rec.Data(bluehs_id).Integer');
feature.BTHeadsetOn.Time = rec.Data(bluehs_id).Time';


% Feature Field 7 : WIFI (1)
feature.WIFI.Integer = int8(rec.Data(wifi_id).Integer');
feature.WIFI.Time = rec.Data(wifi_id).Time';


% Feature Field 8 : Plug On (1)
feature.PlugOn.Integer = int8(rec.Data(plug_id).Integer');
feature.PlugOn.Time = rec.Data(plug_id).Time';


% Feature Field 9 : Battery Level (1)
feature.Battery.Integer = int8(rec.Data(battery_id).Integer');
feature.Battery.Time = rec.Data(battery_id).Time';


% Feature Field 10 : Phone State (1)
feature.Phone.Integer = int8(rec.Data(phone_id).Integer');
feature.Phone.Time = rec.Data(phone_id).Time';


% Feature Field 11 : Acceessibility Event (?)
len_access = length(rec.Data(access_id).Time);
num_noti = 0;
for i=1:len_access
    acc_int2 = rec.Data(access_id).Integer(1,i);
    if acc_int2 == 64
        num_noti = num_noti + 1;
%         feature.Access.Integer(num_noti,1) = int8(rec.Data(access_id).Integer(1,i)');
        feature.Access.Time(num_noti,1) = rec.Data(access_id).Time(i);
        
        acc_string = rec.Data(access_id).String(:, i);
        acc_word = char(hashtable(acc_string(1)));
        for j = 2:11
            if acc_string(j) == 0
                break;
            else
                acc_word = [acc_word, '.', char(hashtable(acc_string(j)))];
            end
        end

         feature.Access.String(num_noti,1) = {acc_word};
%          feature.Access.String(num_noti,:) = uint32(rec.Data(access_id).String(:,i)');
    end
end
if num_noti == 0
%     feature.Access.Integer(1,1) = int8(zeros(1,1));
    feature.Access.Time(1,1) = 0;
    feature.Access.String(1,1) = cell(1,1);
end

% Feature Field 12 : IsWeekend (weekday or weekend) (1)
tmpWeekend = weekday(rec.Data(task_id).Time'/86400/1000 + datenum(1970,1,1));
tmpWeekend(tmpWeekend == 7) = 1;
tmpWeekend(tmpWeekend ~= 1) = 0;
feature.IsWeekend.Integer = int8(tmpWeekend);
feature.IsWeekend.Time = rec.Data(task_id).Time';

% Label Field : AppName
% Get words from hashtable
feature.AppName = {};
for i = 1:len_feature
    cur_string = task_str(:, i);
    
    cur_word = char(hashtable(cur_string(1)));
    for j = 2:11
        if cur_string(j) == 0
            break;
        else
            cur_word = [cur_word, '.', char(hashtable(cur_string(j)))];
        end
    end
    
    feature.AppName(i, 1) = {cur_word};
end



end

