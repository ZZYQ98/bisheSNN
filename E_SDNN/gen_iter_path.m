function [path_iter,labels,num_img] = gen_iter_path( path_list )
%将存储图像的文件夹路径中的图像输入到网络中

% start_path     = 'E:\Users\JiangKe\Desktop\笔记截图';        % uigetdir 的起始路径
% folder_name    = uigetdir(start_path,'select a folder');    % 选择一个文件夹
% file_list      = dir(folder_name);                    % 获取文件夹下所有文件和文件夹的名称列表
% is_sub         = [file_list.isdir];                   % 判断列表中的是否为文件夹的名称，是则1
% file_names     = {file_list(logical(1 - is_sub)).name};     % 获取非文件夹的文件信息
path=dir(path_list);
[path_i,path_j]=size(path);
path_iter=cell(path_i,path_j);
num_img=path_i;
for i=1:path_i
files_tmp=[path_list,'\',path(i,1).name];
path_iter{i}=files_tmp;
end

labels=ones(path_i,path_j);
end

