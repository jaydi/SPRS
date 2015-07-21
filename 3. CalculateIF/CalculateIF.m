clear;

% constants
INTERVALS = 5; % # of transition intervals (5 means 0~4 min)
BETA_BOUND = 4.0; % upper bound for searching Beta
BETA_STEP = 0.001; % increment step for searching Beta
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

    Alpha = zeros(1);
    Beta = zeros(1);
    
    i=0;
    j=0;
    num_Dimension = 1; % initial # of apps = 1
    
    % initializing transition event storage
    num_Transition = cell(1,INTERVALS);
    for i=1:INTERVALS
        num_Transition{1,i}=zeros(1);
    end
    
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
        
        Delta = Extracted_Feature(c,1).Implicit.Tr_Time(b,1);
        Delta = Delta/1000/60;

        % checking size of event logs
        size_Log = size(TmpTrSteps);
        num_Log = size_Log(1,2);
        
        if num_Log <= 0
            num_Log = 1;
        end
        
        %logging current transition%
        TmpTrSteps(1,num_Log) = old_AppID;
        TmpTrSteps(1,num_Log+1) = cur_AppID;
        TmpTrDelta(1,num_Log) = Delta;
        
        % current app id : cur_AppID, previous app id : old_AppID
        % delay : Delta, total # of App : AppN
        % round Delta to negative infinity e.g) 3.2 -> 3
        rounded_Delta = int8(floor(Delta));
        
        %expand the transition kernel if new App detected%
        expand = max(cur_AppID,old_AppID);
        if (expand > num_Dimension)
            for j=1:INTERVALS % expanding transition event storage
                num_Transition{1,j}(expand,expand) = 0;
            end
            Alpha(expand,expand) = 0;
            Beta(expand,expand) = 0;
            num_Dimension = length(num_Transition{1,1}); % expanding total # of Apps
        end
        
        % shaping delta (transition interval) to 0 <= delta <= (INTERVALS - 1) min
        % discard the event that has delta greater than (INTERVALS - 1) for obtaining
        % Alpha and Beta
        if rounded_Delta > (INTERVALS - 1)
            b = b + 1;
            continue;
        elseif rounded_Delta < 0
            rounded_Delta = 0;
        end

        %add 1 to # of transition that happened%
        num_Transition{1,rounded_Delta+1}(old_AppID,cur_AppID) = num_Transition{1,rounded_Delta+1}(old_AppID,cur_AppID) + 1;

        %Adding total sum of transitions%
        total_Transition = total_Transition + 1;
        
        b = b + 1;

    end
    
    fprintf('Transition Log of %dth data has been Captured\n', c);

    % saving event logs
    Extracted_Feature(c,1).Implicit.AppTrLog = TmpTrSteps;
    Extracted_Feature(c,1).Implicit.DeltaLog = TmpTrDelta;

    % STEP 2 : obtaining transition kernel by finding alpha and beta of
    % exponential distribution
    % p^(x) = Alpha * exp (-1 * Beta * x)
    
    %calculating Alpha of input transition%
    for k=1:num_Dimension
        for l=1:num_Dimension
            Alpha(k,l) = num_Transition{1,1}(k,l) / total_Transition; % only consider delta=0 event
        end
    end
    %calculating Beta of input transition%
    for k=1:num_Dimension
        for l=1:num_Dimension
            Alpha1 = Alpha(k,l);   
            % if there are no delta=0 event on that transition, alpha is
            % assumed as 0.4
            if Alpha1 == 0
                Alpha1 = 0.4;
            end
            %initializing error variables
            PError = 0.0;
            BetaB = 0.0;
            %minimizing error of transition kernel by Beta
            BetaT = 0.001;
            while BetaT <= BETA_BOUND
                Prob = 0.0;
                Prob2 = 0.0;
                IProb = 0.0;    
                IProb2 = 0.0;
                % summing up and compare error, finding mininum Beta for
                % minimized error
                for m=2:INTERVALS
                    if num_Transition{1,m}(k,l) == 0
                        continue;
                    else
                        %actual transition probability
                        Prob = num_Transition{1,m}(k,l) / total_Transition;
                        Prob2 = Prob2 + Prob;

                        %assumed transition kernel
                        IProb = Alpha1*exp(-1*BetaT*m);
                        IProb2 = IProb2 + IProb;
                    end
                end
                PErrorC = abs(IProb2 - Prob2);
                if ((PErrorC ~= 0) && (PError == 0)) || (PErrorC < PError)
                    PError = PErrorC;
                    BetaB = BetaT;
                end
                if (BetaT < 1.0)
                    BetaT = BetaT + BETA_STEP;
                else
                    BetaT = BetaT * (1+BETA_STEP);
                end
            end        
            Beta(k,l) = BetaB;
            %initial value for the exepction situations
            if (Alpha(k,l) == 0) && (Beta(k,l) ~= 0)
                Alpha(k,l) = Prob2;
            elseif (Alpha(k,l) ~= 0) && (Beta(k,l) == 0)
                Beta(k,l) = 1.0;
            end        
        end
    end
    
    fprintf('Transition kernel of %dth data has been Calculated\n', c);
    
    % saving Alpha and Beta %
    Extracted_Feature(c,1).Implicit.Alpha = Alpha;
    Extracted_Feature(c,1).Implicit.Beta = Beta;
   
    % STEP 3 : calculating Implicit Feature for training (Algorithm #1 on paper) 

    % total # of transition events
    sizeTr = size(TmpTrSteps);
    numTr = sizeTr(1,2);    
    
    % initializing variables
    TmpImpFeature = zeros(numTr,num_Dimension);
    cur_Step = 0;
    
    % loop for total # of transition events
    for k=2:numTr
        TmpImpFeature(k,:) = TrainIF(TmpTrSteps(1,1:k),TmpTrDelta(1,1:k-1),Alpha,Beta,Depth);
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
    [TmpImpFeatureTest(1,:),TmpTheta(1,:)] = TestIF(TmpTrSteps(1,1),0,Alpha,Beta,Depth);
    for k=2:numTr
        [TmpImpFeatureTest(k,:),TmpTheta(k,:)] = TestIF(TmpTrSteps(1,1:k),TmpTrDelta(1,1:k-1),Alpha,Beta,Depth);
    end    

    % initialize 1st element of Implicit feature and Theta
    TmpIFM_T = zeros(1,num_Dimension);
    TmpIFMCount_T = 0;
    
%     for k=2:numTr
%        if TmpTrSteps(1,k) == first_Step
%            TmpIFM_T = TmpIFM_T + TmpImpFeatureTest(k,:);
%            TmpIFMCount_T = TmpIFMCount_T + 1;
%        end
%     end
%     
%     if TmpIFMCount_T ~= 0
%         TmpIFM_T = TmpIFM_T / TmpIFMCount_T;
%     end
%     
%     TmpImpFeatureTest(1,:) = TmpIFM;
%     TmpTheta(1,:) = ones(1,num_Dimension) / num_Dimension;
    
    % saving whole implicit features for testing
    Extracted_Feature(c,1).Implicit.FeatureT = TmpImpFeatureTest;
    Extracted_Feature(c,1).Implicit.Theta = TmpTheta;
    
    fprintf('Implicit feature for testing of %dth data has been obtained\n', c);
    
    Calculated_Feature(c,1) = Extracted_Feature(c,1);
    
    % clearing variables
    clear num_Transition;
    clear Alpha;
    clear Beta; 
    clear TmpTrSteps;
    clear TmpTrDelta;
    clear TmpImpFeature;
end

% saving results
if ispc
    save('..\Result3.mat', 'Calculated_Feature');
else
    save('../Result3.mat', 'Calculated_Feature');
end
fprintf('All Done!!!\n');