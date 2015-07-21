*********************** CalculateIF.m ***********************

- 실행

CalculateIF.m 이 메인 스크립트이며, 이것을 실행하면 됩니다.
입력으로 Extreacted_Feature (Result2.mat 파일) 데이터가 필요하며 실행 시 Calculated_Feature (Result3.mat 파일)을 출력합니다.

- 상수 값

1. INTERVALS = 5; % # of transition intervals (5 means 0~4 min)
transition kernel (p^(x) = Alpha * exp (-1 * Beta * x)) 의 parameter들 (Alpha, Beta) 을 계산할 때 transition interval을 몇 분까지 체크할 것인가를 결정합니다.
설정한 INTERVALS 값보다 1분 작은 시간 (예 : INTERVALS = 5의 경우 4분)까지에 해당하는 데이터만 가지고 계산합니다.
기본값은 5 입니다.

2. BETA_BOUND = 4.0; % upper bound for searching Beta
Beta를 fitting 할 때 Beta를 찾는 범위, 즉 찾을 Beta의 최대값을 정합니다.
기본값은 4.0 입니다.

3. BETA_STEP = 0.001; % increment step for searching Beta
Beta를 fitting 할 때 Beta의 증분을 설정합니다.
기본값은 0.001 입니다.
