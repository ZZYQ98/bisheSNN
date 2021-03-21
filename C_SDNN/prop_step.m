function [sp_time] = prop_step(st)
global network_struct
global layers
global total_time
global num_layers
%目前没加侧抑制矩阵
[~,~,D]=size(layers{num_layers}.S);
sp_time=zeros(1,D);
for t=1:total_time
    layers{1}.S=st(:,:,:,t);
    for i=2:num_layers
        s=layers{i-1}.S;%本层的输入脉冲=上一层输出脉冲
        pad=network_struct{i}.pad; %将s进行周围补零操作，以便于卷积  s的规模为H×W×D
        [ s_pad ]=pad_for_conv( s,pad );    %s为对于前一层的输出补零得到的值，规模为网络规模边界+补零，有利于之后进行卷积操作
        
        if strcmp( network_struct{i}.Type,'conv' )
           conv_step_prop( i,s_pad,network_struct{i}.stride,network_struct{i}.th);%进行一次权值更新
        elseif strcmp( network_struct{i}.Type,'pool' )
            pooling1(i,s_pad,network_struct{i}.stride,network_struct{i}.th);
        end
        if i==num_layers
            for n=1:D
                if layers{num_layers}.S==1
                    sp_time(n)=t;
                end
            end
        end
    end
    
end

end

