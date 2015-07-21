function [ Cleaned_Feature, AppNameTable ] = clean_data( Merged_Feature )

passappname = {'com.lge.pa', 'com.lge.lmk', 'com.lge.tangible', 'com.lge.app.floating.res', ...
    'com.lge.shutdownmonitor', 'com.lge.boottimeanalyzer', 'com.lge.ckerrorreporterui', ...
    'com.google.android.googlequicksearchbox', 'com.lgcns.mdm', 'com.buzzvil.adhours', ...
    ...
    'android', 'com.android.settings', 'com.lge.settings.easy', 'com.lg.lgplt_qualityreport', ...
    'com.lge.lgdmsclient', ...
    'com.kakao.home', 'com.gau.go.launcherex', 'com.buzzpia.aqua.launcher', 'net.pierrox.lightning_launcher', ...
    'com.campmobile.launcher', 'com.teslacoilsw.launcher', ...
    'com.cashslide', ...
    ...
    'com.android.contacts', 'com.android.systemui', ...
    ...
    ...
    ...
    'com.android.LGSetupWizard', 'com.android.backupconfirm', 'com.android.certinstaller', ...
    'com.android.defcontainer', 'com.android.facelock', 'com.android.htmlviewer', 'com.android.inputdevices', ...
    'com.android.keychain', 'com.android.nfc', 'com.android.packageinstaller', 'com.android.providers', ...
    'com.android.stk', 'com.google.android.location', 'com.google.android.partnersetup', ...
    'com.google.android.partnersetup', 'com.google.android.setupwizard', 'com.google.android.syncadapters', ...
    'com.lge.BtWifiTest', 'com.lge.appbox.bridge', 'com.lge.appbox.remote', 'com.lge.defaultaccount', ...
    'com.lge.hiddenmenu', 'com.lge.hiddenmenuko', 'com.lge.homeselector', 'com.lge.ime', 'com.lge.ims', ...
    'com.lge.internal', 'com.lge.keepscreenon', 'com.lge.lgdrm.permission', 'com.lge.lgfota.permission', ...
    'com.lge.networkpostest', 'com.lge.permission', 'com.lge.settings.compatmode', 'com.lge.shutdownmonitor', ...
    'com.lge.sizechangable', 'com.lge.uplus.permission', 'com.lge.wallpaper', 'com.lge.wv.hidden', ...
    'com.qualcomm.timeservice', ...
    ...
    ...
    'com.lge.oneshotlogger', 'com.android.mms'};
passappword = {'cello', 'protector', 'clock', 'example', 'lock', ...
    'wallpaper', 'camera', 'install', 'store', 'rms'};
launchername = {'com.lge.launcher2', 'com.sec.android.app.launcher'};



nMF = length(Merged_Feature.Time);

newTime = zeros(nMF, 1);
newLocation = zeros(nMF, 2);
newLabel = zeros(nMF, 1);
newMoving = zeros(nMF, 1);
newRingerMode = zeros(nMF, 1);
newBTHeadsetOn = zeros(nMF, 1);
newHeadsetOn = zeros(nMF, 1);
newWIFI = zeros(nMF, 1);
newPlugOn = zeros(nMF, 1);
newBattery = zeros(nMF, 1);
newPhone = zeros(nMF, 1);
newIsWeekend = zeros(nMF, 1);
newNoti = cell(nMF,1);

newCount = 0;

AppNameCount = 0;
AppNameTable = {};

LauncherID = 0; % Let launcher label as '0'


