for t=1:total_time       %按照时间顺序使得网络进行学习
    %时间增加，STDP学习影响降低
    for L=1:learning_layer
        layers{L}.K_STDP=layers{L}.K_STDP-1;%每一时刻开始K_STDP矩阵减一，即窗口期的作用随时间减小
        layers{L}.S=uint8(zeros(size(layers{L}.S)));%每一时刻开始将脉冲矩阵清零，以便下一时刻的脉冲进行传播
    end
    
    layers{1}.S=st(:,:,t);%st为输入的脉冲按照时间分布的矩阵
    layers{1}.K_STDP=K_STDP_refresh_1(layers{1}.S,layers{1}.K_STDP,STDP_time_pre);%输入层K_STDP矩阵进行更新

    
    for i=2:learning_layer    
        s=layers{i-1}.S;    %本层的输入脉冲=上一层输出脉冲
        weight=weights{i};  %权值矩阵
        V=layers{i}.V;      %膜电位矩阵
        S=layers{i}.S;      %输出脉冲矩阵
        K_STDP=layers{i}.K_STDP;
        K_inh=layers{i}.K_inh;%侧抑制矩阵
        pad=network_struct{i}.pad; %将s进行周围补零操作，以便于卷积  s的规模为H×W×D
        th=network_struct{i}.th;
        stride=network_struct{i}.stride;
        [ s_pad ]=pad_for_conv( s,pad );    %s为对于前一层的输出补零得到的值，规模为网络规模边界+补零，有利于之后进行卷积操作
        %根据不同的层调用一些函数
        
        if strcmp( network_struct{i}.Type,'conv' )%该层为卷积层时  
            [V,S,V_buff]=conv_only( s_pad,weight,V,S,stride,th);
             %卷积层输入为s，从pool或者input，，输出为S，更新一下输出层的K_STDP
             [S,K_inh,K_STDP] = lateral_inh1(V_buff,S,K_inh,K_STDP,STDP_time_post);
        elseif strcmp( network_struct{i}.Type,'pool' )%当该层为池层时
            [S,V_buff] = pool(S,s_pad,weight,V,stride,th);
            [S,K_inh,K_STDP] = lateral_inh1(V_buff,S,K_inh,K_STDP,STDP_time_pre);
            %pool层作为学习层的输入层，发出脉冲后更新突触前神经元的K_STDP，作为是否发出抑制型STDP的标志。
        end
        layers{i}.S=S;
        layers{i}.V=V;
        layers{i}.K_STDP=K_STDP;
        layers{i}.K_inh=K_inh;
    end