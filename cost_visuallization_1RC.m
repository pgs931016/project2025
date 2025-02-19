clear; clc; close all

load("G:\공유 드라이브\GSP_Data\postprocessing_HPPC.mat")
SOC_array = table2array(NE_OCV_linear(:,"SOC"));
V_array = table2array(NE_OCV_linear(:,"V"));

for i = 1:size(n1C_pulse,1)
    SOC_val = cell2mat(n1C_pulse.SOC(i)); 
    OCV_vec = interp1(SOC_array, V_array, SOC_val, 'linear', 'extrap');
    n1C_pulse.OCV{i} = OCV_vec;
end

tau1_range = linspace(0,60,121);

for i_pulse = 1:size(n1C_pulse,1)
    
    x = n1C_pulse.t{i_pulse,1} - n1C_pulse.t{i_pulse,1}(1);
    y1 = n1C_pulse.V{i_pulse,1} - n1C_pulse.OCV{i_pulse,1};
    y2 = n1C_pulse.I{i_pulse,1};

     for i_tau1 = 1:length(tau1_range)
         tau1 = tau1_range(i_tau1);
    para_0 = [abs(y1(1))/abs(y2(1)) abs(y1(end) - y1(1))/abs(y2(1)) tau1]; 
    weight = ones(size(y1));
    cost(i_tau1) = func_cost(y1,para_0,x,y2,weight);
   

subplot(5, 2, i_pulse);hold on;
plot(tau1 ,cost(i_tau1),'bo')
xticks(0:5:60)
     end


[~,idx] = min(cost);

plot(tau1_range(idx),cost(idx),'ro','MarkerFaceColor','blue',MarkerSize=8)
tau_opt(i_pulse) = tau1_range(idx);
    title(['Pulse ', num2str(i_pulse), ': Cost function']);
    xlabel('\tau_1 [s]','FontSize', 6);
    ylabel('Cost(RMSE)','FontSize', 6);
end
% cd('G:\공유 드라이브\GSP_Data\ecm_code')
% save('1RC_para_cost','tau_opt')
% savefig('1RC_para_cost')
% print('1RC_para_cost','-dtiff','-r1200')

% model
function y = func_1RC(t,I,para)
R0 = para(1);
R1 = para(2);
tau1 = para(3);
y = I*R0 + I*R1.*(1-exp(-t/tau1));
end


function cost = func_cost(y_data,para,t,I,weight)
y_model = func_1RC(t,I,para); 

cost = sqrt(mean((y_data - y_model).*weight).^2);
end