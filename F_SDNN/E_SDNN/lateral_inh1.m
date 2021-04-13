function [S_out,K_inh_out,K_STDP_out] = lateral_inh1(V_buff,S,K_inh,K_STDP,t)    %侧抑制，一个位置只能有一层发出脉冲
%K_STDP 存储脉冲的发送时间
% 初始的K_inh矩阵为全1
[Vi,Vj,Vk]=size(S);
for k=1:Vk
    for i=1:Vi
        for j=1:Vj
            if S(i,j,k)==1 && K_inh(i,j)==1 && V_buff(i,j,k)==max(V_buff(i,j,:))
                %可以发出脉冲
            K_inh(i,j)=0;
            K_STDP(i,j,k)=t;
            else
                S(i,j,k)=0;
            end
        end 
    end
end  
K_STDP_out=K_STDP;
K_inh_out=K_inh;
S_out=S;
end

