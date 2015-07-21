function IFTrain = TrainIF(AppTrLabel, AppTrDelta, Alpha, Beta, DEPTH)

    % STEP 3 : calculating Implicit Feature (Algorithm #1 on paper) 

    % total # of transition events
    sizeTr = size(AppTrLabel);
    numTr = sizeTr(1,2);    
    
    % total # of Apps
    AppSize = size(Alpha);
    AppNum = AppSize(1,1);
    
    % initializing variables
    
    IFTrain = zeros(1,AppNum);
    cur_Step = 0;
    
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
    
    for h=k-1:-1:w
        cur_Step = AppTrLabel(1,h); % Appi of algorithm 1
        cur_Step2 = 0;
        TmpIFV = 0;
        %IF_t[i] += sum(p_it^(Delta_it)
        TmpIFV = TmpIFV + Alpha(cur_Step,cur_Step_k)*exp(-1*Beta(cur_Step,cur_Step_k)*AppTrDelta(1,h));
        if (k - h > 1)
            for g=k-1:-1:h
                cur_Step2 = AppTrLabel(1,g); % Appm of algorithm 1
                %IF_t[i] += sum(p_im^(Delta_im)*IF_t[m]
                TmpIFV = TmpIFV + Alpha(cur_Step,cur_Step2)*exp(-1*Beta(cur_Step,cur_Step2)*AppTrDelta(1,g))*IFTrain(1,cur_Step2);

            end                

        end
        % saving individual implicit feature
        IFTrain(1,cur_Step) = TmpIFV;
    end
    
    %fprintf('Implicit feature has been obtained\n');   
end