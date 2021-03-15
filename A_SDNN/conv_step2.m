function [ V,S,K_STDP,K_inh ] = conv_step2( S,V,s,w,stride,th,K_STDP,K_inh )
global STDP_time_post     %������STDP����ʱ�䣬����Ԫ�ȷ������壬ǰ��Ԫ�󷢳����壬����Ȩֵ�½�
%UNTITLED2 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
[~,~,Ds]=size(s);
[H,W,~]=size(V);%��һ��������D    DD=Ds*WD
[HH,WW,WD]=size(w); 
ks=0;
for k=1:WD %һ��һ�����   sÿһ����Ȩֵ�����һ����о�����õ�Ds������
    conv_core=w(:,:,k);%��k��ӳ���Ȩֵ������ʽ
    for num_s=1:Ds                            %��֪��Ϊʲô��k����11��
       ks=ks+1;
        for j=1:W
            for i=1:H
            local_image=double(s((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,num_s));%local_imgָ����һ��С��Χ��ͼ���СΪfilter_size
           %ks=(k-1)*Ds+num_s;%����������ĵ�ks�� �ǵ�k��Ȩֵ�������num_s���ӳ��
            result=sum(sum(conv_core.*local_image));
            V(i,j,ks)=result+V(i,j,ks);
               if V(i,j,ks)>th   %�ﵽ��ֵ�Ҳ�����������ʱ
                  V(i,j,ks)=0;%Ĥ��λ��Ϊ��
                  if K_inh(i,j,k)==1
                  S(i,j,ks)=1;%ͻ������Ԫ��������
                  K_inh(i,j,k)=0;%��λ�÷��������ƣ�������ͬȨֵ����ӳ������������ͬλ�÷�������
                  K_STDP(i,j,ks)=STDP_time_post;
                  end
               end
            end
        end
    end
end

end
