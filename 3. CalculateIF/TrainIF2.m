function IFTrain = TrainIF2(AppTrLabel, Dim, DEPTH)

    % STEP 3 : calculating Implicit Feature (Algorithm #1 on paper) 

    % total # of transition events
    numTr = size(AppTrLabel,2);
        
    % initializing variables
    IFTrain = zeros(1,Dim);
    cur_Step = 0;
    total_transition = zeros(1,Dim);
    transition = zeros(Dim,Dim);
    
    if numTr < 2
        return;
    end
    
    % calculate IF for last App
    
    k = numTr;
    cur_Step_k = AppTrLabel(1,k); % Appt of algorithm 1
    
    w = k - DEPTH;
    if w <= 0
        w = 1;
    end
    
    for h=w:k
        if h == 1
            continue;
        end
        cur_Step = AppTrLabel(1,h); % current App
        old_Step = AppTrLabel(1,h-1); % old App
        
        total_transition(cur_Step) = total_transition(old_Step) + 1;
        transition(old_Step,cur_Step) = transition(old_Step,cur_Step) + 1;
    end
    
    % saving individual implicit feature
    IFTrain = transpose(transition(:,cur_Step_k)/total_transition(cur_Step_k));
   
    %fprintf('Implicit feature has been obtained\n');   
end