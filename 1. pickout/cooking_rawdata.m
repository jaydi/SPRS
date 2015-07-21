
function [ feature ] = cooking_rawdata( feature )

STATE_FIELDNAMES = {'RingerMode'; 'HeadsetOn'; 'BTHeadsetOn'; 'WIFI'; 'PlugOn'; 'Phone'; 'Battery'; 'IsWeekend'};

for i = 1:length(STATE_FIELDNAMES)
    cur_fieldname = char(STATE_FIELDNAMES(i));
    feature.(cur_fieldname) = getState(feature.(cur_fieldname), feature.Time);
end

% Notification state
feature.Access = getNotiState(feature.Access, feature.Time);

% Battery drain speed
feature.Battery = getBatteryAttributes(feature.Battery, feature.PlugOn, feature.Time);

% Location state (moving / stopped / unknown)
feature.Location = getLocationAttributes(feature.Location);

% Calling time (unavailable)
feature.Phone = getPhoneAttributes(feature.Phone, feature.Time);

end


function [ feature_field ] = getState( feature_field, Label_Time )

UNKNOWN_STATE = -1;
UNKNOWN_INTERVAL = 0;

% Get app history time
% Label_Time = feature_field.Time;
nTime = length(Label_Time);

cur_field = feature_field;

cur_field.curState = zeros(nTime, 1, 'int8');
cur_field.prevState = zeros(nTime, 1, 'int8');
cur_field.cur_elapsed = zeros(nTime, 1);
cur_field.prev_elapsed = zeros(nTime, 1);


cstate = UNKNOWN_STATE;
pstate = UNKNOWN_STATE;
cetime = UNKNOWN_INTERVAL;
petime = UNKNOWN_INTERVAL;
j = 0;

for i = 1:nTime
    if j+1 <= length(cur_field.Time)
        if Label_Time(i) > cur_field.Time(j+1)
            j = j + 1;

            pstate = cstate;
            cstate = cur_field.Integer(j);
            if j > 1
                petime = cur_field.Time(j) - cur_field.Time(j-1);
            end
        end
    end
    if j > 0
        cetime = Label_Time(i) - cur_field.Time(j);
    end
    
    
    cur_field.curState(i) = cstate;
    cur_field.prevState(i) = pstate;
    cur_field.cur_elapsed(i) = cetime;
    cur_field.prev_elapsed(i) = petime;
end
feature_field = cur_field;

end


function [ feature_field ] = getBatteryAttributes(feature_field, feature_field2, Label_Time)

UNKNOWN_SPEED = -1;

nTime = length(Label_Time);

cur_field = feature_field;
cur_field.DrainSpeed = zeros(nTime, 1);
cur_field2 = feature_field2;

btime = 0;

cspeed = UNKNOWN_SPEED;

for i = 1:nTime
    cur_cap = cur_field.curState(i);
    if (cur_field.prev_elapsed(i) == 0) || (i == 1)
        cspeed = UNKNOWN_SPEED;
    else
        if cur_field2.curState(i) == 0
            btime = btime + cur_field.prev_elapsed(i);
            cspeed = 1/btime*1000;
            if cur_cap ~= pre_cap
                btime = 0;
            end
        else
            cspeed = 0;
        end
    end
    
    cur_field.DrainSpeed(i) = cspeed;
    pre_cap = cur_cap;
end
feature_field = cur_field;

end

function [ feature_field ] = getLocationAttributes(feature_field)

UNKNOWN_STATUS = -1;
R = 6371; % radius of Earth in kilometer

cur_field = feature_field;
nTime = length(cur_field.Time);
cur_field.MovingSpeed = zeros(nTime, 1);
cur_field.curState = zeros(nTime, 1, 'int8');

cur_stat = UNKNOWN_STATUS;

cur_field.curState(1) = cur_stat;
cur_field.MovingSpeed(1) = 0;

point5diff = 0;
found = 0;

