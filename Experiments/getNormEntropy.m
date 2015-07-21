function [ Score, nBin ] = getNormEntropy( feature, Label, nBin, isState )

% need to fix for exceptions, when feature length is short %
% need to fix for exceptions, when feature length is short %
% need to fix for exceptions, when feature length is short %

% nData = size(feature, 1);
% nDim = size(feature, 2);
if ~isState
    [minValue, minind] = min(feature);
    maxValue = max(feature);
    
    feature = ceil((feature - minValue) / (maxValue - minValue) * nBin);
    feature(minind) = 1;
end


[uValues, ~, iV] = unique(feature);

if length(uValues) < nBin % if feature has state values
    nBin = length(uValues);
end

% Real Case
Bins_ind = cell(1, nBin); % This indicates indices of feature values
for i = 1:nBin
    Bins_ind{i} = find(iV == i);
end


% Make Bad Case
BadBins_ind = cell(1, nBin);
[uLabel, ~, iL] = unique(Label);
bnum = 1;
for i = 1:length(uLabel)
    cur_label_ind = find(iL == i);
    for j = 1:length(cur_label_ind)
        BadBins_ind{bnum} = [BadBins_ind{bnum}; cur_label_ind(j)];

        bnum = bnum + 1;
        if bnum > nBin
            bnum = 1;
        end
    end
end


% Make Good Case (Greedy)
GoodBins_ind = cell(1, nBin);
len_gb = zeros(1, nBin);
for i = 1:length(uLabel)
    cur_label_ind = find(iL == i);
    [~, bnum] = min(len_gb);

    GoodBins_ind{bnum} = [GoodBins_ind{bnum}; cur_label_ind];
    len_gb(bnum) = len_gb(bnum) + length(cur_label_ind);
end

H_Real = getBinsEntropy(Bins_ind, Label);
H_Bad = getBinsEntropy(BadBins_ind, Label);
H_Good = getBinsEntropy(GoodBins_ind, Label);




if H_Bad < H_Good
    fprintf('Bad:%f, Good:%f /// ', H_Bad, H_Good);
end
if H_Bad < H_Real
    fprintf('Bad:%f, Real:%f /// ', H_Bad, H_Real);
end

if H_Bad == H_Good
    Score = -1;
else
    Score = (H_Bad - H_Real) / (H_Bad - H_Good);
end


end


function [ H_Bins ] = getBinsEntropy( Bins, Label )

nBin = length(Bins);
nData = length(Label);

H_Bins = 0;
for i = 1:nBin
    [ucurBinind, ~, iL] = unique(Label(Bins{i}));
    
    H_curBin = 0;
    for j = 1:length(ucurBinind)
        prob_curLabel = length(find(iL == j)) / length(iL);
        H_curBin = H_curBin + (- prob_curLabel * log2(prob_curLabel));
    end
    
    H_Bins = H_Bins + (length(iL) / nData) * H_curBin;
end

end