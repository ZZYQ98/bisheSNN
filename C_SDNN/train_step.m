function [  ] = train_step( network_struct,total_time,learning_layer,st)%STDP_per_layer表示每层可以进行STDP学习的最大矩阵数量

%全局变量定义
global weights
global layers
global STDP_counter
global STDP_Flag_p
global STDP_Flag_n
% global STDP_time_pre %STDP作用时间
% global STDP_time_post
STDP_counter=0;
global weight_STDP_flag
global STDP_per_layer
%global STDP_params
%对网络进行训练
%以及网络中的参数传递过程
%layers由init_layers定义
%weights由init_weights定义
%train_total_time=total_time;%总时间
%layer_for_learn=learning_layer+1;

%创建一个STDP权值更新标志寄存器，在学习过程中某些权值未发生STDP，也无输入或输出脉冲，则发生退化，则标志位对应的权值发生减小
weight_STDP_flag=ones(size(weights{learning_layer}));

[~,~,D]=size(weights{learning_layer});
STDP_Flag_p=ones(1,D)*STDP_per_layer(learning_layer);%卷积层中的每一小层权值可以发生变化的数量
STDP_Flag_n=ones(1,D)*STDP_per_layer(learning_layer);

for t=1:total_time       %按照时间顺序使得网络进行学习
    %时间增加，STDP学习影响降低
    for L=1:learning_layer
        layers{L}.K_STDP=layers{L}.K_STDP-1;
    end
    reset_layers_spike(learning_layer); %新的一个时刻，需要将所有的脉冲矩阵清空，从而进行新的传播
    
    
    layers{1}.S=st(:,:,t);%st为输入的脉冲按照时间分布的矩阵
    K_STDP_refresh_1();%输入层K_STDP矩阵进行更新

    
    for i=2:learning_layer    %
        s=layers{i-1}.S;%本层的输入脉冲=上一层输出脉冲
        pad=network_struct{i}.pad; %将s进行周围补零操作，以便于卷积  s的规模为H×W×D
        [ s_pad ]=pad_for_conv( s,pad );    %s为对于前一层的输出补零得到的值，规模为网络规模边界+补零，有利于之后进行卷积操作
        %根据不同的层调用一些函数
        if strcmp( network_struct{i}.Type,'conv' )%该层为卷积层时  
            conv_step5(i,s_pad,network_struct{i}.stride,network_struct{i}.th);
             %卷积层输入为s，从pool或者input，，输出为S，更新一下输出层的K_STDP
        elseif strcmp( network_struct{i}.Type,'pool' )%当该层为池层时
            pooling1(i,s_pad,network_struct{i}.stride,network_struct{i}.th);
            %pool层作为学习层的输入层，发出脉冲后更新突触前神经元的K_STDP，作为是否发出抑制型STDP的标志。
        end
    end
    
    %传播完毕，进行STDP学习 
    %STDP  positive negative 进行操作，对于权值进行更新。
    STDP_positive(layers{learning_layer}.S,layers{learning_layer-1}.S,layers{learning_layer-1}.K_STDP,learning_layer,network_struct{learning_layer}.stride,network_struct{learning_layer}.pad);
    STDP_negative(layers{learning_layer}.S,layers{learning_layer-1}.S,layers{learning_layer}.K_STDP  ,learning_layer,network_struct{learning_layer}.stride,network_struct{learning_layer}.pad) ;
    STDP_inactive(learning_layer);
   % weight_range(learning_layer);
    %对矩阵进行更新操作
    weight_STDP_flag=weight_STDP_flag-1;
   if sum(STDP_Flag_p)+sum(STDP_Flag_n)==0       %判定当层的学习是否已经结束
      continue 
   end
end
 
end