prev_AppName = ''; % just initialize
for i = 1:nMF
    cur_AppName = strsplit(char(Merged_Feature.AppName(i)), '/');
    cur_AppName = cur_AppName(1); % Take First Part
    
    % Go to the next step when same or pass app detected
    if strcmp(cur_AppName, prev_AppName) || ispass(cur_AppName, passappname, passappword)
        continue;
    end
    prev_AppName = cur_AppName;
    
    % Check launcher or current app name
    if islauncher(cur_AppName, launchername)
        AppID = LauncherID;
    else
        % Search the current appname from AppNameTable
        result_cmp = strcmp(cur_AppName, AppNameTable);
        NameDetected = sum(result_cmp);
        
        if NameDetected == 0 % if there is no existing name, then add it.
            AppNameCount = AppNameCount + 1;
            AppNameTable(AppNameCount, 1) = cur_AppName;
            AppID = AppNameCount;
        else
            AppID = find(result_cmp == true); % if it exists, then get AppID.
        end
    end
    
    
    % Write a new feature list
    newCount = newCount + 1;
    newTime(newCount) = Merged_Feature.Time(i);
    newLocation(newCount, :) = getValidLocation( Merged_Feature.Time(i), Merged_Feature.Location ); %Merged_Feature.Location(i, :); 
    if (newLocation(newCount,1)) == -1 && (newCount > 1)
        newLocation(newCount, :) = newLocation(newCount-1, :);
    end
    newMoving(newCount) = getValidMoving( Merged_Feature.Time(i), Merged_Feature.Location );
    newRingerMode(newCount) = getLatestFeature( Merged_Feature.Time(i), Merged_Feature.RingerMode, Merged_Feature.Time);
    newBTHeadsetOn(newCount) = getLatestFeature( Merged_Feature.Time(i), Merged_Feature.BTHeadsetOn, Merged_Feature.Time);
    newHeadsetOn(newCount) = getLatestFeature( Merged_Feature.Time(i), Merged_Feature.HeadsetOn, Merged_Feature.Time);
    newWIFI(newCount) = getLatestFeature( Merged_Feature.Time(i), Merged_Feature.WIFI, Merged_Feature.Time);
    newPlugOn(newCount) = getLatestFeature( Merged_Feature.Time(i), Merged_Feature.PlugOn, Merged_Feature.Time);
    newBattery(newCount) = getLatestFeature( Merged_Feature.Time(i), Merged_Feature.Battery, Merged_Feature.Time);
    newPhone(newCount) = getLatestFeature( Merged_Feature.Time(i), Merged_Feature.Phone, Merged_Feature.Time);
    newIsWeekend(newCount) = getLatestFeature( Merged_Feature.Time(i), Merged_Feature.IsWeekend, Merged_Feature.Time);
    newNoti{newCount} = getLatestNoti( Merged_Feature.Time(i), Merged_Feature.Access, Merged_Feature.Time);
    newLabel(newCount) = AppID;
end


% Cut blank history
newTime(newCount+1:end) = [];
newLocation(newCount+1:end, :) = [];
newMoving(newCount+1:end) = [];
newRingerMode(newCount+1:end) = [];
newBTHeadsetOn(newCount+1:end) = [];
newHeadsetOn(newCount+1:end) = [];
newWIFI(newCount+1:end) = [];
newPlugOn(newCount+1:end) = [];
newBattery(newCount+1:end) = [];
newPhone(newCount+1:end) = [];
newIsWeekend(newCount+1:end) = [];
newLabel(newCount+1:end) = [];
newNoti(newCount+1:end) = [];



% Evaluate App Transition data
TrCount = 0;
Tr_Time = zeros(newCount, 1);
Tr_Label = zeros(newCount, 2);
for i = 1:newCount-1
    if newLabel(i) == LauncherID
        if i ~= 1
            TrCount = TrCount + 1;
            Tr_Time(TrCount) = newTime(i+1)-newTime(i);
            Tr_Label(TrCount, :) = [newLabel(i-1), newLabel(i+1)];
        end
    elseif newLabel(i+1) ~= LauncherID
        TrCount = TrCount + 1;
        Tr_Time(TrCount) = 0;
        Tr_Label(TrCount, :) = [newLabel(i), newLabel(i+1)];
    end
end


% Cut blank history about Transition data
Tr_Time(TrCount+1:end) = [];
Tr_Label(TrCount+1:end, :) = [];
Tr_N = AppNameCount;



