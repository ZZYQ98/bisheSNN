function [ weights ] = train_step3( weights,layers,layers_buff,network_struct,total_time,learning_layer,st,STDP_per_layer,deta_STDP_minus,deta_STDP_plus,offset)%STDP_per_layer表示每层可以进行STDP学习的最大矩阵数量

%layersbuff{i}.S中存上一时刻该层的发出的脉冲，layer_buff{i-1}通过作用，产生本时刻的输出的脉冲layers{i}.S
%layersbuff{i}.V存放输出脉冲位置的神经元膜电位值
[~,~,Sz]=size(layers{learning_layer}.S);

STDP_counter=0;
STDP_index=cell(Sz,1);%预先分配STDP_index的内存位置。
for i=1:Sz
 STDP_index{i}=[0,0,0,0];
end

%用于STDP抑制的矩阵STDP_inh    用于发生侧抑制与互抑制
STDP_inh2=ones(size(layers{2}.S));
STDP_inh4=ones(size(layers{4}.S));
STDP_inh={0,STDP_inh2,0,STDP_inh4};
for t=1:total_time       %按照时间顺序使得网络进行学习 经过这么长的时间，才能保证所有输入脉冲信息传递过网络
    layers{1}.S=st(:,:,t);%st为输入的脉冲按照时间分布的矩阵
    layers{1}.K_STDP=K_STDP_refresh_1(layers{1}.S,layers{1}.K_STDP,t);%输入层K_STDP矩阵进行更新,表示发出脉冲的时间
    %t-1时刻的值均在layers中，初始情况下均为初始化值
    %t时刻的值根据t-1时刻前一层的值进行
    for i=2:learning_layer    
        w=weights{i};
        V=layers{i}.V;       %上一时刻的膜电位值
        s=layers_buff{i-1}.S;%上一时刻，上一层的输出
        K_inh=layers{i}.K_inh;
        K_STDP=layers{i}.K_STDP;
        pad=network_struct{i}.pad; %将s进行周围补零操作，以便于卷积  s的规模为H×W×D
        th=network_struct{i}.th;
        stride=network_struct{i}.stride;
        [ s_pad ]=pad_for_conv( s,pad );    %t-1时刻的前一层的输出脉冲 补零
        %s_pad为对于前一层前一时刻的输出补零得到的值，规模为网络规模边界+补零，有利于之后进行卷积操作
        %根据不同的层调用一些函数
        
        if strcmp( network_struct{i}.Type,'conv' )%该层为卷积层时  
            [ V_out , S_out ]=conv_only( s_pad, w, V ,stride,th);%V_out中包含了输出脉冲位置对应的膜电压电位
             %卷积层输入为s，从pool或者input，，输出为S，更新一下输出层的K_STDP
             [S_out_inh ,K_inh_out, K_STDP_out] = lateral_inh1( V_out , S_out , K_inh, K_STDP,t);
        elseif strcmp( network_struct{i}.Type,'pool' )%当该层为池层时
            [S_out] = pool(layers{i}.S,s_pad,weights{i},stride,th);
            [S_out_inh ,K_inh_out, K_STDP_out] = lateral_inh1(layers{i}.V, S_out, K_inh, K_STDP,t);
            %pool层作为学习层的输入层，发出脉冲后更新突触前神经元的K_STDP，作为是否发出抑制型STDP的标志。
        end
        %传播结束后，存在一个将buff中的值更新的过程，满足下一时刻传播
        layers{i}.V=V_out; %更新为本时刻的膜电位
        layers{i}.K_STDP=K_STDP_out;
        layers{i}.K_inh=K_inh_out;
        layers{i}.S=S_out_inh;%通过上一时刻上一层的输入得到本时刻的输出
    end
    for j=1:learning_layer
        layers_buff{j}.S=layers{j}.S;
    end 
    
    %STDP_inh为对应的STDP
valid=double(S_out_inh.*V_out.*STDP_inh{learning_layer});%可以进行STDP的神经元 
 %获得进行STDP的矩阵的位置
     if  sum(sum(sum(valid)))>0 && STDP_counter<STDP_per_layer(learning_layer)
         [STDP_index,STDP_counter] = get_STDP_idx3(valid,STDP_index,STDP_counter,offset(learning_layer),STDP_per_layer(learning_layer),t);
         [STDP_inh{learning_layer}] = STDP_inh1(valid,STDP_inh{learning_layer},STDP_index,offset(learning_layer));
         %如果有可以进行STDP的脉冲信号，即可得到对应的索引，以及实现STDP的抑制作用
     end 
     

end    
    
    %传播完毕，得到了需要进行更新的STDP位置，进行STDP学习 
  [weights] = STDP(layers,learning_layer,STDP_index,weights,network_struct,deta_STDP_minus,deta_STDP_plus);

end

