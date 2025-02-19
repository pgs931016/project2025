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

% filenames = sprintf('1C pulse');
% figuresettings12(filenames, 1200);

cd('G:\공유 드라이브\GSP_Data\ecm_code')
% save('postprocessing_HPPC.mat','n1C_pulse','data','NE_OCV','NE_OCV_linear',"n1C_idx");
filename = 'V-OCV-ETA';
print(filename, '-dtiff', '-r1200');
savefig('V-OCV-ETA.fig');
















 