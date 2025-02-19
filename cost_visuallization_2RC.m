clear; clc; close all

load("G:\공유 드라이브\GSP_Data\postprocessing_HPPC.mat")
SOC_array = table2array(NE_OCV_linear(:,"SOC"));
V_array = table2array(NE_OCV_linear(:,"V"));

for i = 1:size(n1C_pulse,1)
    SOC_val = cell2mat(n1C_pulse.SOC(i)); 
    OCV_vec = interp1(SOC_array, V_array, SOC_val, 'linear', 'extrap');
    n1C_pulse.OCV{i} = OCV_vec;
end

tau1_range = linspace(0,20,21);
tau2_range = linspace(20,80,21);
[tau1_grid, tau2_grid] = meshgrid(tau1_range, tau2_range);
i_pulses = 1:10;
num_pulses = length(i_pulses); 
opt_tau1 = zeros(1, num_pulses);
opt_tau2 = zeros(1, num_pulses);



i_pulses = 1:10;
for n = 1:length(i_pulses)
    i_pulse = i_pulses(n);
    x = n1C_pulse.t{i_pulse,1} - n1C_pulse.t{i_pulse,1}(1);
    y1 = n1C_pulse.V{i_pulse,1} - n1C_pulse.OCV{i_pulse,1};
    y2 = n1C_pulse.I{i_pulse,1};

     for i_tau1 = 1:length(tau1_range)
         for i_tau2 = 1:length(tau2_range)
         tau1 = tau1_range(i_tau1);
         tau2 = tau2_range(i_tau2);

    para0 = [abs(y1(1))/abs(y2(1)) abs(y1(end) - y1(1))/abs(y2(1))/2 tau1 abs(y1(end) - y1(1))/abs(y2(1))/2 tau2]; 
    weight = ones(size(y1));
    cost_grid(i_tau1,i_tau2) = func_cost(y1,para0,x,y2,weight);
         end
     end

cost_grid(isnan(cost_grid)) = inf;
cost_grid(isinf(cost_grid)) = max(cost_grid(~isinf(cost_grid)));

[min_val, min_idx] = min(cost_grid(:));
[row_idx, col_idx] = ind2sub(size(cost_grid), min_idx);

opt_tau1(n) = tau1_range(col_idx);
opt_tau2(n) = tau2_range(row_idx);
para0(n,:) = para0;

figure(1); 
subplot(5, 2, n); 
surf(tau1_grid, tau2_grid, cost_grid); 
hold on;hold on;
plot3(opt_tau1(n), opt_tau2(n), min_val, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
% plot3(init_tau1, init_tau2, cost_grid(find(tau1_range==init_tau1), find(tau2_range==init_tau2)), 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b'); 
colorbar;
xlabel('\tau_1 [S]', 'Interpreter', 'tex', 'FontSize', 10);
ylabel('\tau_2 [S]', 'Interpreter', 'tex', 'FontSize', 10);
zlabel('Cost (RMSE) [V]', 'Interpreter', 'tex', 'FontSize', 10);
title(['Pulse ', num2str(i_pulse), ': Cost function']);
% legend({'{}','Minimum Cost'}, 'Location', 'northeast');
hold off;


figure(2); 
subplot(5,2,n);
contourf(tau1_grid, tau2_grid, cost_grid, 20, 'LineColor', 'none');
hold on;
plot(opt_tau1(n), opt_tau2(n), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); 

colorbar;
xlabel('\tau_1 [S]', 'Interpreter', 'tex', 'FontSize', 10);
ylabel('\tau_2 [S]', 'Interpreter', 'tex', 'FontSize', 10);
title(['Pulse ', num2str(i_pulse), ': Cost function']);
zlabel('Cost(RMSE) [V]', 'Interpreter', 'tex', 'FontSize', 10);
hold off;



% 
% [min_val, row_idx] = min(cost_grid);
% [global_min, col_idx] = min(min_val);  
% golbal_row_idx = row_idx(col_idx);

% cost_grid(isnan(cost_grid)) = inf;
% cost_grid(isinf(cost_grid)) = max(cost_grid(~isinf(cost_grid)));
% 
% [min_val, min_idx] = min(cost_grid(:)); 
% [row_idx, col_idx] = ind2sub(size(cost_grid), min_idx); 
% 
% global_min = cost_grid(row_idx, col_idx); 
% 
% colorbar;
% plot3(tau1_range(row_idx),tau2_range(col_idx), global_min,'ro','MarkerSize',10, 'MarkerFaceColor', 'r');
% xlim([0 10]);
% ylim([20 80]);
% 
% col_idx(n) = col_idx;
% row_idx(n) = row_idx;
% global_min(n) = global_min;

%     title(['Pulse ', num2str(i_pulse), ': Cost Lfunction']);
%     xlabel('\tau_1 [s]','FontSize', 6);
%     ylabel('Cost(RMSE)','FontSize', 6);
end
cd('G:\공유 드라이브\GSP_Data\ecm_code')
save('2RC_cost_initial','opt_tau1','opt_tau2')
savefig('2RC_costplots')
print('2RC_costplots','-dtiff','-r1200')


function y = func_2RC(t,I,para)

R0 = para(1);
R1 = para(2);
tau1 = para(3);
R2 = para(4);
tau2 = para(5);
y = I*R0 + I*R1.*(1-exp(-t/tau1))+I*R2.*(1-exp(-t/tau2));

end



function cost = func_cost(y_data,para,t,I,weight)

y_model = func_2RC(t,I,para);
cost = sqrt(mean((y_data - y_model).*weight).^2); % RMSE error

end
