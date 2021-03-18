function [ V,S,K_STDP ] = conv_step_without_inh( S,V,s,w,stride,th,K_STDP )
global STDP_time_post     %������STDP����ʱ�䣬����Ԫ�ȷ������壬ǰ��Ԫ�󷢳����壬����Ȩֵ�½�
%UNTITLED2 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
[~,~,Ds]=size(s);
[H,W,~]=size(V);%��һ��������D    D=DS*DD 
[HH,WW,DD]=size(w); 
for k=1:DD %һ��һ�����                           sÿһ����Ȩֵ��һ����о�����õ�Ds������ݣ�������Ȩֵ����һ����о��
    conv_core=w(:,:,k);%��k��ӳ���Ȩֵ������ʽ
    for i=1:H
        for j=1:W
            for num_s=1:Ds
            local_image=double(s((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,Ds));%local_imgָ����һ��С��Χ��ͼ���СΪfilter_size
            ks=(k-1)*Ds+num_s;
            result=sum(sum(conv_core.*local_image));
            V(i,j,ks)=result+V(i,j,ks);%�����������ks��Ϊ����Ds����+1���ڶ�Ӧ��Ȩֵw�Ĳ�
               if V(i,j,ks)>th
                  V(i,j,ks)=0;
                  S(i,j,ks)=1;%ͻ������Ԫ��������
                  K_STDP(i,j,ks)=STDP_time_post;
               end
            end
        end
    end
end

end
