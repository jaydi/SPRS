function [IFTest,Theta] = TestIF2(AppTrLabel, Dim, DEPTH)
    THRESHOLD = DEPTH;
    
    % total # of Apps
    AppNum = Dim;
    
    % initialize
    IFTest = zeros(1,AppNum);   
    Mt = zeros(AppNum,AppNum);
    Theta = ones(1,AppNum)/AppNum;
    
    % total # of transition events
    sizeTr = size(AppTrLabel);
    numTr = sizeTr(1,2);     
    
    % Implicit Feature (training) calculating phase
    if numTr < 2
        AppTrDelta(1,1) = 0;
    else
        AppTrDelta(1,numTr) = 0;
    end
    
    for i=1:AppNum
        AppTrLabel(1,numTr+1) = i;
        TmpIF = TrainIF2(AppTrLabel,AppNum,THRESHOLD);
        Mt(:,i) = TmpIF';
    end
    
    for i=1:THRESHOLD
        % Implicit Feature (testing) update phase
        for j=1:AppNum
            IFTest = IFTest + Mt(:,j)'*Theta(1,j);
        end
        % Theta update phase
        for l=numTr:-1:1
            AppOfL = AppTrLabel(1,l);
            for j=1:AppNum
                Theta(1,AppOfL) = Theta(1,AppOfL) + IFTest(1,j)*Mt(j,AppOfL);
            end
        end
        % Normalize Theta
        NFTheta = sum(Theta);
        Theta = Theta / NFTheta;
    end
end