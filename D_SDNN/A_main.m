%SDNN��������  main����4.13
%���������������
clc
clear

%����ͼƬ·��
path_list='D:\git_code\D_SDNN\dataset_new';
spike_times_to_learn=[path_list,'\LearningSet'];
spike_times_to_train=[path_list,'\TrainingSet'];
spike_times_to_test=[path_list,'\TestingSet'];
path_set_weights='D:\git code\bisheSNN\set_weight';
%����洢·��
path_save_weights='D:\git code\bisheSNN\set_weights';
path_features='D:\git code\bisheSNN\features';
%����FLAG
global learn_SDNN
global set_weights
global save_weights
global save_feature
global DoG
%��־λ����
learn_SDNN=0;   %��������ѧϰ��־λ��learn_SDNN����1ʱ���������STDPѧϰ����learn_SDNN����0ʱ�����粻����ѧϰ��ֱ�Ӷ�ȡ�Ѿ��õ���Ȩֵ���ݣ����в���
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
img_size=struct('img_sizeH',160,'img_sizeW',160);%����ͼ���ģ
DoG_params=struct('img_size', img_size, 'DoG_size', 7, 'std1', 1, 'std2', 2);%����DoG����
%�����������
l1=struct('type','input', 'num_filters', 1, 'pad',0, 'H_layer',DoG_params.img_size.img_sizeH,'W_layer', DoG_params.img_size.img_sizeW);
l2=struct('type', 'conv', 'num_filters', 4, 'filter_size', 5, 'th', 6);
l3=struct('type', 'pool', 'num_filters', 4, 'filter_size', 17, 'th', 0., 'stride', 16);
l4=struct('type', 'conv', 'num_filters',10, 'filter_size', 15, 'th', 27);
l5=struct('type', 'pool', 'num_filters',10, 'filter_size',10, 'th', 0., 'stride', 1);
learnable_layers=[2,4];
network_params={l1,l2,l3,l4,l5};
weight_params=struct('mean',0.8,'std',0.01);%����Ȩֵ��ʼ������ 
max_learn_iter=[0,500,0,700,0];
STDP_per_layer=[0,4,0,1,0];
max_iter=sum(max_learn_iter);
a_minus=[0,0.003,0,0.003];
a_plus=[0,0.005,0,0.005];
offset=[0 5 0 0];
%���STDPȨֵ���¾���
tao_minus=40;
tao_plus=20;
STDP_time_pre=35;%��ǿ��STDP ����ʱ��
STDP_time_post=35;%������STDP ����ʱ��
deta_STDP_minus=deta_STDP(0.03,STDP_time_post,tao_minus);  %���ô�����ΪSTDP_time_minus=40��ʱ����Ϊ40
deta_STDP_plus=deta_STDP(0.07,STDP_time_pre,tao_plus);    %���ô�����ΪSTDP_time_plus=30��ʱ����Ϊ20


STDP_params=struct('max_learning_iter',max_learn_iter,'STDP_per_layer',STDP_per_layer,...
                   'max_iter',max_iter,'a_minus',a_minus,'a_plus',a_plus,'offset',offset);
total_time=30;
STDP_time=10;%���ڶ���K_STDP��־����

%-------------------------------------�������������������SDNN_net----------------------------------------------------
%����ṹ��ʼ��
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
     [spike_times_learn,label_learn]=get_iter_path1(spike_times_to_learn);%��ͼƬ���룬����Ҫ�����˲�
     [spike_times_train,label_train]=get_iter_path1(spike_times_to_train);
     [spike_times_test,label_test]=get_iter_path1(spike_times_to_test);
     [~,num_img_learn]=size(spike_times_learn);
     [~,num_img_train]=size(spike_times_learn);
     [~,num_img_test]=size(spike_times_test);
 else
     spike_times_learn=spike_times_to_learn;       %�������˲���ֱ�ӽ�����ʱ������,��Щ��������ʱ�������Ϊ֮ǰ�õ��ģ��������ļ���
     [~,num_img_learn]=size(spike_times_learn);
     spike_times_train=spike_times_to_train;
     [~,num_img_train]=size(spike_times_train);
     spike_times_test=spike_times_to_test;
     [num_img_,~]=size(spike_times_texst);
 end       

% %------------------------------------ѵ���õ����-----------------------------------------------------------------------
features_train=[];
features_text=[];

weights_path_list='weights_4_1_total.mat';
%����Ȩֵ���߽���STDPѧϰ
if set_weights==1
    weights_buff=load(weights_path_list);  %�����ļ��������Ȩֵ����ֵ��buffer
    weights=weights_buff.weights;
else
    learn_buffer=spike_times_learn;
    weights=train_SDNN(weights,layers,network_struct,spike_times_learn,DoG_params,STDP_params,num_img_learn,learnable_layers,learn_buffer,total_time,deta_STDP_minus,deta_STDP_plus);
end
%Ȩֵ�洢
if save_weights==1
    save('weights','weights');
end
%----------------------------------�����б����������--------------------------------------------------------------------
% %�����б�

X_learn = get_feature(weights,layers,network_struct,spike_times_learn,num_img_learn,DoG_params,total_time);
%%��Ӧ��ǩΪlabel_learn

X_train = get_feature(weights,layers,network_struct,spike_times_train,num_img_train,DoG_params,total_time);
%��Ӧ��ǩΪlabel_train

X_test = get_feature(weights,layers,network_struct,spike_times_test,num_img_test,DoG_params,total_time);
%��Ӧ��ǩΪlabel_test

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