% Cut Launcher data
LauncherIndex = find(newLabel == 0);
newTime(LauncherIndex) = [];
newLocation(LauncherIndex, :) = [];
newMoving(LauncherIndex) = [];
newRingerMode(LauncherIndex) = [];
newBTHeadsetOn(LauncherIndex) = [];
newHeadsetOn(LauncherIndex) = [];
newWIFI(LauncherIndex) = [];
newPlugOn(LauncherIndex) = [];
newBattery(LauncherIndex) = [];
newPhone(LauncherIndex) = [];
newIsWeekend(LauncherIndex) = [];
newLabel(LauncherIndex) = [];
newNoti(LauncherIndex) = [];



% Gather data to a struct
Cleaned_Feature.Time = newTime;
Cleaned_Feature.Location = newLocation;
Cleaned_Feature.IMEI = Merged_Feature.IMEI;
Cleaned_Feature.Moving = newMoving;
Cleaned_Feature.RingerMode = newRingerMode;
Cleaned_Feature.BTHeadsetOn = newBTHeadsetOn;
Cleaned_Feature.HeadsetOn = newHeadsetOn;
Cleaned_Feature.WIFI = newWIFI;
Cleaned_Feature.PlugOn = newPlugOn;
Cleaned_Feature.Battery = newBattery;
Cleaned_Feature.Phone = newPhone;
Cleaned_Feature.IsWeekend = newIsWeekend;
Cleaned_Feature.Label = newLabel;
Cleaned_Feature.Noti = newNoti;
Cleaned_Feature.AppNameTable = AppNameTable;

Cleaned_Feature.Implicit.Tr_Time = Tr_Time;
Cleaned_Feature.Implicit.Tr_Label = Tr_Label;
Cleaned_Feature.Implicit.Tr_N = Tr_N;

end



function [ TF_pass ] = ispass( cur_AppName, passappname, passappword )

if sum(strcmp(cur_AppName, passappname)) ~= 0
    TF_pass = true;
    return;
end

for i = 1:length(passappword)
    if ~isempty(strfind(char(cur_AppName), char(passappword(i))))
        TF_pass = true;
        return;
    end
end

TF_pass = false;
end


function [ TF_launcher ] = islauncher( cur_AppName, launchername )

if sum(strcmp(cur_AppName, launchername)) ~= 0
    TF_launcher = true;
else
    TF_launcher = false;
end

end

function [ Feature_value ] = getLatestFeature( AppTime, Feature, Time )
UNKNOWN_STATE = -1;
Feature_value = UNKNOWN_STATE;

tmpT = Time - AppTime;
if size(tmpT,1) == 0
    return;
end
[tmpV, tmpI] = min(abs(tmpT));
if (tmpT(tmpI) > 0) && (tmpI > 1)
    tmpI = tmpI - 1;
end

Feature_value = Feature.curState(tmpI);

end

function [ Feature_value ] = getValidMoving( AppTime, Feature )
UNKNOWN_STATE = -1;
Feature_value = UNKNOWN_STATE;

tmpT = Feature.Time - AppTime;
if size(tmpT,1) == 0
    return;
end
[tmpV, tmpI] = min(abs(tmpT));
if (tmpT(tmpI) > 0) && (tmpI > 1)
    tmpI = tmpI - 1;
end

if tmpV/1000/60 <= 5
    Feature_value = Feature.curState(tmpI);
end

end

function [ Location ] = getValidLocation( AppTime, Loc_Feature )
UNKNOWN_STATE = -1;
Location = [UNKNOWN_STATE, UNKNOWN_STATE];

tmpT = Loc_Feature.Time - AppTime;
if size(tmpT,1) == 0
    return;
end
[tmpV, tmpI] = min(abs(tmpT));
if (tmpT(tmpI) > 0) && (tmpI > 1)
    tmpI = tmpI - 1;
end

if tmpV/1000/60 <= 5
    Location = Loc_Feature.Double(tmpI,:);
end

end

function [ Feature_value ] = getLatestNoti( AppTime, Feature, Time )
UNKNOWN_STATE = '';
Feature_value = {UNKNOWN_STATE};

tmpT = Time - AppTime;
if size(tmpT,1) == 0
    return;
end
[tmpV, tmpI] = min(abs(tmpT));
if (tmpT(tmpI) > 0) && (tmpI > 1)
    tmpI = tmpI - 1;
end

Feature_value = Feature.curState{tmpI};

end