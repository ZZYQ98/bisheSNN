%SDNN的主函数  main（）
%首先网络输入参数
clc
clear

%输入图片路径
path_list='D:\git_code\E_SDNN\dataset_new';
spike_times_to_learn=[path_list,'\LearningSet'];
spike_times_to_train=[path_list,'\TrainingSet'];
spike_times_to_test=[path_list,'\TestingSet'];
path_set_weights='D:\git code\bisheSNN\set_weight';
%结果存储路径
path_save_weights='D:\git code\bisheSNN\set_weights';
path_features='D:\git code\bisheSNN\features';
%定义FLAG
global learn_SDNN
global relearn_SDNN
global set_weights
global save_weights
global save_feature
global DoG
global total_time
%标志位定义
learn_SDNN=1;   %定义网络学习标志位，learn_SDNN等于1时，网络进行STDP学习，当learn_SDNN等于0时，网络不发生学习，直接读取已经得到的权值数据，进行测试
relearn_SDNN=1;
random_input_img=0;
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
img_size=struct('img_sizeH',160,'img_sizeW',250);%定义图像规模
DoG_params=struct('img_size', img_size, 'DoG_size', 5, 'std1', 1, 'std2', 2);%定义DoG参数
%定义网络参数
l1=struct('type','input', 'num_filters', 1, 'pad',0, 'H_layer',DoG_params.img_size.img_sizeH,'W_layer', DoG_params.img_size.img_sizeW);
l2=struct('type', 'conv', 'num_filters', 4, 'filter_size', 5, 'th', 6);
l3=struct('type', 'pool', 'num_filters', 4, 'filter_size', 17, 'th', 0., 'stride', 16);
l4=struct('type', 'conv', 'num_filters',10, 'filter_size', 15, 'th', 20);
learnable_layers=[2,4];
network_params={l1,l2,l3,l4};
weight_params=struct('mean',0.8,'std',0.01);%定义权值初始化参数 
max_learn_iter=[0,800,0,900];
STDP_per_layer=[0,4,0,1];
max_iter=sum(max_learn_iter);
a_minus=[0,0.003,0,0.003];
a_plus=[0,0.005,0,0.005];
offset=[0 5 0 0];
%获得STDP权值更新矩阵
tao_minus=40;
tao_plus=20;
% STDP_time_pre=35;%增强型STDP 窗口时长
% STDP_time_post=35;%抑制性STDP 窗口时长
STDP_time=35;%STDP 窗口时长
deta_STDP_minus=deta_STDP(0.03,STDP_time,tao_minus);  %作用窗长度为STDP_time_minus=35，时常数为40
deta_STDP_plus=deta_STDP(0.07,STDP_time,tao_plus);    %作用窗长度为STDP_time_plus=30，时常数为20

STDP_params=struct('max_learning_iter',max_learn_iter,'STDP_per_layer',STDP_per_layer,...
                   'max_iter',max_iter,'a_minus',a_minus,'a_plus',a_plus,'offset',offset);
total_time=30;

%强化学习，进行的STDP学习
retrain_params=struct('a_minus_r', 0.03, 'a_plus_r', 0.05, 'a_minus_p', 0.07, 'a_plus_p', 0.01,...
                     'tao_minus_r',40, 'tao_plus_r',20, 'tao_minus_p', 80, 'tao_plus_p', 10,'retrain_iter',1000);
%-------------------------------------根据输入参数创建网络SDNN_net----------------------------------------------------
%网络结构初始化
network_struct=init_net_struct(network_params);%调用函数network_struct，按照设置参数对于网络进行初始化
%network_struct为网络结构体，learnable_layers为可进行学习的卷积层

layers = init_layers(network_struct);%调用函数init_layers，网络中层的初始化

%权值矩阵初始化
[weights]= init_weights( weight_params,network_struct);%调用函数init_weight，用于生成网络权值矩阵，并按要求初始化权值
%weights为初始化的权值矩阵，W_shape为权值矩阵的尺寸

%check_dimensions( network_struct,W_shape )%检查获得的权值矩阵维度与网络维度是否相同，若产生错误，则返回对应的错误原因

%——————————————————输入脉冲是否经过滤波得到————————————————————————————————————
% label中，face为1，motobike为2
if random_input_img==1
     [spike_times_learn,label_learn]=get_iter_path1(spike_times_to_learn);%将图片输入，还需要进行滤波
     [spike_times_train,label_train]=get_iter_path1(spike_times_to_train);
     [spike_times_test,label_test]=get_iter_path1(spike_times_to_test);
     [~,num_img_learn]=size(spike_times_learn);
     [~,num_img_train]=size(spike_times_train);
     [~,num_img_test]=size(spike_times_test);
else           % ----------------------固定的输入次序
     spike_times_learn=load("data100_spike_times_learn.mat").spike_times_learn;      
     label_learn=load("data100_label_learn.mat").label_learn;
     [~,num_img_learn]=size(spike_times_learn);
    
     spike_times_train=load("data100_spike_times_train.mat").spike_times_train;      
     label_train=load("label_train.mat").label_train;
     [~,num_img_train]=size(spike_times_train);
     
     spike_times_test=load("data100_spike_times_test.mat").spike_times_test;      
     label_test=load("data100_label_test.mat").label_test;
     [~,num_img_test]=size(spike_times_test);
end       

% %------------------------------------训练得到结果-----------------------------------------------------------------------

weights_path_list='weights_4_10.mat';

%设置权值或者进行STDP学习
if set_weights==1
   weights =load(weights_path_list);  %将文件中的权值矩阵取出，直接进行赋值
   weights=weights.weights;
else
    %第一层权值的训练已经结束
    weights_2_trained=load("weights_2_trained.mat").weights_2_trained;
    weights{2}=weights_2_trained;
    weights=train_SDNN(weights,layers,network_struct,spike_times_learn,DoG_params,STDP_params,num_img_learn,learnable_layers,total_time,deta_STDP_minus,deta_STDP_plus);
    save('weights_4_11_train_SDNN.mat','weights');
end
if relearn_SDNN==1
    weights=retrain_SDNN(weights,layers,network_struct,spike_times_learn,DoG_params,STDP_params,num_img_learn,total_time,STDP_time,retrain_params,label_learn);
end
%权值存储
if save_weights==1
    save('weights_4_11_retrain_SDNN.mat','weights');
end
%----------------------------------特征判别与输出特征--------------------------------------------------------------------
% %特征判别

[X_learn,T_learn] = get_feature(weights,layers,network_struct,spike_times_learn,num_img_learn,DoG_params,total_time);
%%对应标签为label_learn
[learn_label] = check_T(T_learn);
learning_correct_rate=correct_rate(label_learn,learn_label);

[X_train,T_train] = get_feature(weights,layers,network_struct,spike_times_train,num_img_train,DoG_params,total_time);
%对应标签为label_train
[train_label] = check_T(T_train);
training_correct_rate=correct_rate(label_train,train_label);

[X_test,T_test] = get_feature(weights,layers,network_struct,spike_times_test,num_img_test,DoG_params,total_time);
%对应标签为label_test
[test_label] = check_T(T_test);
testing_correct_rate=correct_rate(label_test,test_label);

%svm分类
SVM_train=fitcsvm(X_train,label_train);
result_learn=predict(SVM_train,X_learn);
result_train=predict(SVM_train,X_train);
result_test=predict(SVM_train,X_test);
SVM_learning_correct_rate=correct_rate(label_learn,result_learn,num_img_learn);
SVM_training_correct_rate=correct_rate(label_train,result_train,num_img_train);
SVM_testing_correct_rate=correct_rate(label_test,result_test,num_img_test);