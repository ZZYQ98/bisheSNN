function [path_iter,labels,num_img] = gen_iter_path( path_list )
%���洢ͼ����ļ���·���е�ͼ�����뵽������

% start_path     = 'E:\Users\JiangKe\Desktop\�ʼǽ�ͼ';        % uigetdir ����ʼ·��
% folder_name    = uigetdir(start_path,'select a folder');    % ѡ��һ���ļ���
% file_list      = dir(folder_name);                    % ��ȡ�ļ����������ļ����ļ��е������б�
% is_sub         = [file_list.isdir];                   % �ж��б��е��Ƿ�Ϊ�ļ��е����ƣ�����1
% file_names     = {file_list(logical(1 - is_sub)).name};     % ��ȡ���ļ��е��ļ���Ϣ
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

