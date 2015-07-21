
function rec_result = MarkovCalculate( Feature )

transitionCounter = length(Feature.Label);
appNumberCounter = length(Feature.AppNameTable);
markovMatrix = zeros(appNumberCounter, appNumberCounter);

currApp=0;
nextApp=0;

if(transitionCounter > 0){
    for i=1:transitionCounter-1

        currApp = Feature.Label(i);
        nextApp = Feature.Label(i+1);
        markovMatrix(currApp, nextApp) = markovMatrix(currApp, nextApp) + 1;
        i = i+1;
    end
    
}

rec_result.markovMatrix = markovMatrix / transitionCounter;
end



