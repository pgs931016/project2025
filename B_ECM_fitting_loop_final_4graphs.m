clear; clc; close all

% hyper parameters
% filename = 'postprocessing_HPPC.mat';
c_mat = lines(9);


% data
load("G:\공유 드라이브\GSP_Data\ecm_code\postprocessing_HPPC.mat")
load("G:\공유 드라이브\GSP_Data\ecm_code\1RC_para_cost.mat")
SOC_array = table2array(NE_OCV_linear(:,"SOC"));
V_array = table2array(NE_OCV_linear(:,"V"));

for i = 1:size(n1C_pulse,1)
SOC_val = cell2mat(n1C_pulse.SOC(i)); 
OCV_vec = interp1(SOC_array,V_array,SOC_val,'linear','extrap');
n1C_pulse.OCV{i} = OCV_vec;
end


selected_pulses = [1,2,7,8];
y1 = cell(size(n1C_pulse,1),1);
for i_pulse = 1:size(n1C_pulse,1)
    x = n1C_pulse.t{i_pulse,1}-n1C_pulse.t{i_pulse,1}(1);
    %y1 = n1C_pulse.V{i_pulse,1}-n1C_pulse.V_final(i_pulse); % dV from OCV
    y1{i_pulse} = n1C_pulse.V{i_pulse,1} - n1C_pulse.OCV{i_pulse,1}; 
    y2 = n1C_pulse.I{i_pulse,1};
end

point_idx = [1,2,7,8];

for k = 1:length(point_idx)
    i = point_idx(k);

subplot(2,2,k)
plot(n1C_pulse.t{i,1} - n1C_pulse.t{i,1}(1), n1C_pulse.V{i,1}, 'Color',c_mat(2,:)); hold on;
plot(n1C_pulse.t{i,1} - n1C_pulse.t{i,1}(1), n1C_pulse.OCV{i,1},'Color',c_mat(3,:));
ylim([3.6 4.6]);
yticks(3:0.2:4.6);
xlabel('Time [S]')
ylabel('Voltage')
if k == 3 || k == 4
ylim([3 4]);
yticks(3:0.2:4);
end
yyaxis right
ax =gca;
plot(n1C_pulse.t{i,1} - n1C_pulse.t{i,1}(1), y1{i,1},'Color',c_mat(4,:));
ax.YColor = c_mat(4,:);
ylim([-0.16 0]);
yticks(-0.16:0.02:0); 
legend({'1C Pulse','OCV','Overpotential'}, 'Interpreter','tex','Location','North','Orientation', 'horizontal', 'FontSize', 8, 'Box', 'on');
ylabel('\eta','Interpreter','tex')







