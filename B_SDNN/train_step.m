function [  ] = train_step( network_struct,total_time,learning_layer,st)%STDP_per_layer表示每层可以进行STDP学习的最大矩阵数量

%全局变量定义
global weights
global layers
global STDP_counter
% global STDP_time_pre %STDP作用时间
% global STDP_time_post
STDP_counter=0;
global weight_STDP_flag
%global STDP_params
%对网络进行训练
%以及网络中的参数传递过程
%layers由init_layers定义
%weights由init_weights定义
%train_total_time=total_time;%总时间
%layer_for_learn=learning_layer+1;

%创建一个STDP权值更新标志寄存器，如在一定时间内某些权值未发生STDP，也无输入或输出脉冲，则发生退化，则标志位对应的权值发生减小，减小幅度为a_minus
weight_STDP_flag=ones(size(weights(learning_layer)))*30;
[H,W,D]=size(weights(learning_layer));
for t=1:total_time       %按照时间顺序使得网络进行学习
    %时间增加，STDP学习影响降低
    for L=1:learning_layer
        layers{L}.K_STDP=layers{L}.K_STDP-1;
    end
    reset_layers_spike(learning_layer); %新的一个时刻，需要将所有的脉冲矩阵清空，从而进行新的传播
    
    layers{1}.S=st(:,:,t);%st为输入的脉冲按照时间分布的矩阵
    layers{1}.K_STDP=K_STDP_refresh_pre(layers{1}.S,layers{1}.K_STDP);%输入层K_STDP矩阵进行更新

    
%     K_STDP_post=layers{learning_layer}.K_STDP;
%     K_STDP_pre=layers{learning_layer-1}.K_STDP;
    
    for i=2:learning_layer    %
        stride=network_struct{i}.stride;%步长
        th=network_struct{i}.th;%阈值
        w=weights{i};%权值矩阵
        s=layers{i-1}.S;%本层的输入脉冲=上一层输出脉冲
        pad=network_struct{i}.pad; %将s进行周围补零操作，以便于卷积  s的规模为H×W×D
        [ s_pad ]=pad_for_conv( s,pad );    %s为对于前一层的输出补零得到的值，规模为网络规模边界+补零，有利于之后进行卷积操作
        
        %根据不同的层调用一些函数
        if strcmp( network_struct{i}.Type,'conv' )%该层为卷积层时
            
            %卷积层输入为s，从pool或者input，更新一下输入层的K_STDP
           layers{i-1}.K_STDP=K_STDP_update(s,layers{i-1}.K_STDP);%用与进行增强型STDP
           
           conv_step3( i,s_pad,stride,th,pad);
       
        elseif strcmp( network_struct{i}.Type,'pool' )%当该层为池层时
            pooling1(i,s_pad,w,stride,th);
            layers{i}.K_STDP=K_STDP_refresh_pre(layers{i}.S,layers{i}.K_STDP);%pool层作为学习层的输入层，发出脉冲后更新突触前神经元的K_STDP，作为是否发出抑制型STDP的标志。
        end
    end
    check_Spike=sum(sum(sum(layers{learning_layer-1}.S)));%观察此时刻有无脉冲输出
    %传播完毕，进行STDP学习
    if check_Spike
    STDP1(layers{learning_layer}.S,layers{learning_layer-1}.S,layers{learning_layer-1}.K_STDP,...
    layers{learning_layer}.K_STDP,learning_layer,network_struct{learning_layer}.stride,network_struct{learning_layer}.pad);
    end
    
    for k=1:D
        for i=1:H
            for j=1:W
                if weight_STDP_flag(i,j,k)==0
                    weights(i,j,k)=weights(i,j,k)-a_minus(learning_layer);
                    if weights(i,j,k)<1e-6
                        weights(i,j,k)=1e-6;
                    end
                end
            end
        end
    end
    %对矩阵进行更新操作
    weight_STDP_flag=weight_STDP_flag-1;

end
 
end

