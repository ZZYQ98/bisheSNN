%SDNN的主函数  main（）
%首先网络输入参数
clc
clear

%输入图片路径
global spike_times_train
global spike_times_learn
path_list='D:\SDNN_files\learn';
spike_times_to_learn='D:\MATLABfiles\MINST';
spike_times_to_train='D:\MATLABfiles\MINST';
spike_times_to_test='D:\SDNN_files\test';
path_set_weights='D:\SDNN_files\set_weight';
%结果存储路径
path_save_weights='D:\SDNN_files\set_weights';
path_features='D:\SDNN_files\features';
%定义FLAG
global learn_SDNN
global set_weights
global save_weights
global save_feature
global DoG
%标志位定义
learn_SDNN=1;   %定义网络学习标志位，learn_SDNN等于1时，网络进行STDP学习，当learn_SDNN等于0时，网络不发生学习，直接读取已经得到的权值数据，进行测试
%首先看网络是否进行训练      
if  learn_SDNN==1                  
    set_weights=0;         %训练时，不设置权值，而进行权值初始化
    save_weights=1;         %进行训练，保存权值信息与路径信息
    save_feature=1;
else                       %不训练时，设置权值，
    set_weights=1;
    save_weights=0;
    save_feature=0;
end

DoG=1;            %定义DoG滤波标志位，DoG等于1时，输入图像进行滤波得到脉冲发射时间，当DoG等于0时，从文件中读取脉冲发射时间 

%SDNN参数——————————————————————————————————
global weights
global layers
global max_iter
global max_learn_iter
global a_minus
global a_plus
global learnable_layers
global img_size
global STDP_time
global learn_buffer
global num_layers
global STDP_time_pre %STDP作用时间
global STDP_time_post
global network_struct
global STDP_params
global DoG_params
global total_time
img_size=struct('img_sizeH',28,'img_sizeW',28);%定义图像规模
DoG_params=struct('img_size', img_size, 'DoG_size', 5, 'std1', 1, 'std2', 2);%定义DoG参数
%定义网络参数
l1=struct('type','input', 'num_filters', 1, 'pad',0, 'H_layer',DoG_params.img_size.img_sizeH,'W_layer', DoG_params.img_size.img_sizeW);
l2=struct('type', 'conv', 'num_filters', 4, 'filter_size', 3, 'th', 1.5);
l3=struct('type', 'pool', 'num_filters', 1, 'filter_size', 5, 'th', 0., 'stride', 3);
l4=struct('type', 'conv', 'num_filters',10, 'filter_size', 7, 'th', 3);
l5=struct('type', 'pool', 'num_filters',1, 'filter_size', 5, 'th', 0, 'stride',2);
l6=struct('type', 'conv', 'num_filters',8, 'filter_size', 3, 'th', 2);
learnable_layers=[2,4,6];
network_params={l1,l2,l3,l4,l5,l6};
weight_params=struct('mean',0.8,'std',0.05);%定义权值初始化参数
max_learn_iter=[0,300,0,400,0,500,0];
STDP_per_layer=[0,10,0,4,0,2];
max_iter=sum(max_learn_iter);
a_minus=[0,0.003,0,0.003,0,0.003];
a_plus=[0,0.004,0,0.004,0,0.004];
offset_STDP=[0,floor(network_params{2}.filter_size),0,floor(network_params{4}.filter_size/8),0,floor(network_params{6}.filter_size)];
STDP_params=struct('max_learning_iter',max_learn_iter,'STDP_per_layer',STDP_per_layer,...
                   'max_iter',max_iter,'a_minus',a_minus,'a_plus',a_plus,'offset_STDP',offset_STDP);
total_time=100;
STDP_time=10;%用于定义K_STDP标志矩阵
STDP_time_pre=10;
STDP_time_post=8;
%-------------------------------------根据输入参数创建网络SDNN_net----------------------------------------------------
%网络结构初始化
[~,num_layers]=size(network_params);
network_struct=init_net_struct(network_params);%调用函数network_struct，按照设置参数对于网络进行初始化
%network_struct为网络结构体，learnable_layers为可进行学习的卷积层

layers = init_layers(network_struct);%调用函数init_layers，网络中层的初始化

%权值矩阵初始化
[weights]= init_weights( weight_params,network_struct);%调用函数init_weight，用于生成网络权值矩阵，并按要求初始化权值
%weights为初始化的权值矩阵，W_shape为权值矩阵的尺寸

%check_dimensions( network_struct,W_shape )%检查获得的权值矩阵维度与网络维度是否相同，若产生错误，则返回对应的错误原因

%——————————————————输入脉冲是否经过滤波得到————————————————————————————————————
% 
if DoG==1
     [spike_times_learn,y_learn]=gen_iter_path(spike_times_to_learn);%将图片输入，还需要进行滤波
     [spike_times_train,y_train]=gen_iter_path(spike_times_to_train);
%     [spike_times_text,y_test]=gen_iter_path(spike_times_to_test);
     [num_img_learn,~]=size(y_learn);
     [num_img_train,~]=size(y_train);
%     [num_img_test,~]=size(y_test);
 else
     spike_times_learn=spike_times_to_learn;       %不经过滤波，直接将脉冲时间输入,这些输入脉冲时间参数均为之前得到的，保存在文件中
     [num_img_learn,~]=size(spike_times_learn);
     spike_times_train=spike_times_to_train;
     [num_img_train,~]=size(spike_times_train);
%     spike_times_test=spike_times_to_test;
%     [num_img_,~]=size(spike_times_texst);
 end       

%------------------------------------训练得到结果-----------------------------------------------------------------------
features_train=[];
features_text=[];

%设置权值或者进行STDP学习
if set_weights==1
    weights_buff=load(weights_path_list);  %将从文件中输入的权值矩阵赋值给buffer
    weights=weights_buff.weights;
else
    learn_buffer=spike_times_learn;
    train_SDNN(network_struct,total_time,spike_times_learn,DoG_params,num_img_learn);
end
%权值存储
if save_weights==1
    save('weights','weights');
end
%----------------------------------特征判别与输出特征--------------------------------------------------------------------
% %特征判别
%[X_train] = train_feature(num_img_train);
% [X_text,y_text]=test_feature();%------------函数还未定义


%保存X_train X_test
%保存x_train,y_train,x_text,y_text







% %---------------------------------分类器------------------------------------------------------------------------
% calssfier_params=struct('C',1,'gamma','auto');
% train_mean=mean(X_train,1);
% train_std=std(X_train,1);
% X_train=X_train-train_mean;
% X_test=X_test-train_mean;
% X_train=X_train/(train_std+1e-5);
% X_test=X_test/(train_std+1e-5);
% 
% %调用分类器 classfier
% 









