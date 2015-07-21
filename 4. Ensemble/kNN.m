function [ Accs, rec ] = kNN( train_D, train_Label, test_D, test_Label, kValues, L )
% kNN algorithm based recommendation


% Get test data
nTest = length(test_Label);

Accs = zeros(1, length(kValues));
rec = zeros(nTest, length(kValues));
for i = 1:nTest
    x = test_D(i, :);
    pred = query_LMNN(x, train_D, train_Label, kValues, L);
    
    Accs = Accs + (pred == test_Label(i));
    rec(i, :) = pred;
end
Accs = Accs / nTest;

end

function [ pred ] = query_LMNN( x, train_D, train_Label, kValues, L )

% When no linear transformation(same as k-NN)
if isempty(L)
    L = eye(length(x));
end

% Calculate new distance using L
newdistance = zeros(size(train_D,1), 1);
for i = 1:size(train_D,1)
    newdistance(i) = norm(L*(x - train_D(i, :))');
end

% Find the k nearest neighbors
[~, ind] = sort(newdistance);

pred = zeros(1, length(kValues));
for i = 1:length(kValues)
    k = kValues(i);
    if k > size(train_Label, 1)
        k = size(train_Label, 1);
    end

    pred(i) = majorvote_NN(newdistance(ind(1:k)), train_Label(ind(1:k)));
    % Choose the best prediction by majority votes (need to be updated!)
    % pred = mode(train_Label(ind(1:k)));
end


end


function [ major ] = majorvote_NN( neighbor_dist, neighbor_label )

candidate = unique(neighbor_label);
cand_count = zeros(size(candidate));
for i = 1:length(neighbor_label)
    c = neighbor_label(i);
    cind = find(candidate == c);
    cand_count(cind) = cand_count(cind) + 1;
end

maxcount = max(cand_count);
maxlabel = candidate(cand_count == maxcount);

maxlen = length(maxlabel);

if maxlen == 1
    major = maxlabel;
else
    maxlabel_dist = zeros(maxlen, 1);
    for i = 1:maxlen
        curlabel = maxlabel(i);
        dist_ind = (neighbor_label == curlabel);
        maxlabel_dist(i) = sum(neighbor_dist(dist_ind));
    end
    
    [~, mindist_ind] = min(maxlabel_dist);
    major = maxlabel(mindist_ind);
end

end