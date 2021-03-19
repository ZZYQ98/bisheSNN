function [ S,K_inh] = lateral_inh( S,V,K_inh )
%侧抑制矩阵形成过程
%   此处显示详细说明
S_inh=ones(size(S));
K=ones(size(K_inh));
[Vi,Vj,Vk]=size(V);
for i=1:Vi
    for j=1:Vj
        for k=1:Vk
            flag=0;
            if S(i,j,k)~=1%无输出脉冲，不发生侧抑制
                continue
            end
            if K_inh(i,j)==0;%当侧抑制矩阵该处为0时，设该处的S_inh为0
                S_inh(i,j,k)=0;
                continue
            end
            
            for kz=1:Vk
                if S(i,j,kz)==1&&V(i,j,k)<V(i,j,kz)
                    S_inh(i,j,kz)=0;
                    flag=1;
                end
            end
            if flag
                continue
            else
                K(i,j)=0;
            end
        end
    end
end
S_inh1=uint8(S_inh);
S=S.*S_inh1; %将被抑制出脉冲输出调为零
K1=uint8(K);
K_inh=K1.*K_inh;
end

