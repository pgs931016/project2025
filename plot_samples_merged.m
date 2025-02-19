clc;clear;close all

data_folder1 = "G:\공유 드라이브\GSP_Data\1C1C.mat"; 
data_folder2 = "G:\공유 드라이브\GSP_Data\QC1C cycles.mat";
data_folder3 = "G:\공유 드라이브\GSP_Data\new_samples.mat";
save_path = "G:\공유 드라이브\GSP_Data";

C_mat = lines(10);

load(data_folder1);
data_merged1 = data_merged;
load(data_folder2);
data_merged2 = data_merged;
load(data_folder3);
data_merged3 = data_merged;

figure(1)
% for i = 1:length(data_merged3.data(1).SOH(:,1))
% plot(data_merged3.data(1).cycles, data_merged3.data(1).SOH(i,:), "Color", C_mat(i,:),'LineWidth', 1.5); hold on;
% end

% for i = 1:length(data_merged3.data(2).SOH(:,1))
% plot(data_merged3.data(2).cycles, data_merged3.data(2).SOH(i,:), "Color", C_mat(i,:),'LineWidth', 1.5); hold on;
% end

plot(data_merged3.data(3).cycles, data_merged3.data(3).SOH, "Color", C_mat(7,:),'LineWidth', 1.5); hold on; 

plot(data_merged3.data(4).cycles, data_merged3.data(4).SOH, "Color", C_mat(8,:),'LineWidth', 1.5); 

plot(data_merged3.data(5).cycles, data_merged3.data(5).SOH, "Color", C_mat(9,:),'LineWidth', 1.5); 

plot(data_merged3.data(6).cycles, data_merged3.data(6).SOH, "Color", C_mat(10,:),'LineWidth', 1.5); 

h = legend({...
    % ['SOH 1C/1C 25', char(176), 'C (1)'], ...
    % ['SOH 1C/1C 25', char(176), 'C (2)'], ...
    % ['SOH 1C/1C 25', char(176), 'C (3)'], ...
       
    % ['SOH 1C/1C 35', char(176), 'C (1)'], ...
    % ['SOH 1C/1C 35', char(176), 'C (2)'], ...
    % ['SOH 1C/1C 35', char(176), 'C (3)']}, ...
    

    ['SOH QC/1C 25', char(176), 'C'], ...
    ['SOH QC/0.3C 25', char(176), 'C'], ...
    ['SOH 1C/0.3C 10', char(176), 'C'], ...
    ['SOH 2C/0.3C 10', char(176), 'C']}, ...
       'Location', 'Southwest');

h.ItemTokenSize(1) = 30;
h.FontSize = 10;

grid on;
ylim ([0 70]);
set(gca, 'YDir', 'reverse');

drawnow;

cd('G:\공유 드라이브\GSP_Data\article_figure');
addpath('C:\Users\GSPARK\Documents\GitHub\article_figure')
savefig('그외조건.fig')
filenames = sprintf('그외조건');
figuresettings_3a(filenames, 1200);
