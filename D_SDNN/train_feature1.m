function [X_train] = train_feature1(weights,layers,network_struct,spike_times_train,DoG_params,num_img_learn,total_time)
global DoG
[~,num_layers]=size(network_struct);
curr_img=0;
n=3;
filt=DOG_creat1(DoG_params);
featrues_in_train=[];
%  X_train: Training features of size (N, M) where N is the number of training samples and M is the number of maps in the last layer
       network_struct{3}.th=100000; % Set threshold of last layer to inf         先对层3进行train
       fprintf('-------------------------------------------------------------\n')
       fprintf('--------------EXTRACTING TRAINING FEATURES-------------------\n')
       fprintf('-------------------------------------------------------------\n')
       for ii=1:num_img_train
           perc=ii/num_img_train;
            fprintf('---------------------TRAINING PROGRESS %2.3f----------------- \n',perc)
            %reset layers
            reset_layers(num_layers);
            
           if DoG   % 是否进行DoG获得输入脉冲矩阵st
             path_img=spike_times_train{n};
              if n<num_img_train
                  n=n+1;
              else
                  n=3;
              end    
                 st=DoG_filter_to_st(path_img,filt,DoG_params.img_size,total_time);%  st = spike_time 输入脉冲时间
           else
                 st=spike_times_train(curr_img,:,:,:,:);  %此处的spike_times_learn是来自于读取的数据，而不用滤波得到
                 if curr_img+1<num_img_learn
                   curr_img=curr_img+1;
                 else
                  curr_img=0;
                 end
           end
          %脉冲传播过程
        for t=1:total_time+num_layers      %按照时间顺序使得网络进行学习

            layers{1}.S=st(:,:,t);%st为输入的脉冲按照时间分布的矩阵
            layers{1}.K_STDP=K_STDP_refresh_1(layers{1}.S,layers{1}.K_STDP,t);%输入层K_STDP矩阵进行更新

            %t-1时刻的值均在layers中，初始情况下均为初始化值
            %t时刻的值根据t-1时刻前一层的值进行
            for i=2:learning_layer    
                V=layers{i}.V;      %膜电位矩阵
                S=layers{i}.S;      %输出脉冲矩阵
                K_STDP=layers{i}.K_STDP;
                K_inh=layers{i}.K_inh;%侧抑制矩阵
                pad=network_struct{i}.pad; %将s进行周围补零操作，以便于卷积  s的规模为H×W×D
                th=network_struct{i}.th;
                stride=network_struct{i}.stride;
                [ s_pad ]=pad_for_conv( layers{i-1}.S,pad );    %s_pad为对于前一层前一时刻的输出补零得到的值，规模为网络规模边界+补零，有利于之后进行卷积操作
                %根据不同的层调用一些函数

                if strcmp( network_struct{i}.Type,'conv' )%该层为卷积层时  
                    [V,S,V_buff]=conv_only( s_pad,weights{i},V,layers{i}.S,stride,th);%V_buff为输出脉冲位置对应的膜电压电位
                     %卷积层输入为s，从pool或者input，，输出为S，更新一下输出层的K_STDP
                     [S,K_inh,K_STDP] = lateral_inh1(V_buff,S,K_inh,K_STDP,t);
                elseif strcmp( network_struct{i}.Type,'pool' )%当该层为池层时
                    [S,V_buff] = pool(layers{i}.S,s_pad,weights{i},V,stride,th);
                    [S,K_inh,K_STDP] = lateral_inh1(V_buff,S,K_inh,K_STDP,t);
                    %pool层作为学习层的输入层，发出脉冲后更新突触前神经元的K_STDP，作为是否发出抑制型STDP的标志。
                end
                layers{i}.S=S;
                layers{i}.V=V;
                layers{i}.K_STDP=K_STDP;       %K_STDP矩阵中存储脉冲发放时间
                layers{i}.K_inh=K_inh;
            end
        end    
        
        % Obtain maximum potential per map in last layer      
        per_features_train=layers{num_layers}.V;%最后一层V的值是一个1*1*D的三维矩阵
        [~,n_features]=size(sp_time);
        featrues_in_train=[featrues_in_train,per_features_train];%将行向量结合
       end
       X_train=reshape(featrues_in_train,[num_img_train,n_features]);  %将特征转化为矩阵形式
       fprintf('---------------------TRAINING PROGRESS %2.3f----------------- \n',num_img_train/num_img_train)
       fprintf('-------------------------------------------------------------')
       fprintf('---------------TRAINING FEATURES EXTRACTED-------------------')
       fprintf('-------------------------------------------------------------')

end

