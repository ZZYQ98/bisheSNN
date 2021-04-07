function [X] = get_feature(weights,layers,network_struct,spike_times,num_img,DoG_params,total_time)
global DoG
%获得一个N*M的矩阵，N为训练的样本数，M为最后一层的层数，即每一列保存训练结果
[~,num_layers]=size(network_struct);
layers_buff=init_layers(network_struct);%流水线结构
curr_img=0;
n=3;
filt=DOG_creat(DoG_params);
[~,~,n_featuers]=size(layers{num_layers}.V);
X=zeros(num_layers,n_featuers);


network_struct{4}.th=1000000;
       
       
       fprintf('-------------------------------------------------------------\n')
       fprintf('--------------EXTRACTING TRAINING FEATURES-------------------\n')
       fprintf('-------------------------------------------------------------\n')
       for ii=1:num_img
           perc=ii/num_img;
            fprintf('---------------------TRAINING PROGRESS %2.3f----------------- \n',perc)
            %reset layers
            reset_layers(layers,num_layers);
            reset_layers(layers_buff,num_layers);
           if DoG   % 是否进行DoG获得输入脉冲矩阵st
             path_img=spike_times{n};
              if n<num_img
                  n=n+1;
              else
                  n=3;
              end    
                 st=DoG_filter_to_st(path_img,filt,DoG_params.img_size,total_time);%  st = spike_time 输入脉冲时间
           else
                 st=spike_times(curr_img,:,:,:,:);  %此处的spike_times_learn是来自于读取的数据，而不用滤波得到
                 if curr_img+1<num_img
                   curr_img=curr_img+1;
                 else
                  curr_img=0;
                 end
           end
       
            %脉冲传播过程
            for t=1:total_time+num_layers       %按照时间顺序使得网络进行学习 经过这么长的时间，才能保证所有输入脉冲信息传递过网络
              if t<=total_time
                layers{1}.S=st(:,:,t);%st为输入的脉冲按照时间分布的矩阵
                layers{1}.K_STDP=K_STDP_refresh_1(layers{1}.S,layers{1}.K_STDP,t);%输入层K_STDP矩阵进行更新
              end
                %t-1时刻的值均在layers中，初始情况下均为初始化值
                %t时刻的值根据t-1时刻前一层的值进行
                for i=2:num_layers    
                    w=weights{i};
                    V=layers{i}.V;
                    s=layers_buff{i-1}.S;
                    K_inh=layers{i}.K_inh;
                    K_STDP=layers{i}.K_STDP;
                    pad=network_struct{i}.pad; %将s进行周围补零操作，以便于卷积  s的规模为H×W×D
                    th=network_struct{i}.th;
                    stride=network_struct{i}.stride;
                    [ s_pad ]=pad_for_conv( s,pad );    %t-1时刻的前一层的输出脉冲
                    %s_pad为对于前一层前一时刻的输出补零得到的值，规模为网络规模边界+补零，有利于之后进行卷积操作
                    %根据不同的层调用一些函数

                    if strcmp( network_struct{i}.Type,'conv' )%该层为卷积层时  
                        [ V_out , S_out ]=conv_only( s_pad, w, V ,stride,th);%V_out中包含了输出脉冲位置对应的膜电压电位,用于get_STDP_index中找到发生STDP学习的神经元位置
                         %卷积层输入为s，从pool或者input，，输出为S，更新一下输出层的K_STDP
                         [S_out_inh ,K_inh_out, K_STDP_out] = lateral_inh1( V_out , S_out , K_inh, K_STDP,t);
                    elseif strcmp( network_struct{i}.Type,'pool' )%当该层为池层时
                        [S_out] = pool(layers{i}.S,s_pad,weights{i},stride,th);
                        [S_out_inh ,K_inh_out, K_STDP_out] = lateral_inh1(layers{i}.V, S_out, K_inh, K_STDP,t);
                        %pool层作为学习层的输入层，发出脉冲后更新突触前神经元的K_STDP，作为是否发出抑制型STDP的标志。
                    end
                    %传播结束后，存在一个将buff中的值更新的过程，满足下一时刻传播
                    layers{i}.V=V_out;
                    layers{i}.K_STDP=K_STDP_out;
                    layers{i}.K_inh=K_inh_out;
                    layers{i}.S=S_out_inh;
                end
                for j=1:num_layers
                    layers_buff{j}.S=layers{j}.S;
                end 
            end
        % Obtain maximum potential per map in last layer      
        features=layers{num_layers-1}.V;%最后一层V的值是一个1*1*D的三维矩阵
        features1=max(features,[],1);
        features=max(features1,[],2);
        T=layers{num_layers-1}.K_STDP;
        X(ii,:)=features;%将行向量结合
       end

       fprintf('---------------------TRAINING PROGRESS %2.3f----------------- \n',num_img/num_img)
       fprintf('-------------------------------------------------------------')
       fprintf('---------------TRAINING FEATURES EXTRACTED-------------------')
       fprintf('-------------------------------------------------------------\n')

end

