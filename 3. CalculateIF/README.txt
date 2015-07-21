*********************** CalculateIF.m ***********************

- ����

CalculateIF.m �� ���� ��ũ��Ʈ�̸�, �̰��� �����ϸ� �˴ϴ�.
�Է����� Extreacted_Feature (Result2.mat ����) �����Ͱ� �ʿ��ϸ� ���� �� Calculated_Feature (Result3.mat ����)�� ����մϴ�.

- ��� ��

1. INTERVALS = 5; % # of transition intervals (5 means 0~4 min)
transition kernel (p^(x) = Alpha * exp (-1 * Beta * x)) �� parameter�� (Alpha, Beta) �� ����� �� transition interval�� �� �б��� üũ�� ���ΰ��� �����մϴ�.
������ INTERVALS ������ 1�� ���� �ð� (�� : INTERVALS = 5�� ��� 4��)������ �ش��ϴ� �����͸� ������ ����մϴ�.
�⺻���� 5 �Դϴ�.

2. BETA_BOUND = 4.0; % upper bound for searching Beta
Beta�� fitting �� �� Beta�� ã�� ����, �� ã�� Beta�� �ִ밪�� ���մϴ�.
�⺻���� 4.0 �Դϴ�.

3. BETA_STEP = 0.001; % increment step for searching Beta
Beta�� fitting �� �� Beta�� ������ �����մϴ�.
�⺻���� 0.001 �Դϴ�.
