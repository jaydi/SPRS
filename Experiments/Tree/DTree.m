% Created by Donghyeon Yi, 2014/01/06

function [ Result ] = DTree( Calculated_Feature, Options )
% Ensemble Algorithm Start
% Only LMNN used up to date

% Fill default options
Options = FillDefaultOptions(Options);
fitctree_OptionList = Parse_funcOption(Options.DTree.fitctreeOptions);
fitensemble_OptionList = Parse_funcOption(Options.DTree.fitensembleOptions);

%Allocation some memory before recommending
nUser = length(Calculated_Feature);

Indices = cell(nUser, 1);
IMEIs = cell(nUser, 1);

Acc.nTest = zeros(nUser, 1);
Acc.istested = zeros(nUser, 1);

Acc.accs_b = zeros(nUser, 1);
Acc.accs_t = zeros(nUser, 1);

if Options.saveRecords
    Acc.rec_b = cell(nUser, 1);
    Acc.rec_t = cell(nUser, 1);
end

PCA = Options.PCA;
if Options.PCA.Flag
    PCA.outDim = zeros(nUser, 1);
end
if Options.PCA.IFFlag
    PCA.IFoutDim = zeros(nUser, 1);
end

treeClassifier = cell(nUser, 1);


% Start Recommendation for all users in 'Result3.mat'
for i = 1:nUser
    % Get current user data
    FeatureSets = Calculated_Feature(i);
    
    
    % Step 0 : Check feasibility of data and normalize it.
    % Parameter auto update
    nData = length(FeatureSets.Time);
    fprintf('User %-3d: nData=%-4d ', i, nData);
    if nData == 0
        fprintf('Skip!\n');
        continue;
    end
    nTrain = floor(nData * Options.test.train_percentage);
    nTest = nData - nTrain;
    
    
    % Normalize feature data
    FeatureSets = normalize_FeatureSets(FeatureSets);
    
    
    % Step 1 : Arrange data before applying Ensemble Algorithm
    % Determine test indices
    if Options.test.UseIndices
        test_ind = Options.test.Indices{i};
    else
        if Options.test.israndom
            test_ind = sort(randperm(nData, nTest));
        else
            test_ind = nTrain+1:nData;
        end
    end
    
    % Arrange data to n-dimensional space
    [D, Label, nDim, IFoutDim] = arrange_Data(FeatureSets, Options, test_ind);
    if Options.PCA.IFFlag
        PCA.IFoutDim(i) = IFoutDim;
    end
    test_D = D(test_ind, :);
    test_Label = Label(test_ind, :);
    train_D = D;
    train_Label = Label;
    train_D(test_ind, :) = [];
    train_Label(test_ind) = [];
    
    
    
    % Step 2 : Reduce training set
    [train_D, train_Label] = reduce_set(train_D, train_Label, 4);
    % If there's no data, the skip.
    if isempty(train_D)
        fprintf('Skip!\n');
        continue;
    end
    
    % Step 2.5 PCA
    if Options.PCA.Flag
        [pca_coeff, ~, pca_latent] = pca(train_D);
        
        if Options.PCA.UseCUT
            vsum = 0;
            for j = 1:length(pca_latent)
                vsum = vsum + pca_latent(j);
                if sqrt(vsum/sum(pca_latent)) >= Options.PCA.CUTVal
                    PCA.outDim(i) = j;
                    break;
                end
            end
        end
        
        train_D = train_D * pca_coeff(:, 1:PCA.outDim(i));
        test_D = test_D * pca_coeff(:, 1:PCA.outDim(i));
    end
    
    % Step 3 : Train data
    if Options.DTree.ensembleFlag
        try
            treeClassifier{i} = fitensemble(train_D, train_Label, ...
                Options.DTree.Method, Options.DTree.NLearn, Options.DTree.Learners, fitensemble_OptionList{:});
        catch
            fprintf('Skip!\n');
            continue;   
        end
        

    elseif Options.DTree.ctreeFlag
        treeClassifier{i} = fitctree(train_D, train_Label, fitctree_OptionList{:});
    else
        error('No classifier selected!');
    end
    
    
    % Step 4 : Ensemble Recommendation
    % Baseline
    % Calculate baseline
    pred = mode(train_Label);
    Acc.accs_b(i) = sum(test_Label == pred) / nTest;
    if Options.saveRecords
        Acc.rec_b{i} = pred;
    end
    
    % Decision Tree
    testResult = predict(treeClassifier{i}, test_D);
    Acc.accs_t(i) = mean(test_Label == testResult);
    if Options.saveRecords
        Acc.rec_t{i} = testResult;
    end
    
    % Save some parameters
    Acc.nTest(i) = nTest;
    Acc.istested(i) = true;
    Indices{i} = test_ind;
    IMEIs{i} = FeatureSets.IMEI;
    
    
    % Calculate accuracy
    Acc.acc = sum(Acc.accs_t) / sum(Acc.istested);
    Acc.wacc = (Acc.nTest' * Acc.accs_t) / sum(Acc.nTest);
    Acc.base_acc = sum(Acc.accs_b) / sum(Acc.istested);
    Acc.base_wacc = Acc.nTest' * Acc.accs_b / sum(Acc.nTest);
    
    
    
    
    % Print accuracy
    fprintf('Acc : ');
    fprintf('%6.2f\n', floor(Acc.accs_t(i) * 100));
    
    
    
    % Save process
    Result.Acc = Acc;
    Result.Trees = treeClassifier;
    Result.Options = Options;
    Result.Indices = Indices;
    Result.PCA = PCA;
    Result.IMEIs = IMEIs;
    
    save(Options.FileName, 'Result');
end




% Print total accuracy
fprintf('**************************\n');
fprintf('Experiment result : \n');
fprintf('%6.2f\n', Acc.wacc * 100);
fprintf('**************************\n');





end







% utility functions

function [ Options ] = FillDefaultOptions( Options )

% Define Default option struct
Default.test.UseIndices = false;

Default.test.israndom = false;
Default.test.train_percentage = 0.9;

Default.Used_FieldName = {'Implicit'};

Default.PCA.Flag = false;
Default.PCA.IFFlag = true;
Default.PCA.UseCUT = true;
Default.PCA.CUTVal = 0.9;

Default.DTree.ctreeFlag = true;
Default.DTree.ensembleFlag = false;

Default.DTree.fitctreeOptions = struct;
Default.DTree.fitensembleOptions = struct;

Default.saveRecords = false;

Default.FileName = 'Result4.mat';

Options = FillFields(Options, Default);

end

function [ subOption ] = FillFields(subOption, subDefault)

def_names = fieldnames(subDefault);

for i = 1:length(def_names)
    cur_name = def_names{i};
    if isfield(subOption, cur_name)
        if isstruct(subOption.(cur_name))
            subOption.(cur_name) = FillFields(subOption.(cur_name), subDefault.(cur_name));
        elseif isempty(subOption.(cur_name))
            subOption.(cur_name) = subDefault.(cur_name);
        end
    else
        subOption.(cur_name) = subDefault.(cur_name);
    end
end

end


function [ funcOptionList ] = Parse_funcOption( funcOption )

fo_names = fieldnames(funcOption);
funcOptionList = cell(length(fo_names), 2); % Make Name, Value pair cell matrix

for i = 1:length(fo_names)
    cur_name = fo_names{i};
    funcOptionList{i, 1} = cur_name;
    funcOptionList{i, 2} = funcOption.(cur_name);
end


end


function [ newD, newLabel ] = reduce_set( D, Label, thresh )

class = unique(Label);
counts = zeros(size(class));

% find meaningless classs
for i = 1:size(D, 1)
    c = Label(i);
    cind = find(class == c);
    counts(cind) = counts(cind) + 1;
end
del = find(counts < thresh); % classes that have fewere than 'thresh' counts
% Exclude classes used fewer than 'thresh' counts

newlen = size(D, 1) - sum(counts(del));
newD = zeros(newlen, size(D, 2));
newLabel = zeros(newlen, 1);

% reducing training set
j = 1;
for i = 1:size(D, 1)
    c = Label(i);
    if isempty(find(class(del) == c))
        newD(j, :) = D(i, :);
        newLabel(j) = Label(i);
        j = j + 1;
    end
end

% fprintf('Training set is reduced to %d\n', size(newD, 1));

end



function [ FeatureSets ] = normalize_FeatureSets( FeatureSets )

nData = length(FeatureSets.Time);

% Time
% Modify time to 24-hour form (2 dimensions)
hour_form = rem(FeatureSets.Time, 24*60*60*1000) / (60*60*1000);
unitcircle_form = 0.5 * [sin(2*pi*(hour_form/24)), cos(2*pi*(hour_form/24))];
FeatureSets.Time = unitcircle_form;



% Location
% Filtering out unknown location value (-1) with average value
L = FeatureSets.Location;
unknown_ind = find(L(:, 1) == -1);
known_L = L;
known_L(unknown_ind, :) = [];
meanL = mean(known_L);
minL = min(known_L);
maxL = max(known_L);
L(unknown_ind, :) = repmat(meanL, [length(unknown_ind), 1]);
if isempty(known_L)
    L = zeros(nData, 2);
else
    for i = 1:2
        if maxL(i) == minL(i)
            L(:, i) = 0;
        else
            L(:, i) = (L(:, i) - minL(i)) / (maxL(i) - minL(i));
        end
    end
end
FeatureSets.Location = L;


% States
STATE_FIELDNAMES = {'Moving', 'RingerMode', 'BTHeadsetOn', 'HeadsetOn', 'WIFI', 'PlugOn', 'Phone'};
for i = 1:size(STATE_FIELDNAMES, 2)
    cur_field = STATE_FIELDNAMES{i};
    
    uState = unique(FeatureSets.(cur_field));
    nState = length(uState);
    % If feature has unknown Field
    uind = find(uState == -1);
    if ~isempty(uind)
        uState(uind) = [];
        nState = nState - 1;
    end
    
    FieldValue = zeros(nData, nState);
    
    for j = 1:nData
        uind = uState == FeatureSets.(cur_field)(j);
        FieldValue(j, uind) = 1;
    end
    
    FeatureSets.(cur_field) = FieldValue;
end

FeatureSets.Battery = FeatureSets.Battery/100;
end