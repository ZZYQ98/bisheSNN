clc 
clear
%得到图片的地址，存在buff中
path_list='D:\git_code\D_SDNN\dataset_new\LearningSet';
path_list_Face=[path_list,'\','Face'];
path_list_Motorbike=[path_list,'\','Motorbike'];

path_Face=dir(path_list_Face);
path_Motorbike=dir(path_list_Motorbike);

[path_Face_i,path_Face_j]=size(path_Face);
[path_Motorbike_i,path_Motorbike_j]=size(path_Motorbike);
iter=cell(1,path_Face_i+path_Motorbike_i-4);%预先定义地址的存储位置
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
%[path_iter,labels,num_img]=gen_iter_path(path_list);