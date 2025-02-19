clc;clear;close all

RPT_num = 6;

%% Variable name change 

Sample01_path = 'G:\공유 드라이브\BSL_Data2\HNE_AgingDOE_Processed\HNE_FCC\1CPD 4C1C(10) (25-42)\10degC\data_ocv_HNE_FCC_1CPD4C1C102542_10degC_s01_111_74_Merged.mat'; %load sample01
Sample02_path = 'G:\공유 드라이브\BSL_Data2\HNE_AgingDOE_Processed\HNE_FCC\1CPD 4C1C(10) (25-42)\10degC\data_ocv_HNE_FCC_1CPD4C1C102542_10degC_s02_112_75_Merged.mat'; %load sample02

load(Sample01_path);
load(Sample02_path);

[~,a,~] = fileparts(Sample01_path);
[~,b,~] = fileparts(Sample02_path);

eval(['data_s01' ' = ' a ';']);
eval(['data_s02' ' = ' b ';'])

%% Normalization

for j = 1:RPT_num % sample 01 normalization
    data_s01(j).LAMp = data_s01(j).LAMp/data_s01(1).Q;
    data_s01(j).LAMn = data_s01(j).LAMn/data_s01(1).Q;
    data_s01(j).LLI = data_s01(j).LLI/data_s01(1).Q;
    data_s01(j).dQ_LLI = data_s01(j).dQ_LLI/data_s01(1).Q;
    data_s01(j).dQ_LAMp = data_s01(j).dQ_LAMp/data_s01(1).Q;
    data_s01(j).dQ_data = data_s01(j).dQ_data/data_s01(1).Q;
    data_s01(j).Q_resistance = data_s01(j).Q_resistance/data_s01(1).Q;
end

for j = 1:RPT_num % sample 02 normalization
    data_s02(j).LAMp = data_s02(j).LAMp/data_s02(1).Q;
    data_s02(j).LAMn = data_s02(j).LAMn/data_s02(1).Q;
    data_s02(j).LLI = data_s02(j).LLI/data_s02(1).Q;
    data_s02(j).dQ_LLI = data_s02(j).dQ_LLI/data_s02(1).Q;
    data_s02(j).dQ_LAMp = data_s02(j).dQ_LAMp/data_s02(1).Q;
    data_s02(j).dQ_data = data_s02(j).dQ_data/data_s02(1).Q;
    data_s02(j).Q_resistance = data_s02(j).Q_resistance/data_s02(1).Q;
end



%% Make average value 

data_line = struct('LAMp',zeros(1,1),'LAMn',zeros(1,1),'LLI',zeros(1,1),'dQ_LLI',zeros(1,1),'dQ_LAMp',zeros(1,1),'dQ_data',zeros(1,1),'Q_resistance',zeros(1,1), 'cycle',zeros(1,1));
data_average_ocv = repmat(data_line,RPT_num,1);

for i = 1:length(data_average_ocv)
    data_average_ocv(i).LAMp = (data_s01(i).LAMp + data_s02(i).LAMp)/2;
    data_average_ocv(i).LAMn = (data_s01(i).LAMn + data_s02(i).LAMn)/2;
    data_average_ocv(i).LLI = (data_s01(i).LLI + data_s02(i).LLI)/2;
    data_average_ocv(i).dQ_LLI = (data_s01(i).dQ_LLI + data_s02(i).dQ_LLI)/2;
    data_average_ocv(i).dQ_LAMp = (data_s01(i).dQ_LAMp + data_s02(i).dQ_LAMp)/2;
    data_average_ocv(i).dQ_data = (data_s01(i).dQ_data + data_s02(i).dQ_data)/2;
    data_average_ocv(i).Q_resistance = (data_s01(i).Q_resistance + data_s02(i).Q_resistance)/2;
    data_average_ocv(i).cycle = data_s01(i).cycle;
end


%% figure 

% Calculate standard deviation for dQ_data (c/3) and Q_resistance
std_dQ_data1 = std(cat(3, [data_s01.dQ_data], [data_s02.dQ_data]), 1, 3);
std_dQ_data_with_resistance1 = std(cat(3, [data_s01.dQ_data] + [data_s01.Q_resistance], [data_s02.dQ_data] + [data_s02.Q_resistance]), 1, 3);

% Plot the stacked ba
figure()
bar([data_average_ocv.cycle], [data_average_ocv.dQ_LLI; data_average_ocv.dQ_LAMp; data_average_ocv.Q_resistance]', 'stacked');
hold on;
plot([data_average_ocv.cycle], [data_average_ocv.dQ_data], '-sc', 'LineWidth', 2); % Cyan
plot([data_average_ocv.cycle], [data_average_ocv.dQ_data] + [data_average_ocv.Q_resistance], '-sm', 'LineWidth', 2); % Magenta

% Add error bars for dQ_data (c/3) and Q_resistance
errorbar([data_average_ocv.cycle], [data_average_ocv.dQ_data], std_dQ_data1, 'Color', [0 1 1], 'LineStyle', 'none', 'LineWidth', 1); % Cyan
errorbar([data_average_ocv.cycle], [data_average_ocv.dQ_data] + [data_average_ocv.Q_resistance], std_dQ_data_with_resistance1, 'Color', [1 0 1], 'LineStyle', 'none', 'LineWidth', 1); % Magenta

% Legend and title
legend({'Loss by LLI', 'Loss by LAMp', 'Loss by resistance', 'Loss data (c/20)', 'Loss data (c/3)'}, 'Location', 'northwest');
title('4CPD 4C (25-42) 10degC ');
ylim([0 0.6])





















%% Make Error Bar graph 