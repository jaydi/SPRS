% This function returns gain(D,A) (Gain)
% D : labels, A : states
% states : Nx1, labels : Nx1
function [ gain ] = get_gain(states, labels)
gain = getEntropy(labels) - getSelectedEntropy(states, labels);
end


% This function returns H[D] (Entropy)
% D : labels
% labels : Nx1, double, 
function [ h ] = getEntropy( labels )

% Make label begins 1
if(min(labels) ~= 1)
    labels = labels - min(labels) + 1;
end
% Counting..
count = zeros(max(labels)-min(labels)+1, 1);
for i = 1 : length(labels)
    count(labels(i)) = count(labels(i)) + 1;
end

% Sum..
h = 0;
if(sum(count) > 0)
    for i = 1 : length(count)
        if(count(i) > 0)
            h = h + ((count(i) / sum(count)) * log2((count(i) / sum(count))));
        end
    end
end

h = -h;

end

% This function returns H_A[D] (Entropy of selected branch)
% D : labels, A(selected branch) : states
% states : Nx1, labels : Nx1
function [ h_s ] = getSelectedEntropy( states, labels )

% Make label begins 1
if(min(labels) ~= 1)
    labels = labels - min(labels) + 1;
end

% Make label begins 1
if(min(states) ~= 1)
    states = states - min(states) + 1;
end

% Counting..
count = zeros(max(states)-min(states)+1, max(labels)-min(labels)+1);
for i = 1 : length(states)
    if(i > length(labels))
        continue;
    end
    
    count(states(i), labels(i)) = count(states(i), labels(i)) + 1;
end

% Sum..
h_s = 0;
if(sum(count(:)) > 0)
    [count_row, count_col] = size(count);
    for i = 1 : count_row
        % Do Not Use function getEntropy..
        % h_s = h_s + ((sum(count(i,:)) / sum(count)) * getEntropy(  );

        h_tmp = 0;
        if(sum(count(i,:)) > 0)
            for j = 1 : count_col
                if(count(i,j) > 0)
                    h_tmp = h_tmp + ((count(i,j) / sum(count(i,:))) * log2((count(i,j) / sum(count(i,:)))));
                end
            end
        end
        h_s = h_s + ((sum(count(i,:)) / sum(count(:))) * (-h_tmp));
    end

    h_s = -h_s;
end

end


