function [V,S_out] = conv_only( s,weight,V,stride,th)         
%STDP_time_post������STDP����ʱ�䣬����Ԫ�ȷ������壬ǰ��Ԫ�󷢳����壬����Ȩֵ�½�

%UNTITLED2 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
S_out=zeros(size(V));%�����������С��Ĥ��λ�����С��ͬ
[Vi,Vj,Vk]=size(V);
[HH,WW,MM,DD]=size(weight);   %MM=Ds  ��һ��Ĳ���     Vk=DD  

for k=1:Vk %һ��һ�����   sÿһ����Ȩֵ�����һ����о�����õ�Ds������
        for i=1:Vi
            for j=1:Vj
              if  V(i,j,k)>th %�ﵽ��ֵ
                  V(i,j,k)=0;%Ĥ��λ��Ϊ��
              end
              
              local_image=double(s((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,:));%local_imgָ����һ��С��Χ��ͼ���СΪfilter_size 
              %local_image �Ĵ�СΪHH*WW*Ds
              result=sum(sum(sum(weight(:,:,:,k).*local_image))); %����ǰHH*WW*Ds��Ԫͨ����k��Ȩֵ����ӳ��õ���Ȩֵ������
              
              V(i,j,k)=result+V(i,j,k);%���¸�λ�õ�Ȩֵ����
                   %�۲��Ƿ�ﵽ��ֵ��������������
                   %Ŀǰ������Ч�����ڻ����ƣ�û�з���������
              if V(i,j,k)>th
                 S_out(i,j,k)=1;
              else
                 S_out(i,j,k)=0;
               end
            end  
        end  
end   
end

%�����Ʊ�ʾĳ��Ԫ���ͬһͨ���ڵ�����������Ԫ�������ƣ�������ͨ�����ɵ�����������Ԫ����Ȩ�ظ��£�ʹ��ͬһͨ���ڽ�ѧϰ������Ϊ����ĵ�������
%���������ʾĳ��Ԫ�����������Ԫ�������ƣ�����ͬͨ���е��ض�������Ȼ�ɵ�����������Ԫ����Ȩ�ظ��£�ʹ�ò�ͬͨ����ȡ���Է��ϵ�������