clear;

if ispc
    load('..\Result1.mat', '-mat');
else
    load('../Result1.mat', '-mat');
end

fprintf('Cleaning data');
for i = 1:length(Merged_Feature)
    % Data Clean & Evaluate Transition Data
    [Extracted_Feature(i, 1), AppNameTable] = clean_data(Merged_Feature(i));
    if rem(i,3) == 0
        fprintf('.');
    end
end
fprintf('complete!\n');

fprintf('Saving data.................');
if ispc
    save('..\Result2.mat', 'Extracted_Feature');
else
    save('../Result2.mat', 'Extracted_Feature');
end
fprintf('complete!\n');