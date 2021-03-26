function [weights] = STDP(layers,learning_layer,STDP_index,weights,network_struct,delta_STDP_minus,delta_STDP_plus)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
pad=network_struct{learning_layer}.pad; %将s进行周围补零操作，以便于卷积  s的规模为H×W×D
stride=network_struct{learning_layer}.stride;

K_STDP=layers{learning_layer-1}.K_STDP; %学习层上一层的脉冲输入时间矩阵
K_STDP_pad=pad_for_conv( K_STDP,pad );
w=weights{learning_layer};

%  Sk  为输出脉冲的层数，与权值矩阵的个数有关
[H,W,D,Sk]=size(w);
for K=1:Sk
    if STDP_index{K}>0
     si=STDP_index{K}(1);
     sj=STDP_index{K}(2);
     sk=STDP_index{K}(3); %sk=K
     st=STDP_index{K}(4); %即将进行STDP的位置，按层得到
     local_K_STDP=K_STDP_pad((si-1)*stride+1:(si-1)*stride+H,(sj-1)*stride+1:(sj-1)*stride+W,:);
    for k=1:D
        for i=1:H
            for j=1:W
                if local_K_STDP(i,j,k)==0
                    dw=-delta_STDP_minus(1);%*w(i,j,k,sk);
                else
                   
                    if local_K_STDP(i,j,k)>=st
                        dw=-delta_STDP_minus(local_K_STDP(i,j,k)-st+1);%*w(i,j,k,sk);
                    elseif local_K_STDP(i,j,k)<st
                        dw=delta_STDP_plus(st-local_K_STDP(i,j,k));%*(1-w(i,j,k,sk));
                    end
                end
                w(i,j,k,K)=w(i,j,k,K)+dw;
                if w(i,j,k,K)>0.999999
                    w(i,j,k,K)=0.999999;
                elseif w(i,j,k,K)<0.000001
                    w(i,j,k,K)=0.000001;
                end  
            end
        end
    end
    end
end
weights{learning_layer}=w;
end

