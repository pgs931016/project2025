clc;clear;close all;
load("G:\공유 드라이브\Battery Software Lab\Projects\현대자동차 (1) 2025\박겸손\NE_HPPC.mat")
load("G:\공유 드라이브\Battery Software Lab\Projects\현대자동차 (1) 2025\NE_MCT25oC_HPPC25oC_OCV_KENTECH.mat")

SOC_interp = min(NE_OCV.SOC): 0.01:max(NE_OCV.SOC);
V = interp1(NE_OCV.SOC,NE_OCV.V,SOC_interp,"linear");
BSA = interp1(NE_OCV.SOC,NE_OCV.BSA,SOC_interp,"linear");

NE_OCV_linear.SOC = SOC_interp;
NE_OCV_linear.V = V;
NE_OCV_linear.BSA = BSA;

NE_OCV_combined = [NE_OCV_linear.SOC(:), NE_OCV_linear.V(:), NE_OCV_linear.BSA(:)];
NE_OCV_linear = array2table(NE_OCV_combined,'VariableNames',{'SOC','V','BSA'});

c_mat = lines(9);

for i = 1:length(data)
    data(i).avg_I  = mean(data(i).I);
end

idx = [];
for i = 1:length(data)
if data(i).avg_I <= -57.6*0.95 && data(i).avg_I >= -57.6*1.05  
   data(i).n1C_flag = 1;
   idx = [idx, i];
else
   data(i).n1C_flag = 0;
end
end

n1C_idx = [];
for i = 1:length(data)
    t_values = data(i).t;
    interval = mean(diff(t_values));
    if any(interval <0.5) && data(i).n1C_flag == 1 && length(data(i).t) >= 10 % 1초 이상의pulse
        n1C_idx = [n1C_idx, i];
    data(i).n1C_flag = 1;
    else
    data(i).n1C_flag = 0;
    end
end

V_array = table2array(NE_OCV_linear(:,"V"));
SOC_array = table2array(NE_OCV_linear(:,"SOC"));

for i = 1:length(data) 
    voltage = data(i).V;  
    SOC = zeros(size(voltage)); 
    
    for j = 1:length(voltage)  
        [~, SOC_idx] = min(abs(V_array - voltage(j))); 
        SOC(j) = SOC_array(SOC_idx); 
    end

    data(i).SOC = SOC; 


%     if data(i).type == 'D' || data(i).type == 'C'
%     Q_tot = trapz(data(i).t, data(i).I);
%     Q_cum = cumtrapz(data(i).t, data(i).I);
%     data(i).n1C.SOC = data(i-1).SOC(end) + (data(i+1).SOC(1) - data(i-1).SOC(end)).*(Q_cum./Q_tot)
%     SOC_pulse = data(i-1).SOC(end) + ...
%                ((data(i+1).SOC(1) - data(i-1).SOC(end)) ./ ...
%                (data(i).t(end) - data(i).t(1))) .* (data(i).t - data(i).t(1));
%     end
% 
%     data(i).SOC = SOC_pulse;  
end


V = {}; I = {}; t = {};
SOC = {}; 
V_final = []; V_after = [];
SOC0 = []; SOC1 = [];
for k = 1:length(n1C_idx) 
    i = n1C_idx(k); 
    data(i).n1C.V = data(i).V;
    data(i).n1C.I = data(i).I;
    data(i).n1C.t = data(i).t;
    data(i).n1C.SOC = data(i).SOC;
    data(i).n1C.V_final = data(i-1).V(end);
    data(i).n1C.V_after = data(i+1).V(end);

    [~, SOC0_idx] = min(abs(NE_OCV_linear.V - data(i).n1C.V_final));
    data(i).n1C.SOC0 = NE_OCV_linear.SOC(SOC0_idx);
    
    [~, SOC1_idx] = min(abs(NE_OCV_linear.V - data(i).n1C.V_after));
    data(i).n1C.SOC1 = NE_OCV_linear.SOC(SOC1_idx);

    V{end+1, 1} = data(i).n1C.V;
    I{end+1, 1} = data(i).n1C.I;
    t{end+1, 1} = data(i).n1C.t;
   
    V_final = [V_final; data(i).n1C.V_final];
    V_after = [V_after; data(i).n1C.V_after];
    SOC0 = [SOC0; data(i).n1C.SOC0];
    SOC1 = [SOC1; data(i).n1C.SOC1];

    Q_tot = trapz(data(i).t, data(i).I);
    Q_cum = cumtrapz(data(i).t, data(i).I);
    data(i).n1C.SOC = data(i).n1C.SOC0 + (data(i).n1C.SOC1 - data(i).n1C.SOC0).*(Q_cum./Q_tot);
    SOC{end+1, 1} = data(i).n1C.SOC;