for i = 2:nTime
    if found == 1
        point5 = i;
        found = 0;
    else
        point5 = i - point5diff;
    end
    while point5 > 1
        if (cur_field.Time(i) - cur_field.Time(point5)) >= 1000*60*5 % 5 min
            found = 1;
            break;
        end
        point5 = point5 - 1;
    end
    point5diff = i - point5;
    % calculating distance between two points
    dLat = degtorad(cur_field.Double(i,1) - cur_field.Double(point5,1));
    dLon = degtorad(cur_field.Double(i,2) - cur_field.Double(point5,2));
    lat1 = degtorad(cur_field.Double(point5,1));
    lat2 = degtorad(cur_field.Double(i,1));

    a = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(lat1) * cos(lat2); 
    c = 2 * atan2(sqrt(a), sqrt(1-a)); 
    d = R * c;
    
    time_diff = cur_field.Time(i)-cur_field.Time(point5);
    
    if (time_diff > 0) && (time_diff < 1000*60*10) % between 5 min and 10 min
        mov_speed = d/(time_diff/1000/3600); % moving speed in km/h
        if abs(mov_speed) >= 2
            if abs(mov_speed) < 1000
                cur_stat = 1; % moving
            else
                cur_stat = UNKNOWN_STATUS;
            end
        else 
            cur_stat = 0; %stopped
        end
    else
        mov_speed = 0;
        cur_stat = UNKNOWN_STATUS;
    end
    
    cur_field.MovingSpeed(i) = mov_speed;

    cur_field.curState(i) = cur_stat;
end
feature_field = cur_field;

end

function [ feature_field ] = getPhoneAttributes(feature_field, Label_Time)

UNKNOWN_INTERVAL = -1;

OFFHOOK = 2;
RINGING = 1;

nTime = length(Label_Time);

cur_field = feature_field;
cur_field.CallTime = zeros(nTime, 1);

ctime = UNKNOWN_INTERVAL;
cur_field.CallTime(1) = ctime;

for i = 2:nTime
    void = 1;
    ctime = UNKNOWN_INTERVAL;
    if cur_field.curState(i) == OFFHOOK
        pointC = i;
        while pointC > 1
            pointC = pointC - 1;
            if cur_field.curState(pointC) == RINGING
                void = 0;
                break;
            elseif cur_field.curState(pointC) == OFFHOOK
                void = 1;
                break;
            end
        end
        
        if void == 0
            ctime = Label_Time(i) - Label_Time(pointC);
        end
    end
    
    cur_field.CallTime(i) = ctime;
end
feature_field = cur_field;

end

function [ feature_field ] = getNotiState(feature_field, Label_Time)


UNKNOWN_STATE = '';
UNKNOWN_INTERVAL = 0;
TIME_TH = 5;

% Get app history time
% Label_Time = feature_field.Time;
nTime = length(Label_Time);

cur_field = feature_field;

cur_field.curState = cell(nTime, 1);
% cur_field.prevState = cell(nTime, 1);
cur_field.cur_elapsed = zeros(nTime, 1);
% cur_field.prev_elapsed = zeros(nTime, 1);


cstate = UNKNOWN_STATE;
% pstate = UNKNOWN_STATE;
cetime = UNKNOWN_INTERVAL;
% petime = UNKNOWN_INTERVAL;
j = 1;

for i = 1:nTime
    while j+1 <= length(cur_field.Time)
        if Label_Time(i) < cur_field.Time(j+1)
%             pstate = cstate;
            cstate = cur_field.String{j};
%             if j > 1
%                 petime = cur_field.Time(j) - cur_field.Time(j-1);
%             end
            break;
        else
             j = j + 1;
        end
    end
    if j > 0
        cetime = Label_Time(i) - cur_field.Time(j);
    end
    
    if cetime <= 1000*60*TIME_TH % TIME_TH min
        cur_field.curState(i) = {cstate};
    else
        cur_field.curState(i) = {UNKNOWN_STATE};
    end
%     cur_field.prevState(i) = {pstate};
    cur_field.cur_elapsed(i) = cetime;
%     cur_field.prev_elapsed(i) = petime;
end
feature_field = cur_field;

end