clear; clc;
if ispc
    load('..\..\Result3.mat', '-mat');
else
    load('/Result3.mat', '-mat');
end

OptionList = struct;

FNs = {'Time', 'Location', 'Moving', 'RingerMode', 'BTHeadsetOn', ...
    'HeadsetOn', 'WIFI', 'PlugOn', 'Battery', 'IsWeekend', 'Implicit'};

% TEST
OptionList(1).saveRecords = 1;
OptionList(1).DTree.Method = 'AdaBoostM2';
OptionList(1).DTree.NLearn = 150;
OptionList(1).DTree.ensembleFlag = 1;
OptionList(1).DTree.Learners = 'Tree';
OptionList(1).DTree.fitensembleOptions.LearnRate = 1;
  


% for i = 1:5     
%  
%     OptionList(i).DTree.fitctreeOptions.Minparent = i;
%     OptionList(i).saveRecords = 1;
%     OptionList(i).DTree.Method = 'AdaBoostM2';
%     OptionList(i).DTree.NLearn = 100*i;
%     OptionList(i).DTree.ensembleFlag = 1;
%     OptionList(i).DTree.Learners = 'Tree';
% end
% 
% for i = 11:20
%     OptionList(i).DTree.fitctreeOptions.Minparent = i;
%     OptionList(i).saveRecords = 1;
%     OptionList(i).DTree.Method = 'LPBoost';
%     OptionList(1).DTree.NLearn = 100*(i-10);
% end
% for i = 21:30
%     OptionList(i).DTree.fitctreeOptions.Minparent = i;
%     OptionList(i).saveRecords = 1;
%     OptionList(i).DTree.Method = 'LPBoost';
%     OptionList(1).DTree.NLearn = 100*(i-20);
% end
% for i = 31:40
%     OptionList(i).DTree.fitctreeOptions.Minparent = i;
%     OptionList(i).saveRecords = 1;
%     OptionList(i).DTree.Method = 'LPBoost';
%     OptionList(1).DTree.NLearn = 100*(i-10);
% end
% for i = 41:50
%     OptionList(i).DTree.fitctreeOptions.Minparent = i;
%     OptionList(i).saveRecords = 1;
%     OptionList(i).DTree.Method = 'LPBoost';
%     OptionList(1).DTree.NLearn = 100*(i-10);
% end
% for i = 51:60
%     OptionList(i).DTree.fitctreeOptions.Minparent = i;
%     OptionList(i).saveRecords = 1;
%     OptionList(i).DTree.Method = 'LPBoost';
%     OptionList(1).DTree.NLearn = 100*(i-10);
% end
% 
% for i = 1:60
%     OptionList(i).DTree.ensembleFlag = 1;
%     OptionList(i).DTree.Learners = 'Tree';
% end
% OptionList(1).FileName = 'Ex1.mat';
% OptionList(1).Used_FieldName = FNs;
% OptionList(1).DTree.fitctreeOptions.MinParent = 10;
% OptionList(1).DTree.fitctreeOptions.Prune = 'off';
% OptionList(1).saveRecords = 1;


% OptionList(2).DTree.Method = 'LPBoost';
% OptionList(1).DTree.Method = 'TotalBoost';
% OptionList(2).DTree.Method = 'RUSBoost';
% OptionList(3).DTree.Method = 'Subspace';

% OptionList(1).DTree.NLearn = 100;

% OptionList(2).DTree.NLearn = 200;
% OptionList(3).DTree.NLearn = 300;
% OptionList(4).DTree.NLearn = 400;
% OptionList(5).DTree.NLearn = 500;

% OptionList(1).DTree.fitctreeOptions.Prune = 'off';
% OptionList(1).DTree.fitctreeOptions.MinParent = 3;
% OptionList(1).DTree.fitensembleOptions.CrossVal = 'On';
% OptionList(1).PCA.Flag = 1;
% OptionList(1).PCA.IFFlag = 0;
% OptionList(1).PCA.UseCUT = 1;
% OptionList(1).test.israndom = 1;


% OptionList(1).saveRecords = 1;
% OptionList(1).DTree.ensembleFlag = 1;
% OptionList(1).DTree.fitctreeOptions.Prune = 'off';
% OptionList(2).DTree.fitctreeOptions.MinParent = 40;

% OptionList(2).DTree.fitctreeOptions.MinParent = 5;
% OptionList(3).DTree.fitctreeOptions.MinParent = 7;
% OptionList(4).DTree.fitctreeOptions.MinParent = 20;
% OptionList(1).Used_FieldName = FNs([2, 5, 6]);
% OptionList(2).Used_FieldName = FNs([1, 3, 4]);
% OptionList(2).Used_FieldName = FNs([2, 5, 6]);
% OptionList(2).DTree.ensembleFlag = 1;
% OptionList(2).DTree.Method = 'AdaBoostM2';
% OptionList(2).DTree.NLearn = 100;
% OptionList(2).DTree.Learners = 'Tree';
% OptionList(2).DTree.fitensembleOptions.CrossVal = 'On'

nExperiment = length(OptionList);

for i = 1:nExperiment
    cur_Options = OptionList(i);
    
    fprintf('\n\n\n\n**************************\n');
    fprintf('Start Experiment %d\n', i);
    fprintf('**************************\n');
    
    Result(i, 1) = DTree(Calculated_Feature, cur_Options);
end

if ispc
    save('Result_Tree.mat', 'Result');
else
    save('Result_Tree.mat', 'Result');
end