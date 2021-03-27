function [iter,image_number] = get_iter_path1(path_list)
%UNTITLED6 此处显示有关此函数的摘要
%   此处显示详细说明
path_list_Face=[path_list,'\','Face'];
path_list_Motorbike=[path_list,'\','Motorbike'];

path_Face=dir(path_list_Face);
path_Motorbike=dir(path_list_Motorbike);

[path_Face_i,~]=size(path_Face);
[path_Motorbike_i,~]=size(path_Motorbike);
image_number=path_Face_i+path_Motorbike_i-4;
iter=cell(1,image_number);%预先定义地址的存储位置
p=randperm(100);
for i=1:100
    if i<50
    for j=3:52
        files_tmp=[path_list_Face,'\',path_Face(j,1).name];
        iter{p(i)}=files_tmp;
    end
    else
        for j=3:52
            files_tmp=[path_list_Motorbike,'\',path_Motorbike(j,1).name]; 
            iter{p(i)}=files_tmp;
        end
    end

end
end

