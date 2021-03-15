function [  ] = train_step( network_struct,total_time,learning_layer,st)%STDP_per_layer表示每层可以进行STDP学习的最大矩阵数量

%全局变量定义
global weights
global layers
global STDP_counter
% global STDP_time_pre %STDP作用时间
% global STDP_time_post
STDP_counter=0;
%global STDP_params
%对网络进行训练
%以及网络中的参数传递过程
%layers由init_layers定义
%weights由init_weights定义
%train_total_time=total_time;%总时间
%layer_for_learn=learning_layer+1;

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
%         H=network_struct{i}.shape.H_layer;
%         W=network_struct{i}.shape.W_layer;
%         D=network_struct{i}.shape.num_filters;
%         pad=network_struct{i}.pad;
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
           %[layers{i}.V,layers{i}.S,layers{i}.K_STDP]=conv_step_without_inh(S,V,s_pad,w,stride,th,K_STDP);%卷积操作，对膜电位矩阵更新，达到阈值发出脉冲，不考虑侧抑制
           conv_step3( i,s_pad,stride,th,pad);
          %conv_step2( layers{i}.S,layers{i}.V,s_pad,weights{i},stride,th,layers{i}.K_STDP,layers{i}.K_inh);
          %[layers{i}.V,layers{i}.S,layers{i}.K_STDP,layers{i}.K_inh] = conv_step2( layers{i}.S,layers{i}.V,s_pad,weights{i},stride,th,layers{i}.K_STDP,layers{i}.K_inh) ;%侧抑制矩阵起作用
        elseif strcmp( network_struct{i}.Type,'pool' )%当该层为池层时
            %pooling_inh=layers{i}.pooling_inh; %之后再调试，这种情况下对应池化只会发送一次脉冲
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

    
    
%     
%     %STDP_learning
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %以下对stdp的学习过程进行描述
%         lay=learning_layer;  %layerning_layer由上层函数定义，ltl：layer to learn
%         if strcmp( network_struct{lay}.Type,'conv' )
%             S=layers{lay}.S;%输出脉冲矩阵               输出脉冲矩阵加上查看K_inh可以得到可以进行STDP的神经元对应的
%             V=layers{lay}.V;%更新结束后的膜电位值
%             K_STDP=layers{lay}.K_STDP;
%             S=double(S);
%             K_STDP=double(K_STDP);
%             valid=S.*V.*K_STDP;%valid是学习层中可以进行stdp且在t时刻发射脉冲的
%             if sum(sum(sum(valid)))>0
%                 H=network_struct{lay}.shape.H_layer;
%                 W=network_struct{lay}.shape.W_layer;
%                 D=network_struct{lay}.shape.num_filters;
%                 stride=network_struct{lay}.stride;
%                 offset=STDP_params.offset_STDP(lay);
%                 a_minus=STDP_params.a_minus;
%                 a_plus=STDP_params.a_plus;
%                 
%                 s=layers{lay-1}.S;
%                 ssum=sum(s,4);
%                 s=pad_for_conv( ssum,pad );%定义函数 pad_for_conv在外围补零
%                 w=weights{lay};
%              % [maxval,maxind1,maxind2]=get_STDP_idxs(valid,H,W,D,lay,STDP_per_layer,offset_STDP);%---------函数未调试
%             
%         
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            %基于CPU的学习方法
%            %调用STDP学习函数
%            S_sz=size(S);
%            [w,K_STDP_out]=STDP(S_sz,s,w,K_STDP,maxval,maxind1,maxind2,stride,offset,a_minus,a_plus);%函数未调试
%            %S_sz为脉冲矩阵的大小
%            weights{i}=w;
%            layers{learning_layer}.K_STDP=K_STDP_out;
%            end
%         end
end
 
end

