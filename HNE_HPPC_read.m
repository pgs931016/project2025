clc;clear;close all

data_folder = 'G:\공유 드라이브\GSP_Data\driving_sample';

% Split the path using the directory separator
splitPath = split(data_folder, filesep);

% Find the index of "Data" (to be replaced)
index = find(strcmp('driving_sample',splitPath), 1);

% Replace the first "Data" with "Processed_Data"
splitPath{index} = 'driving_sample';

% Create the new save_path
save_path = strjoin(splitPath, filesep);

% Create the directory if it doesn't exist
if ~exist(save_path, 'dir')
   mkdir(save_path)
end

I_1C = 57.6;
n_hd = 2; 



slash = filesep;
files = dir([data_folder slash '*.xlsx']); % select only txt files (raw data)

cd(files.folder)
NE_HPPC = readtable('NE_MCT25oC_HPPC25oC_OCV_KENTECH_송부.xlsx','Sheet','HPPC_25oC','NumHeaderLines',n_hd,'readVariableNames',0);
data1.I = NE_HPPC.Var7;
data1.V = NE_HPPC.Var6;
data1.t1 = NE_HPPC.Var4; %step time
data1.t2 = NE_HPPC.Var5; %total time
data1.cap = NE_HPPC.Var8;
data1.T = NE_HPPC.Var11;


 % datetime
 if isduration(data1.t2(1))
    data1.t = seconds(data1.t2);
 else
    data1.t = data1.t2;
 end

 % absolute current
 data1.I_abs = abs(data1.I);

 % type
 data1.type = char(zeros([length(data1.t),1]));
 data1.type(data1.I>0) = 'C';
 data1.type(data1.I==0) = 'R';
 data1.type(data1.I<0) = 'D';

 % step
 data1_length = length(data1.t);
 data1.step = zeros(data1_length,1);
 m  =1;
 data1.step(1) = m;
 for j = 2:data1_length
    if data1.type(j) ~= data1.type(j-1)
       m = m+1;
    end
    data1.step(j) = m;
 end

%  check for error, if any step has more than one types
vec_step = unique(data1.step);
num_step = length(vec_step);

for i_step = 1:num_step
    type_in_step = unique(data1.type(data1.step == vec_step(i_step)));      
    if size(type_in_step,1) ~=1 || size(type_in_step,2) ~=1
       disp('ERROR: step assignent is not unique for a step')
       return
    end
end

% plot for selected samples

    figure
    old_title = strjoin(strsplit(files.name(1:end-36),'_'),' ');
    new_title = strcat(old_title, ' - HPPC 25', char(176), 'C');
    title(new_title);
    hold on
    plot(data1.t/3600,data1.V,'-')
    xlabel('Time (hours)')
    ylabel('Voltage [V]')
    ylim([2.4 4.4])

    yyaxis right
    plot(data1.t/3600,data1.I/I_1C,'-')
    ylabel('Current [C]')
    ax = gca;
    ax.YColor = 'k';
    box on;
    grid on;



% make struct (output format)
data_line = struct('V',zeros(1,1),'I',zeros(1,1),'t',zeros(1,1),'indx',zeros(1,1),'type',char('R'),...
'steptime',zeros(1,1));
data = repmat(data_line,num_step,1);

% fill in the struc
n =1; 
for i_step = 1:num_step

        range = find(data1.step == vec_step(i_step));
        data(i_step).V = data1.V(range);
        data(i_step).I = data1.I(range);
        data(i_step).t = data1.t(range);
        data(i_step).indx = range;
        data(i_step).type = data1.type(range(1));
        data(i_step).steptime = data1.t1(range);
        data(i_step).cap = data1.cap(range);
        data(i_step).temp = data1.T(range);

        % display progress
            if i_step> num_step/10*n
                 fprintf('%6.1f%%\n', round(i_step/num_step*100));
                 n = n+1;
            end
end
% cd('C:\Users\GSPARK\Documents\GitHub\article_figure');
% save('NE_HPPC.mat', 'data');
% filenames = sprintf('NE - HPPC');
% figuresettings12(filenames, 1200);