n1C_pulse = table(V, I, t, V_final, V_after, SOC0, SOC1, SOC);
end

% SOC = {}; 
% for k = 1:length(n1C_idx) 
%     i = n1C_idx(k); 
%     Q_tot = trapz(data(i).t, data(i).I);
%     Q_cum = cumtrapz(data(i).t, data(i).I);
%     data(i).n1C.SOC = data(i).n1C.SOC0 + (data(i).n1C.SOC1 - data(i).n1C.SOC0).*(Q_cum./Q_tot);
%     SOC{end+1, 1} = data(i).n1C.SOC;
% n1C_pulse = table(V, I, t, V_final, V_after, SOC0, SOC);
% end

SOC_idx = [];
checked_i = [];

for k = 1:length(n1C_idx)
    i = n1C_idx(k);
    SOC = data(i).SOC; 
    SOC_target = [95, 92, 35, 31];
    tolerance = 5; 
    
    if ismember(i, checked_i)
        continue; 
    end

    for j = 1:length(SOC)

        if any(abs(SOC_target - SOC(j)) < tolerance)

            SOC_idx = [SOC_idx; i, j];
            checked_i = [checked_i; i];
            break;
        end
    end
end

SOC_1C = n1C_pulse(:,6:7);
SOC_1C_array = table2array(SOC_1C); 
SOC_1C = reshape(SOC_1C_array', [], 1);

V_1C = n1C_pulse(:,4:5);
V_1C_array = table2array(V_1C); 
V_1C = reshape(V_1C_array', [], 1);

SOC_1C_1 = SOC_1C_array(:, 1);
V_1C_1 = V_1C_array(:, 1);

SOC_1C_2 = SOC_1C_array(:, 2);
V_1C_2 = V_1C_array(:, 2);

% % figure
% % hold on;      
% plot(SOC_1C_1, V_1C_1, '-o', 'Color', 'b', 'MarkerFaceColor', 'b', 'DisplayName', 'Column 4');
% plot(SOC_1C_2, V_1C_2, '-o', 'Color', 'r', 'MarkerFaceColor', 'r', 'DisplayName', 'Column 5');
% % plot(SOC_1C, V_1C, '-o');
% 
% legend({'V(start)','V(end)'});
% xlabel('SOC')
% ylabel('Voltage [V]')
% ylim([3.2 4.3])
% yticks([3.2:0.1:4.3])
% title('HPPC (-1C pulse)')
% grid on;
% box on;

point_idx = n1C_idx(:,[1,2,7,8]);



for k = 1:length(point_idx)
    i = point_idx(k);
    figure(i) 
    hold on;

    subplot(2,2,1)

    for j = 13:15
        yyaxis left
        plot(data(j).t - data(14).t(1), data(j).V, 'Color',c_mat(2,:)); hold on;
        ylim([3.6 4.6])
        yticks(3.6:0.2:4.6)
        % xlim([5.15 5.35]);
        % xlim([18540 19260]);
        xlim([-180 360]);
        xticks(-180:60:360);
        xlabel('Time [S]')
        ylabel('Voltage [V]')

        yyaxis right
        plot(data(j).t - data(14).t(1), data(j).I/56.7, 'Color',c_mat(1,:));
        ylim([-2.15 1])
        yticks(-2:0.5:1)
        ylabel('Current [C]')
        title('SOC 95 (-1C pulse)')


        grid on;
        box on;
        width = 16;  
        height = 10; 
        set(gcf, 'Units', 'centimeters', 'Position', [3, 3, width, height]);
    end


     subplot(2,2,2)
    for j = 35:37
        yyaxis left
        plot(data(j).t - data(36).t(1), data(j).V, 'Color',c_mat(2,:)); hold on;
        ylim([3.58 4.6])
        yticks(3.6:0.2:4.6);
        % xlim([11.7 12]);
        % xlim([42120 43200]);
        xlim([-180 360]);
        xticks(-180:60:360);
        xlabel('Time [S]')
        ylabel('Voltage [V]')

        yyaxis right
        plot(data(j).t - data(36).t(1), data(j).I/56.7, 'Color',c_mat(1,:));
        ylim([-2.15 1])
        yticks(-2:0.5:1)
        ylabel('Current [C]')
        title('SOC 92 (-1C pulse)')

        grid on;
        box on;
    end

        subplot(2,2,3)
    for j = 149:151
        
        yyaxis left
         plot(data(j).t - data(150).t(1), data(j).V,'Color',c_mat(2,:)); hold on;
        ylim([3 4])
        % xlim([46.1 46.14]);
        % xlim([165950 166104]);
        xlim([-40 60]);
        xticks(-40:10:60);
        yticks(3:0.2:4)
        xlabel('Time [S]')
        ylabel('Voltage [V]')

        yyaxis right
        plot(data(j).t - data(150).t(1), data(j).I/56.7,'Color',c_mat(1,:));
        ylim([-2.15 1])
        yticks(-2:0.5:1)
        ylabel('Current [C]')
        title('SOC 35 (-1C pulse)')

        grid on;
        box on;
    end


        subplot(2,2,4)
    for j = 175:177
        yyaxis left
        plot(data(j).t - data(176).t(1), data(j).V,'Color',c_mat(2,:)); hold on;
        ylim([3 4])
        % xlim([54.02 54.06]);
        % xlim([194484 194616]);
        xlim([-40 60]);
        xticks(-40:10:60);
        yticks(3:0.2:4)
        xlabel('Time [S]')
        ylabel('Voltage [V]')
        yyaxis right
        plot(data(j).t - data(176).t(1), data(j).I/56.7,'Color',c_mat(1,:));
        ylim([-2.15 1])
        yticks(-2:0.5:1)
        ylabel('Current [C]')
        title('SOC 20 (-1C pulse)')

        grid on;
        box on;
    end

    axs = findall(gcf, 'Type', 'axes'); 
    for idx = 1:length(axs)
        axs(idx).YAxis(1).Color = c_mat(2,:); 
        axs(idx).YAxis(2).Color = c_mat(1,:);
    end
% annotation('rectangle', [0.02, 0.02, 0.96, 0.96], 'LineWidth', 2, 'Color', 'k');

end
% for k = 1:length(point_idx)
%     i = point_idx(k);
%     subplot(2, 2, k); 
%     hold on;
%     for j = i-1:i+1
%         yyaxis left
%         plot(data(j).SOC, data(j).V, 'Color','b');
%         ylim([3 4.5])
%         xlabel('SOC')
%         ylabel('Voltage [V]')
% 
% 
%         yyaxis right
%         plot(data(j).SOC, data(j).I/56.7, 'Color','r');
%         ylim([-1.5 0.5])
%         grid on;
%         box on;
% 
%         ylabel('Currnet [C]')
% 
%     end
% 
% 
% end
%     hold off;
% end

% 
% filenames = sprintf('1C pulse');
% figuresettings12(filenames, 1200);

% 
cd('G:\공유 드라이브\GSP_Data\driving_sample')
% save('postprocessing_HPPC.mat','n1C_pulse','data','NE_OCV','NE_OCV_linear');
filename = '1C_pulse2';
print(filename, '-dtiff', '-r1200');
savefig('1C_pulse2.fig');
















 