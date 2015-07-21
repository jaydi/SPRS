clear;

% Load mat filenames
if ispc
    matDir = '..\matData';
else
    matDir = '../matData';
end

fprintf('Merging data files');

listing = dir(matDir);

nmat = length(listing); % number of mat files

matfiles_name = cell(nmat, 1);
IMEIcell = cell(nmat, 1);
k = 1;
for i = 1:nmat
    cur_filename = listing(i).name;
    if isempty(regexp(cur_filename,'^.*\.(mat)$','ignorecase'))
        continue;
    end
    matfiles_name(k) = cellstr(cur_filename);
    
    % IMEI Detector
    j = 1;
    while listing(i).name(j) ~= '_'
        j = j + 1;
    end
    IMEIcell(k) = {listing(i).name(1:j-1)};
    
    k = k + 1;
    if rem(i,20) == 0
        fprintf('.');
    end
end

nmat = k-1;

matfiles_name = matfiles_name(1:nmat);
IMEIcell = IMEIcell(1:nmat);

% Ordering by IMEI numbers
[~, name_order] = sort(str2double(IMEIcell));
matfiles_name = matfiles_name(name_order);

fprintf('complete!\n');

% Load string hashtable from check_hashed.txt
if ispc
    fid = fopen('..\matData\check_hashed.txt');
elseif ismac
    fid = fopen('../matData/check_hashed.txt');
else
    fid = fopen('../matData/check_hashed_utf8.txt');
end

fprintf('Loading hashtables');

nline = 0;
tline = fgetl(fid);
while ischar(tline)
    nline = nline + 1;
    
    i = 1;
    while tline(i) ~= ','
        i = i + 1;
    end
    tline = tline(i+1:end);
    
    hashtable(nline, 1) = {tline};
    tline = fgetl(fid);
end
fclose(fid);
% hashtable made

fprintf('...................complete!\n');

fprintf('Merging features');

% Load matfiles
user_id = [];
IT_FIELDNAMES = {'ScreenOn'; 'RingerMode'; 'HeadsetOn'; 'BTHeadsetOn'; 'WIFI'; 'PlugOn'; 'Battery'; 'Phone'; 'IsWeekend'};
for i = 1:nmat
    % Step 1
    % Load matfile and check user number(IMEI)
    if ispc
        load([matDir, '\', char(matfiles_name(i))], '-mat');
    else
        load([matDir, '/', char(matfiles_name(i))], '-mat');
    end
    
    % Step 2
    % Confirm availability of data
%     if isempty(rec.Data(38).Time)
%         continue;
%     end
    % More Functions needed
    
    % Step 3
    % Pick out some base information from data
    cur_feature = pickout(rec, hashtable);
    
    % Step 4
    % Merge features if there is same IMEI data
    cur_uid = str2double(cur_feature.IMEI);
    if isempty(user_id)
        uindex = 1;
        user_id(uindex, 1) = cur_uid;
        Merged_Feature = cur_feature;
    else
        uindex = find(user_id == cur_uid);
        if isempty(uindex)
            uindex = length(user_id) + 1;
            user_id(uindex, 1) = cur_uid;
            Merged_Feature(uindex, 1) = cur_feature;
        else
            Merged_Feature(uindex, 1).Time = [Merged_Feature(uindex, 1).Time; cur_feature.Time];
            
            Merged_Feature(uindex, 1).Location.Double = [Merged_Feature(uindex, 1).Location.Double; cur_feature.Location.Double];
            Merged_Feature(uindex, 1).Location.Time = [Merged_Feature(uindex, 1).Location.Time; cur_feature.Location.Time];
            
            for j = 1:length(IT_FIELDNAMES)
                cur_fieldname = char(IT_FIELDNAMES(j));
                Merged_Feature(uindex, 1).(cur_fieldname).Integer = [Merged_Feature(uindex, 1).(cur_fieldname).Integer; cur_feature.(cur_fieldname).Integer];
                Merged_Feature(uindex, 1).(cur_fieldname).Time = [Merged_Feature(uindex, 1).(cur_fieldname).Time; cur_feature.(cur_fieldname).Time];
            end
            
%             Merged_Feature(uindex, 1).Access.Integer = [Merged_Feature(uindex, 1).Access.Integer; cur_feature.Access.Integer];
            Merged_Feature(uindex, 1).Access.String = [Merged_Feature(uindex, 1).Access.String; cur_feature.Access.String];
%             Merged_Feature(uindex, 1).Access.Double = [Merged_Feature(uindex, 1).Access.Double; cur_feature.Access.Double];
            Merged_Feature(uindex, 1).Access.Time = [Merged_Feature(uindex, 1).Access.Time; cur_feature.Access.Time];
            
            Merged_Feature(uindex, 1).AppName = [Merged_Feature(uindex, 1).AppName; cur_feature.AppName];
        end
    end
    if rem(i,20) == 0
        fprintf('.');
    end
end

fprintf('complete!\n');

fprintf('Processing feature data');
for i = 1:length(Merged_Feature)
    Merged_Feature(i) = cooking_rawdata(Merged_Feature(i));
    if rem(i,3) == 0
        fprintf('.');
    end
end
fprintf('complete!\n');


fprintf('Saving results.....');
if ispc
    save('..\Result1.mat', 'Merged_Feature', '-v7.3');
else
    save('../Result1.mat', 'Merged_Feature', '-v7.3');
end
fprintf('complete!\n');