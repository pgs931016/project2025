clc;clear;close all

% Cycles = {'CYC O', 'CYC 100', 'CYC 200', 'CYC 300', 'CYC 400', 'CYC 500', 'CYC 600', 'CYC 800', 'CYC 1000'};
% Stock = { , 'CYC 400', 'CYC 600', 'CYC 800', 'CYC 1000'};

% cycles1 = [0, 400, 600, 800, 1000];
% cycles2 = [0, 100, 200, 300, 400, 500]; 

%% Variable name change 

data_folder1 = "G:\공유 드라이브\GSP_Data\1C1C.mat"; 
data_folder2 = "G:\공유 드라이브\GSP_Data\QC1C cycles.mat"; 
data_folder3 = "G:\공유 드라이브\GSP_Data\new_samples.mat";
save_path = "G:\공유 드라이브\GSP_Data";

% 데이터 로드
load(data_folder1);
data_merged1 = data_merged;
load(data_folder2);
data_merged2 = data_merged;
load(data_folder3);
data_merged3 = data_merged.data;

% 데이터 정의
cycles1 = [0, 400, 600, 800, 1000];
cycles2 = [0, 100, 200, 300, 400, 500];

M_LLI1 = [data_merged1(1:5).NdQ_LLI];
M_LLI2 = [data_merged2(1:6).NdQ_LLI];
M_LAMp1 = [data_merged1(1:5).NdQ_LAMp];
M_LAMp2 = [data_merged2(1:6).NdQ_LAMp];
M_R1 = [data_merged1(1:5).NR];
M_R2 = [data_merged2(1:6).NR];

% 통합된 X축 생성 
combined_cycles = unique([cycles1, cycles2]);

% 첫 번째 그룹 데이터를 통합된 X축에 맞게 재배열
y1 = zeros(length(combined_cycles), 3); 
for i = 1:length(cycles1)
    idx = combined_cycles == cycles1(i);
    y1(idx, :) = [M_LLI1(i), M_LAMp1(i), M_R1(i)];
end

% 두 번째 그룹 데이터를 통합된 X축에 맞게 재배열
y2 = zeros(length(combined_cycles), 3); 
for i = 1:length(cycles2)
    idx = combined_cycles == cycles2(i);
    y2(idx, :) = [M_LLI2(i), M_LAMp2(i), M_R2(i)];
end

% 오프셋 적용할 X축 값 설정
offset_cycles = [0, 400];
offset = 16.7;

% 첫 번째 그룹의 X축 위치 조정
x1_adjusted = combined_cycles;
x1_adjusted(ismember(combined_cycles, offset_cycles)) = x1_adjusted(ismember(combined_cycles, offset_cycles)) - offset;

% 두 번째 그룹의 X축 위치 조정
x2_adjusted = combined_cycles;
x2_adjusted(ismember(combined_cycles, offset_cycles)) = x2_adjusted(ismember(combined_cycles, offset_cycles)) + offset;

% 막대 그래프 그리기
barWidth = 0.4; 

colors =    [0.937254901960784	0.752941176470588	0;    % LLI (yellow)
             0	0.450980392156863	0.760784313725490;    % LAMp (red)
             0.125490196078431	0.521568627450980	0.305882352941177];  % R (green)

data_C_Q = [56.9 56.0 55.3 54.7 53.9];
Crate_Q = [56.3 54.9 54.4 53.7 52.9];

Q_C_max = 56.9;

Q_norm1 = 1 - (abs(data_C_Q) / abs(Q_C_max));
Q_norm3 = data_merged3(1).SOH./100;
Q_norm3 = Q_norm3';



C_Q_norm1 = abs(Crate_Q) / abs(Q_C_max);

% x와 y 데이터 정의 
x = [-17, 383, 600, 800, 1000];
x3 = [-17, 200, 383, 600, 800, 1000];
y = Q_norm1;
y3 = Q_norm3;

% 보간을 위한  x 값 생성
x_fine = linspace(min(x), max(x), 100);

% interp1 곡선 생성
y_smooth = interp1(x, y, x_fine);

% y_smooth3 = zeros(length(x_fine),size(y3,2));
for i = 1:size(y3,2)
y_smooth3(:,i) = interp1(x3, y3(:,i), x_fine);
end

% plot([-17 383 600 800 1000], Q_norm1, '-s', 'LineWidth', 0.5); hold on;

