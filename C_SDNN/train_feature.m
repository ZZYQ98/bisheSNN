function [X_train] = train_feature(num_img_train)
global network_struct
global num_layers
global DoG
global layers
global img_size
global DoG_params
global spike_times_train
global total_time
curr_img=0;
n=3;
filt=DOG_creat1(DoG_params);
featrues_in_train=[];
%  X_train: Training features of size (N, M) where N is the number of training samples and M is the number of maps in the last layer
       network_struct{5}.th=100000; % Set threshold of last layer to inf
       fprintf('-------------------------------------------------------------\n')
       fprintf('--------------EXTRACTING TRAINING FEATURES-------------------\n')
       fprintf('-------------------------------------------------------------\n')
       for i=1:num_img_train
           perc=i/num_img_train;
            fprintf('---------------------TRAINING PROGRESS %2.3f----------------- \n',perc)
            %reset layers
            reset_layers(num_layers);
            
           if DoG       % �Ƿ����DoG��������������st
             path_img=spike_times_train{n};
              if n<num_img_train
                  n=n+1;
              else
                  n=3;
              end    
                 st=DoG_filter_to_st(path_img,filt,img_size,total_time);%  st = spike_time ��������ʱ��
           else
                 st=spike_times_train(curr_img,:,:,:,:);  %�˴���spike_times_learn�������ڶ�ȡ�����ݣ��������˲��õ�
             if curr_img+1<num_img_learn
                 curr_img=curr_img+1;
               else
                 curr_img=0;
             end
           end
          sp_time=prop_step(st);
          % Obtain maximum potential per map in last layer      
        %features_train=layers{num_layers}.V;%���һ��V��ֵ��һ��1*1*D����ά����
        [~,n_features]=size(sp_time);
        featrues_in_train=[featrues_in_train,sp_time];%�����������
       end
       X_train=reshape(featrues_in_train,[num_img_train,n_features]);  %������ת��Ϊ������ʽ
       fprintf('---------------------TRAINING PROGRESS %2.3f----------------- \n',num_img_train/num_img_train)
       fprintf('-------------------------------------------------------------')
       fprintf('---------------TRAINING FEATURES EXTRACTED-------------------')
       fprintf('-------------------------------------------------------------')

end

