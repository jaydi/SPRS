clear; clc;
if ispc
    load('..\Result3.mat', '-mat');
else
    load('../Result3.mat', '-mat');
end

OptionList = struct;
% OptionList(1).FileName = 'Ex1.mat';
% OptionList(1).LMNN.Flag = 0;
% OptionList(2).LMNN.quiet = 0;

nExperiment = length(OptionList);

parfor i = 1:nExperiment
    cur_Options = OptionList(i);
    
    fprintf('\n\n\n\n**************************\n');
    fprintf('Start Experiment %d\n', i);
    fprintf('**************************\n');
    
    Result(i, 1) = Ensemble(Calculated_Feature, cur_Options);
end

if ispc
    save('..\Result4.mat', 'Result');
else
    save('../Result4.mat', 'Result');
end