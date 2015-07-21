if ispc
    fprintf('Start 1. pickout\nNow processing..\n\n');
    run('.\1. pickout\start_pickout.m');

    fprintf('Start 2. CleanData\nNow processing...\n\n');
    run('.\2. CleanData\start_clean.m');

    fprintf('Start 3. CalculateIF\nNow processing....\n\n');
    run('.\3. CalculateIF\CalculateIF2.m');

    fprintf('Start 4. Ensemble\nNow processing.....\n\n');
    run('.\4. Ensemble\start_ensemble.m');
else
    fprintf('Start 1. pickout\nNow processing..\n\n');
    run('./1. pickout/start_pickout.m');

    fprintf('Start 2. CleanData\nNow processing...\n\n');
    run('./2. CleanData/start_clean.m');

    fprintf('Start 3. CalculateIF\nNow processing....\n\n');
    run('./3. CalculateIF/CalculateIF2.m');

    fprintf('Start 4. Ensemble\nNow processing.....\n\n');
    run('./4. Ensemble/start_ensemble.m');
end