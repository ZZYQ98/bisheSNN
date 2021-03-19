function [ S,K_inh] = lateral_inh( S,V,K_inh )
%�����ƾ����γɹ���
%   �˴���ʾ��ϸ˵��
S_inh=ones(size(S));
K=ones(size(K_inh));
[Vi,Vj,Vk]=size(V);
for i=1:Vi
    for j=1:Vj
        for k=1:Vk
            flag=0;
            if S(i,j,k)~=1%��������壬������������
                continue
            end
            if K_inh(i,j)==0;%�������ƾ���ô�Ϊ0ʱ����ô���S_inhΪ0
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
S=S.*S_inh1; %�������Ƴ����������Ϊ��
K1=uint8(K);
K_inh=K1.*K_inh;
end

