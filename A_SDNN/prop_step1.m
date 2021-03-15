function [] = prop_step1(st)
global network_struct
global layers
global total_time

%目前没加侧抑制矩阵
for t=1:total_time
    layers{1}.S=st(:,:,t);
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
    
end

end

