function [S,K_inh,K_STDP] = lateral_inh(V_buff,S,K_inh,K_STDP,K_STDP_time)    %侧抑制，一个位置只能有一层发出脉冲
%UNTITLED 此处显示有关此函数的摘要
% 初始的K_inh矩阵为全1
[Vi,Vj,Vk]=size(V_buff);
for k=1:Vk
    for i=1:Vi
        for j=1:Vj
            if S(i,j,k)~=1
                continue
            end
            
            if K_inh(i,j)==0
                S(i,j,k)=0;
                continue
            end
            for K=1:Vk
                if S(i,j,K)==1 && V_buff(i,j,k)<V_buff(i,j,K) %若通一个map相同位置发出脉冲，则膜电位最大的位置才能发出脉冲
                    S(i,j,k)=0;   %这个如果S(i,j,k)发出脉冲了，则对应位置一定为0 
                    return
                end
            end
            K_inh(i,j)=0;
            K_STDP(i,j,k)=K_STDP_time;
        end 
    end
end          
end