% 완속충전 그리기
hBar = bar(x1_adjusted, y1, 'stacked', 'BarWidth', barWidth, 'FaceAlpha', 0.8); hold on;
for i = 1:length(hBar)
    hBar(i).FaceColor = 'flat'; 
    hBar(i).CData =  repmat(colors(i, :), size(hBar(i).YData', 1), 1);
    hBar(i).EdgeColor = 'b';
    hBar(i).LineWidth = 2;
end


% 그래프 그리기 
% line_alpha = 0.2;
% scatter(x, y, 10, 'o'); 
% scatter(x_fine, y_smooth, 10, 'ob', 'MarkerFaceAlpha', line_alpha);

linestyles = {':',':',':'};
h1 = plot(x_fine, y_smooth,'Color','b','LineWidth',1.5); hold on;
for i = 1:size(y3,2)
h3 = plot(x_fine,y_smooth3(:,i),'Color','b','LineStyle',linestyles{i});
end


% ------------------------------------------
data_C_Q = [56.9 56.6 56.3 55.7 54.8 51.8];
Crate_Q = [56.6 55.9 55.6 55.0 54.1 51.4];

Q_C_max = 56.9;

Q_norm2 = 1 - (abs(data_C_Q) / abs(Q_C_max));
C_Q_norm2 = abs(Crate_Q) / abs(Q_C_max);
Q_norm4 = data_merged3(3).SOH./100;

x = [17 100 200 300 417 500];
y = Q_norm2;
y4 = Q_norm4(1:6);

x_fine = linspace(min(x), max(x), 100);

y_smooth = interp1(x, y, x_fine);
y_smooth4 = interp1(x, y4, x_fine);

% h2 그룹
hBar = bar(x2_adjusted, y2, 'stacked', 'BarWidth', barWidth, 'FaceAlpha', 0.8);
for i = 1:length(hBar)
    hBar(i).FaceColor = 'flat'; 
    hBar(i).CData =  repmat(colors(i, :), size(hBar(i).YData', 1), 1);
    hBar(i).EdgeColor = 'r';
    hBar(i).LineWidth = 2;
end

% h2그래프 그리기

h2 = plot(x_fine, y_smooth,'Color','r','LineWidth',1.5); 
h4 = plot(x_fine,y_smooth4,'Color','r','LineStyle',':');
% X축 설정
xticks(combined_cycles);
xticklabels(string(combined_cycles))


xlabel('Cycles');
ylabel('$\Delta Q$', 'Interpreter', 'latex');

xlim([-34 1017]);
ylim([0 0.12]);
yticks(0:0.02:0.12);

set(gca, 'YDir', 'reverse');
set(gca, 'XTick', 0:100:1000);
xticklabels(string(0:100:1000))
grid on;
box on;


% legend 재설정
hLegend(1) = patch(NaN, NaN, [0.937254901960784	0.752941176470588	0], 'EdgeColor', 'none'); % 노랑 (LLI)
hLegend(2) = patch(NaN, NaN, [0	0.450980392156863	0.760784313725490], 'EdgeColor', 'none');   % 파랑 (LAMp)
hLegend(3) = patch(NaN, NaN, [ 0.125490196078431	0.521568627450980	0.305882352941177], 'EdgeColor', 'none'); % 초록 (R)


h = legend([hLegend, h1, h3, h2, h4],{'Loss by LLI', 'Loss by LAMp', 'Loss by R', '1C Loss','1C Loss', 'QC Loss', 'QC Loss' }, 'Location', 'SouthWest', 'Box', 'on');
h.ItemTokenSize(1) = 30;
h.FontSize = 5;


% %-----------------------------------------
% % 현재 y축 눈금 값과 레이블 가져오기
% yticks = get(gca, 'YTick');
% yticklabels = get(gca, 'YTickLabel');
% 
% % 제거하려는 눈금 값의 인덱스 찾기 (예: 0)
% indexToRemove = find(yticks == 0);
% 
% % 해당 인덱스의 눈금 값과 레이블 제거
% yticks(indexToRemove) = [];
% yticklabels(indexToRemove, :) = [];
% 
% % 수정된 눈금 값과 레이블 설정
% set(gca, 'YTick', yticks);
% set(gca, 'YTickLabel', yticklabels);
% 
addpath('C:\Users\GSPARK\Documents\GitHub\article_figure');
cd('G:\공유 드라이브\GSP_Data');
savefig('bar_new')
filenames = sprintf('bar_new');
figuresettings_3a(filenames,1200);


% hbar1 = bar(cycles1, [M_LLI1; M_LAMp1; M_R1],'stacked');
% hbar2 = bar(cycles2, [M_LLL2; M_LAMp2; M_R2],'stacked');


% % 첫 번째 그룹 y 데이터를 통합 x 축에 맞게 재정렬
% y1_new = zeros(length(combined_x), size(y1, 2));
% for i = 1:length(grp1_x)
%     idx = combined_x == grp1_x(i);
%     y1_new(idx, :) = y1(i, :);
% end
% 
% % 두 번째 그룹 y 데이터를 통합 x 축에 맞게 재정렬
% y2_new = zeros(length(combined_x), size(y2, 2));
% for i = 1:length(grp2_x)
%     idx = combined_x == grp2_x(i);
%     y2_new(idx, :) = y2(i, :);
% end
% 
% % 막대 그래프 그리기
% bar(grp1_x - 25, y1, 'stacked', 'BarWidth', 0.3, 'FaceAlpha', 0.8);
% xticklabels(string([0 100 200 300 400 500]));
% hold on;
% bar(grp2_x + 25, y2, 'stacked', 'BarWidth', 0.3, 'FaceAlpha', 0.8);
% % xticks([grp1_x grp2_x]); % 원래 x축 값 설정
% xticklabels(string([0 400 600 800 1000])); % x축 레이블 그대로 표시


% % 두 번째 그룹 (data_merged2)
% bar(grp2_x, y2, 'stacked', 'BarWidth', 0.3, 'FaceAlpha',0.8)

% colors = [0.572549019607843 0.368627450980392 0.623529411764706;   % LLI
%           0.882352941176471 0.529411764705882 0.152941176470588;   % LAMp
%           0.937254901960784 0.752941176470588 0];                  % 저항

% hbar = bar([data_merged1(1:5).cycle], [data_merged1(1:5).NdQ_LLI; data_merged1(1:5).NdQ_LAMp(1:5); data_merged1(1:5).NR], ...
%     'stacked', 'BarWidth', 0.4);
% for i = 1:length(hBar)
%     hBar(i).FaceColor = 'flat'; 
%     hBar(i).CData = repmat(colors(i, :), size(hBar(i).YData', 3), 1);
%     hBar(i).BarWidth = bar_width;
% 
% for i = 1:length(hBar)
%     hBar(i).FaceColor = 'flat'; 
%     hBar(i).CData = repmat(colors(i, :), size(hBar(i).YData', 3), 1);
%     hBar(i).BarWidth = bar_width;
% end
% 
% end
% 
% hold on;
% hbar = bar([data_merged2(1:6).cycle], [data_merged2(1:6).NdQ_LLI; data_merged2(1:6).NdQ_LAMp; data_merged2(1:6).NR], ...
%     'stacked', 'BarWidth', 0.4);
% 
% for i = 1:length(hBar)
%     hBar(i).FaceColor = 'flat'; 
%     hBar(i).CData = repmat(colors(i, :), size(hBar(i).YData', 3), 1);
%     hBar(i).BarWidth = bar_width;
% end
% 
% 
% set(gca, 'YDir', 'reverse');
% 
% xlabel('Cycle');
% ylabel('$\Delta Q$', 'Interpreter', 'latex');
% yticks(0:0.01:0.12);
% ylim([0 0.12]);
% 
% h = legend({'Loss by LLI', 'Loss by LAMp', 'Loss by R', 'Loss data (C/10)', 'Loss data (C/3)'}, 'Location', 'northwest');
% h.ItemTokenSize(1) = 15;
% h.FontSize = 6;
% 
% grid on;
% title('Combined Cycle Analysis with Reversed Y-axis');


% 
% % 
% % %% Normalization
% % 
% for j = 1:length(data_merged) % sample 01 normalization
%     data_merged(j).NLAMp = data_merged(j).LAMp/data_merged(1).Q;
%     data_merged(j).NLAMn = data_merged(j).LAMn/data_merged(1).Q;
%     data_merged(j).NLLI = data_merged(j).LLI/data_merged(1).Q;
%     data_merged(j).NdQ_LLI = data_merged(j).dQ_LLI/data_merged(1).Q;
%     data_merged(j).NdQ_LAMp = data_merged(j).dQ_LAMp/data_merged(1).Q;
%     data_merged(j).NdQ_data = data_merged(j).dQ_data/data_merged(1).Q;
%     data_merged(j).NR = data_merged(j).R/data_merged(1).Q;
% end
% 
% colors =    [0.572549019607843	0.368627450980392	0.623529411764706;   % LLI
%              0.882352941176471	0.529411764705882	0.152941176470588;    % LAMp
%              0.937254901960784	0.752941176470588	0];  % 저항
% 
% % % Plot the stacked bar
% subplot(1,2,1)
% hBar = bar([data_merged.cycle], [data_merged.NdQ_LLI; data_merged.NdQ_LAMp;data_merged.NR]', 'stacked');
% 
% for i = 1:length(hBar)
%     hBar(i).FaceColor = 'flat'; 
%     hBar(i).CData = repmat(colors(i, :), size(hBar(i).YData', 3), 1);
% end
% 
% hold on;
% plot([data_merged.cycle], [data_merged.NdQ_data] , '-sc', 'LineWidth', 1); % Cyan
% plot([data_merged.cycle], [data_merged.NdQ_data] + [data_merged.NR], '-sm', 'LineWidth', 1); % Magenta
% 
%    yticks(0:0.01:0.08);
%    ylim([0 0.08]);
% 
% h = legend({'Loss by LLI', 'Loss by LAMp', 'Loss by R', 'Loss data (C/10)', 'Loss data (C/3)'}, 'Location', 'northwest');
%     h.ItemTokenSize(1) = 15;
%     h.FontSize = 4;
% 
%     xlabel('cycle');
%     ylabel('$\Delta Q$', 'Interpreter', 'latex');
% % title('고속층전(QC1C) 열화인자 분석');
% 
% 
% %fig1 = sprintf('G:\\공유 드라이브\\BSL-Data\\Processed_data\\Hyundai_dataset\\현대차파우치셀 (rOCV,Crate)\\1C1C\\Nbar_plot.jpg');
% % fig1 = sprintf('G:\\공유 드라이브\\BSL-Data\Processed_data\\Hyundai_dataset\\현대차파우치셀 (rOCV,Crate)\\QC1C\\QC1C셀들(C20)\\Nbar_plot');
% % saveas(gcf, fig1);
% 
% save(save_path,'data_merged');
% cd(save_path);
% filenames = sprintf('1c1cbar');
% figuresettings17(filenames, 1200);


% data_folder = "G:\공유 드라이브\BSL-Data\Processed_data\Hyundai_dataset\현대차파우치셀 (rOCV,Crate)\QC1C\QC1C사이클(C10)\fig_500cyc\NE_data_ocv2.mat"; 
% save_path = "G:\공유 드라이브\GSP_Data\QC1C cycles";
% load(data_folder);
% 
% for j = 1:length(data_merged) % sample 01 normalization
%     data_merged(j).NLAMp = data_merged(j).LAMp/data_merged(1).Q;
%     data_merged(j).NLAMn = data_merged(j).LAMn/data_merged(1).Q;
%     data_merged(j).NLLI = data_merged(j).LLI/data_merged(1).Q;
%     data_merged(j).NdQ_LLI = data_merged(j).dQ_LLI/data_merged(1).Q;
%     data_merged(j).NdQ_LAMp = data_merged(j).dQ_LAMp/data_merged(1).Q;
%     data_merged(j).NdQ_data = data_merged(j).dQ_data/data_merged(1).Q;
%     data_merged(j).NR = data_merged(j).R/data_merged(1).Q;
% end
% 
% 
% subplot(1,2,2)
% hBar = bar([data_merged(1:6).cycle], [data_merged(1:6).NdQ_LLI; data_merged(1:6).NdQ_LAMp; data_merged(1:6).NR]', 'stacked');
% 
% for i = 1:length(hBar)
%     hBar(i).FaceColor = 'flat'; 
%     hBar(i).CData = repmat(colors(i, :), size(hBar(i).YData', 3), 1);
% end
% 
% hold on;
% 
% plot([data_merged(1:6).cycle], [data_merged(1:6).NdQ_data] , '-sc', 'LineWidth', 1); % Cyan
% plot([data_merged(1:6).cycle], [data_merged(1:6).NdQ_data] + [data_merged(1:6).NR], '-sm', 'LineWidth', 1); % Magenta
% 
% yticks(0:0.02:0.12);
% ylim([0 0.12]);
% 
%     xlabel('cycle');
%     ylabel('$\Delta Q$', 'Interpreter', 'latex');
% 
% h = legend({'Loss by LLI', 'Loss by LAMp', 'Loss by R', 'Loss data (C/10)', 'Loss data (C/3)'}, 'Location', 'northwest');
%     h.ItemTokenSize(1) = 15;
%     h.FontSize = 4;
% 
% % data_merged = data_folder.data_merged; 
% save(save_path,'data_merged');
% cd(save_path);
% addpath('C:\Users\GSPARK\Documents\GitHub\article_figure');
% filenames = sprintf('Qc1cbarchart_test');
% figuresettings43a(filenames, 1200);










