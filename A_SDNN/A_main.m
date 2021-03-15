%SDNN��������  main����
%���������������
clc
clear

%����ͼƬ·��
global spike_times_train
global spike_times_learn
path_list='D:\SDNN_files\learn';
spike_times_to_learn='D:\MATLABfiles\MINST';
spike_times_to_train='D:\MATLABfiles\MINST';
spike_times_to_test='D:\SDNN_files\test';
path_set_weights='D:\SDNN_files\set_weight';
%����洢·��
path_save_weights='D:\SDNN_files\set_weights';
path_features='D:\SDNN_files\features';
%����FLAG
global learn_SDNN
global set_weights
global save_weights
global save_feature
global DoG
%��־λ����
learn_SDNN=1;   %��������ѧϰ��־λ��learn_SDNN����1ʱ���������STDPѧϰ����learn_SDNN����0ʱ�����粻����ѧϰ��ֱ�Ӷ�ȡ�Ѿ��õ���Ȩֵ���ݣ����в���
%���ȿ������Ƿ����ѵ��      
if  learn_SDNN==1                  
    set_weights=0;         %ѵ��ʱ��������Ȩֵ��������Ȩֵ��ʼ��
    save_weights=1;         %����ѵ��������Ȩֵ��Ϣ��·����Ϣ
    save_feature=1;
else                       %��ѵ��ʱ������Ȩֵ��
    set_weights=1;
    save_weights=0;
    save_feature=0;
end

DoG=1;            %����DoG�˲���־λ��DoG����1ʱ������ͼ������˲��õ����巢��ʱ�䣬��DoG����0ʱ�����ļ��ж�ȡ���巢��ʱ�� 

%SDNN������������������������������������������������������������������������
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
global STDP_time_pre %STDP����ʱ��
global STDP_time_post
global network_struct
global STDP_params
global DoG_params
global total_time
img_size=struct('img_sizeH',28,'img_sizeW',28);%����ͼ���ģ
DoG_params=struct('img_size', img_size, 'DoG_size', 5, 'std1', 1, 'std2', 2);%����DoG����
%�����������
l1=struct('type','input', 'num_filters', 1, 'pad',0, 'H_layer',DoG_params.img_size.img_sizeH,'W_layer', DoG_params.img_size.img_sizeW);
l2=struct('type', 'conv', 'num_filters', 4, 'filter_size', 3, 'th', 1.5);
l3=struct('type', 'pool', 'num_filters', 1, 'filter_size', 5, 'th', 0., 'stride', 3);
l4=struct('type', 'conv', 'num_filters',10, 'filter_size', 7, 'th', 3);
l5=struct('type', 'pool', 'num_filters',1, 'filter_size', 5, 'th', 0, 'stride',2);
l6=struct('type', 'conv', 'num_filters',8, 'filter_size', 3, 'th', 2);
learnable_layers=[2,4,6];
network_params={l1,l2,l3,l4,l5,l6};
weight_params=struct('mean',0.8,'std',0.05);%����Ȩֵ��ʼ������
max_learn_iter=[0,300,0,400,0,500,0];
STDP_per_layer=[0,10,0,4,0,2];
max_iter=sum(max_learn_iter);
a_minus=[0,0.003,0,0.003,0,0.003];
a_plus=[0,0.004,0,0.004,0,0.004];
offset_STDP=[0,floor(network_params{2}.filter_size),0,floor(network_params{4}.filter_size/8),0,floor(network_params{6}.filter_size)];
STDP_params=struct('max_learning_iter',max_learn_iter,'STDP_per_layer',STDP_per_layer,...
                   'max_iter',max_iter,'a_minus',a_minus,'a_plus',a_plus,'offset_STDP',offset_STDP);
total_time=100;
STDP_time=10;%���ڶ���K_STDP��־����
STDP_time_pre=10;
STDP_time_post=8;
%-------------------------------------�������������������SDNN_net----------------------------------------------------
%����ṹ��ʼ��
[~,num_layers]=size(network_params);
network_struct=init_net_struct(network_params);%���ú���network_struct���������ò�������������г�ʼ��
%network_structΪ����ṹ�壬learnable_layersΪ�ɽ���ѧϰ�ľ����

layers = init_layers(network_struct);%���ú���init_layers�������в�ĳ�ʼ��

%Ȩֵ�����ʼ��
[weights]= init_weights( weight_params,network_struct);%���ú���init_weight��������������Ȩֵ���󣬲���Ҫ���ʼ��Ȩֵ
%weightsΪ��ʼ����Ȩֵ����W_shapeΪȨֵ����ĳߴ�

%check_dimensions( network_struct,W_shape )%����õ�Ȩֵ����ά��������ά���Ƿ���ͬ�������������򷵻ض�Ӧ�Ĵ���ԭ��

%���������������������������������������������Ƿ񾭹��˲��õ�������������������������������������������������������������������������
% 
if DoG==1
     [spike_times_learn,y_learn]=gen_iter_path(spike_times_to_learn);%��ͼƬ���룬����Ҫ�����˲�
     [spike_times_train,y_train]=gen_iter_path(spike_times_to_train);
%     [spike_times_text,y_test]=gen_iter_path(spike_times_to_test);
     [num_img_learn,~]=size(y_learn);
     [num_img_train,~]=size(y_train);
%     [num_img_test,~]=size(y_test);
 else
     spike_times_learn=spike_times_to_learn;       %�������˲���ֱ�ӽ�����ʱ������,��Щ��������ʱ�������Ϊ֮ǰ�õ��ģ��������ļ���
     [num_img_learn,~]=size(spike_times_learn);
     spike_times_train=spike_times_to_train;
     [num_img_train,~]=size(spike_times_train);
%     spike_times_test=spike_times_to_test;
%     [num_img_,~]=size(spike_times_texst);
 end       

%------------------------------------ѵ���õ����-----------------------------------------------------------------------
features_train=[];
features_text=[];

%����Ȩֵ���߽���STDPѧϰ
if set_weights==1
    weights_buff=load(weights_path_list);  %�����ļ��������Ȩֵ����ֵ��buffer
    weights=weights_buff.weights;
else
    learn_buffer=spike_times_learn;
    train_SDNN(network_struct,total_time,spike_times_learn,DoG_params,num_img_learn);
end
%Ȩֵ�洢
if save_weights==1
    save('weights','weights');
end
%----------------------------------�����б����������--------------------------------------------------------------------
% %�����б�
%[X_train] = train_feature(num_img_train);
% [X_text,y_text]=test_feature();%------------������δ����


%����X_train X_test
%����x_train,y_train,x_text,y_text







% %---------------------------------������------------------------------------------------------------------------
% calssfier_params=struct('C',1,'gamma','auto');
% train_mean=mean(X_train,1);
% train_std=std(X_train,1);
% X_train=X_train-train_mean;
% X_test=X_test-train_mean;
% X_train=X_train/(train_std+1e-5);
% X_test=X_test/(train_std+1e-5);
% 
% %���÷����� classfier
% 









