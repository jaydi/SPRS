clear;

% constants
Depth = 3; % how many step to take for 

% loading extracted features
if ispc
    load('..\Result2.mat', '-mat'); % '/'  for OSX, '\' for windows
else
    load('../Result2.mat', '-mat');
end

% obtaining # of samples (users)
size_Users = size(Extracted_Feature);
num_Users = size_Users(1,1);

% main loop
for c=1:num_Users
    
    if size(Extracted_Feature(c,1).Implicit.Tr_Label,1) == 0
        fprintf('%dth data has no app transition events! Skipping IF calculation.\n', c);
        Calculated_Feature(c,1) = Extracted_Feature(c,1);
        continue;
    end
    
    % STEP 1 : collecting App transition events
    
    %initializing variables%
    total_Transition = 0;
    
    i=0;
    j=0;
    num_Dimension = 1; % initial # of apps = 1
    
    % initializing event logger
    TmpTrSteps = zeros(1);
    TmpTrDelta = zeros(1);
    
    b = 1;
    
    while 1
        % collect data until no data is found
        try
            cur_AppID = Extracted_Feature(c,1).Implicit.Tr_Label(b,2);
        catch error
            break;
        end
        
        old_AppID = Extracted_Feature(c,1).Implicit.Tr_Label(b,1);

        % checking size of event logs
        size_Log = size(TmpTrSteps);
        num_Log = size_Log(1,2);
        
        if num_Log <= 0
            num_Log = 1;
        end
        
        %logging current transition%
        TmpTrSteps(1,num_Log) = old_AppID;
        TmpTrSteps(1,num_Log+1) = cur_AppID;
        
        %expand the transition kernel if new App detected%
        expand = max(cur_AppID,old_AppID);
        if (expand > num_Dimension)
           num_Dimension = expand; % expanding total # of Apps
        end

        %Adding total sum of transitions%
        total_Transition = total_Transition + 1;
        
        b = b + 1;

    end
    
    fprintf('Transition Log of %dth data has been Captured\n', c);

    % saving event logs
    Extracted_Feature(c,1).Implicit.AppTrLog = TmpTrSteps;

    % STEP 3 : calculating Implicit Feature for training (Algorithm #1 on paper) 

    % total # of transition events
    sizeTr = size(TmpTrSteps);
    numTr = sizeTr(1,2);    
    
    % initializing variables
    TmpImpFeature = zeros(numTr,num_Dimension);
    cur_Step = 0;
    
    % loop for total # of transition events
    for k=2:numTr
        TmpImpFeature(k,:) = TrainIF3(TmpTrSteps(1,1:k),num_Dimension,Depth);
    end
    
    % initialize 1st element of Implicit feature
    first_Step = TmpTrSteps(1,1);
    TmpIFM = zeros(1,num_Dimension);
    TmpIFMCount = 0;
    
    for k=2:numTr
       if TmpTrSteps(1,k) == first_Step
           TmpIFM = TmpIFM + TmpImpFeature(k,:);
           TmpIFMCount = TmpIFMCount + 1;
       end
    end
    
    if TmpIFMCount ~= 0
        TmpIFM = TmpIFM / TmpIFMCount;
    end
    
    TmpImpFeature(1,:) = TmpIFM;
    
    % saving whole implicit features
    Extracted_Feature(c,1).Implicit.Feature = TmpImpFeature;
    
    fprintf('Implicit feature of %dth data has been trained\n', c);
    
    % STEP 4 : calculating Implicit Feature for Test (Algorithm #2 on paper)
    
    % initializing variables
    TmpImpFeatureTest = zeros(numTr,num_Dimension);   
    TmpTheta = zeros(numTr,num_Dimension);
    
    % loop for total # of transition events
    [TmpImpFeatureTest(1,:),TmpTheta(1,:)] = TestIF2(TmpTrSteps(1,1),num_Dimension,Depth);
    for k=2:numTr
        [TmpImpFeatureTest(k,:),TmpTheta(k,:)] = TestIF2(TmpTrSteps(1,1:k),num_Dimension,Depth);
    end    
    
    % saving whole implicit features for testing
    Extracted_Feature(c,1).Implicit.FeatureT = TmpImpFeatureTest;
    Extracted_Feature(c,1).Implicit.Theta = TmpTheta;
    
    fprintf('Implicit feature for testing of %dth data has been obtained\n', c);
    
    Calculated_Feature(c,1) = Extracted_Feature(c,1);
    
end

% saving results
if ispc
    save('..\Result3.mat', 'Calculated_Feature');
else
    save('../Result3.mat', 'Calculated_Feature');
end
fprintf('All Done!!!\n');