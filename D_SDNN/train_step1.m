function [ weights ] = train_step1( weights,layers,network_struct,total_time,learning_layer,st,STDP_per_layer,deta_STDP_minus,deta_STDP_plus,offset)%STDP_per_layer表示每层可以进行STDP学习的最大矩阵数量

%全局变量定义
global STDP_Flag
%global STDP_params
%对网络进行训练
%以及网络中的参数传递过程
%layers由init_layers定义
%weights由init_weights定义
%train_total_time=total_time;%总时间
%layer_for_learn=learning_layer+1;

layers_buff=init_layers(network_struct);

[~,~,~,D]=size(weights{learning_layer});
STDP_Flag=ones(1,D)*STDP_per_layer(learning_layer);%卷积层中的每一小层权值可以发生变化的数量

%用于STDP抑制的矩阵STDP_inh
STDP_inh2=ones(size(layers{2}.S));
STDP_inh4=ones(size(layers{4}.S));
STDP_index=cell(STDP_per_layer(learning_layer),D);
STDP_inh={0,STDP_inh2,0,STDP_inh4};
for t=1:total_time       %按照时间顺序使得网络进行学习

    layers_buff{1}.S=st(:,:,t);%st为输入的脉冲按照时间分布的矩阵
    layers{1}.K_STDP=K_STDP_refresh_1(layers_buff{1}.S,layers{1}.K_STDP,t);%输入层K_STDP矩阵进行更新

    %t-1时刻的值均在layers中，初始情况下均为初始化值
    %t时刻的值根据t-1时刻前一层的值进行
    for i=2:learning_layer    
        V=layers{i}.V;      %膜电位矩阵
       % S=zeros(size(layers{i}.S));     %输出脉冲矩阵
        K_STDP=layers{i}.K_STDP;
        K_inh=layers{i}.K_inh;%侧抑制矩阵
        pad=network_struct{i}.pad; %将s进行周围补零操作，以便于卷积  s的规模为H×W×D
        th=network_struct{i}.th;
        stride=network_struct{i}.stride;
        [ s_pad ]=pad_for_conv( layers_buff{i-1}.S,pad );    %s_pad为对于前一层前一时刻的输出补零得到的值，规模为网络规模边界+补零，有利于之后进行卷积操作
        %根据不同的层调用一些函数
        
        if strcmp( network_struct{i}.Type,'conv' )%该层为卷积层时  
            [V,S,V_buff]=conv_only( s_pad,weights{i},V,layers{i}.S,stride,th);%V_buff为输出脉冲位置对应的膜电压电位，V为神经元膜电位矩阵（发出脉冲部分归零了）
             %卷积层输入为s，从pool或者input，，输出为S，更新一下输出层的K_STDP
             [S,K_inh,K_STDP] = lateral_inh1(V_buff,S,K_inh,K_STDP,t);
             layers_buff{i}.S=S;
        elseif strcmp( network_struct{i}.Type,'pool' )%当该层为池层时
            [S,V_buff] = pool(layers{i}.S,s_pad,weights{i},V,stride,th);
            [S,K_inh,K_STDP] = lateral_inh1(V_buff,S,K_inh,K_STDP,t);
            layers_buff{i}.S=S;
            %pool层作为学习层的输入层，发出脉冲后更新突触前神经元的K_STDP，作为是否发出抑制型STDP的标志。
        end
        layers{i}.S=S;
        layers{i}.V=V;
        layers{i}.K_STDP=K_STDP;       %K_STDP矩阵中存储脉冲发放时间
        layers{i}.K_inh=K_inh;
        
    end
    
    
     %获得进行STDP的矩阵的位置
        if  sum(sum(sum(S)))>0 && sum(STDP_Flag)>0
             [STDP_index,STDP_inh{i}] = get_STDP_idx1(layers{learning_layer}.S,V_buff,STDP_index,STDP_inh{i},offset(i),t);%如果有可以进行STDP的脉冲信号，即可得到对应的索引，以及实现STDP的抑制作用
        end 
end    
    
    %传播完毕，得到了需要进行更新的STDP位置，进行STDP学习 
  [weights] = STDP(layers,learning_layer,STDP_index,weights,network_struct,deta_STDP_minus,deta_STDP_plus);
    
    
    
    
    
%     %STDP  positive negative 进行操作，对于权值进行更新。
%    [ weights{learning_layer},layers{learning_layer-1}.K_STDP,weight_STDP_flag ] =STDP_positive(layers{learning_layer}.S,layers{learning_layer-1}.S,layers{learning_layer-1}.K_STDP,...
%     network_struct{learning_layer}.stride,network_struct{learning_layer}.pad,weight_STDP_flag,weights{learning_layer},deta_STDP_plus);



   
%  %添加了STDP_inh的STDP学习函数
%  [weights{learning_layer},weight_STDP_flag] = STDP_pos(layers{learning_layer}.S,weights{learning_layer},V_buff,layers{learning_layer-1}.K_STDP,...
%   network_struct{learning_layer}.stride,network_struct{learning_layer}.pad,weight_STDP_flag,deta_STDP_plus,offset(learning_layer) );
%  
%  [ weights{learning_layer},layers{learning_layer}.K_STDP,weight_STDP_flag ]=STDP_negative(layers{learning_layer}.S,layers{learning_layer-1}.S,layers{learning_layer}.K_STDP  ,...
%  network_struct{learning_layer}.stride,network_struct{learning_layer}.pad,weight_STDP_flag,weights{learning_layer},deta_STDP_minus) ;

 
  


end

