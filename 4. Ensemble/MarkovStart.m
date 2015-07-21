clear;
if ispc
    load('..\Result2.mat', '-mat');
else
    load('../Result2.mat', '-mat');
end

count_err = 0;
bbb = length(Extracted_Feature);
for i = 1:length(Extracted_Feature)
    fprintf('Start Recommending for user %s\n', Extracted_Feature(i).IMEI);
    
    try
        Result(i, 1) = MarkovCalculate(Extracted_Feature(i));
    catch
        count_err = count_err + 1;
        saved_err_i(count_err) = i;
        continue;
    end
    
    
    
    
    if ispc
        save('..\ResultMarkov.mat', 'Result');
    else
        save('../ResultMarkov.mat', 'Result');
    end
end