end
% 
% selected_pulses = [1,2,7,8];
% for i_pulse = 1:size(n1C_pulse,1)
% 
%     x = n1C_pulse.t{i_pulse,1}-n1C_pulse.t{i_pulse,1}(1);
%     %y1 = n1C_pulse.V{i_pulse,1}-n1C_pulse.V_final(i_pulse); % dV from OCV
%     y1 = n1C_pulse.V{i_pulse,1}-n1C_pulse.OCV{i_pulse,1};
%     y2 = n1C_pulse.I{i_pulse,1};
% 
% if ismember(i_pulse, selected_pulses)
% figure(1)
% set(gcf, 'Units', 'centimeters', 'Position', [3, 3, 26, 20]);
% 
% subplot_index = find(selected_pulses == i_pulse);
% subplot(2,2,subplot_index);
% 
% % subplot(5,2,i_pulse)
% %yyaxis left
% scatter(x, y1, 10, 'o', 'MarkerEdgeColor', c_mat(1,:), 'MarkerFaceColor', c_mat(1,:), ...
%     'MarkerFaceAlpha', 0.2, 'MarkerEdgeAlpha', 0.2);
% 
% % plot(x, y1,'Color',c_mat(2,:));
% ylim([1.1*min(y1) 0])
% %yyaxis right
% %plot(x, y2,'o')
% %ylim([1.1*min(y2) 0])
% end
% 
% % model visualization
% 
% para0 = [abs(y1(1))/abs(y2(1)), abs(y1(end) - y1(1))/abs(y2(1)), tau_opt(i_pulse)]; % initial guess
% 
% y_model = func_1RC(x,y2,para0);
% 
% hold on
% %yyaxis left
% if ismember(i_pulse, selected_pulses)
% figure(1)
% subplot_index = find(selected_pulses == i_pulse); 
% subplot(2,2,subplot_index);
% plot(x,y_model,'-','Color',c_mat(2,:),'LineWidth',1.5)
% end
% 
% 
% 
% %% fitting CASE 1
% % initial guess
%     %para0
% % bound 
%     lb= [0 0 0];
%     ub = para0*2;
% % weight
%     weight = ones(size(y1)); % uniform weighting
% 
% % fitting
%         % options = optimset('display','iter','MaxIter',400,'MaxFunEvals',1e5,...
%         % 'TolFun',1e-10,'TolX',1e-8,'FinDiffType','central');    
%         % para_hat = fmincon(@(para)func_cost(y1,para,x,y2,weight),para0,[],[],[],[],lb,ub,[],options);
%         options = optimset('display','iter', 'MaxIter',400, 'MaxFunEvals',1e5, ...
%                        'TolFun',1e-10, 'TolX',1e-8, 'FinDiffType','central');
%         ms = MultiStart('Display', 'iter', 'UseParallel', true); 
%         problem = createOptimProblem('fmincon', ...
%         'objective', @(para) func_cost(y1, para, x, y2, ones(size(y1))), ...
%         'x0', para0, 'lb', lb, 'ub', ub, 'options', options);
%         num_start_points = 1000;
%         [para_hat, fval, exitflag, output, solutions] = run(ms, problem, num_start_points);
%         para_hats(i_pulse, :) = para_hat;
% 
% % visualize
%     y_model_hat = func_1RC(x,y2,para_hat);
% 
% if ismember(i_pulse, selected_pulses)
% figure(1)
% subplot_index = find(selected_pulses == i_pulse); 
% subplot(2,2,subplot_index);
% %    yyaxis left
%     plot(x,y_model_hat,'-','Color',c_mat(3,:),'LineWidth',1.5)
% end
% 
%  legend({'Experimental Data', 'Initial Guess', 'Fitted Model'}, ...
%     'Orientation', 'horizontal', 'FontSize', 6, 'Box', 'on');
% 
% grid on;
% box on;
% 
% xlabel('Time (sec)');
% ylabel('Voltage [V]')
% 
% end
% 
%  % yticks(-0.14:0.02:0);  
% 
% % lgd = legend({'Experimental Data', 'Initial Guess', 'Fitted Model'}, ...
% %     'Orientation', 'horizontal', 'FontSize', 10, 'Box', 'on');
% 
% % % lgd.Position = [0.4, 0.95, 0.2, 0.05];
% % cd('G:\공유 드라이브\GSP_Data\driving_sample');
% % save('1RC_para_gridsearch','para_hats')
% % savefig('1RC_fitting_gridsearch')
% % print('1RC_fitting_gridsearch','-dtiff','-r1200')
% % %% initial guess
% % 
% % para0_mat =[para0; 0.001 0.001 65; 0.0013 0.0018*2 60; 0.0013 0.0018 60*1.5; 0.0013*0.6 0.0018*0.5 60];
% % 
% % 
% % for i = 1: size(para0_mat,1)
% % 
% % 
% %     para0 = para0_mat(i,:);
% %     lb= [0 0 1];
% %     ub = para0*10;
% % 
% %     % initial model 
% %     y_model = func_1RC(x,y2,para0);
% %     figure(4)
% %     hold on
% %     %yyaxis left
% %     plot(x,y_model,'-','Color',c_mat(2,:));
% % 
% %     % fitted model
% %     para_hat = fmincon(@(para)func_cost(y1,para,x,y2,weight),para0,[],[],[],[],lb,ub,[],options);
% % 
% %     % visualize
% %     y_model_hat = func_1RC(x,y2,para_hat);
% %     figure(4)
% %     hold on
% %     %    yyaxis left
% %     plot(x,y_model_hat,'-','Color',c_mat(3,:))
% % 
% % end


% % model
% function y = func_1RC(t,I,para)
% % x; time in sec
% % para(1) = R0 [ohm]
% % para (2) = R1 [ohm]
% % para (3) = tau1 [ohm]
% % y = overpotential (V - OCV) [V]
% 
% R0 = para(1);
% R1 = para(2);
% tau1 = para(3);
% y = I*R0 + I*R1.*(1-exp(-t/tau1));
% 
% end
% 
% % cost (weight)
% function cost = func_cost(y_data,para,t,I,weight)
% % this is a cost function to be minimized
% y_model = func_1RC(t,I,para);
% cost = sqrt(mean((y_data - y_model).*weight).^2); % RMSE error
% 
% end