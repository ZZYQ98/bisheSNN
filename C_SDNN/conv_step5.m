function [] = conv_step5( ii,s,stride,th)         
global STDP_time_post     %������STDP����ʱ�䣬����Ԫ�ȷ������壬ǰ��Ԫ�󷢳����壬����Ȩֵ�½�
global layers 
global weights
%UNTITLED2 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
[~,~,Ds]=size(s);
[H,W,D]=size(layers{ii}.V);%D ��WD�Ĵ�С��ͬ
V_buff=zeros(H,W);
[HH,WW,WD]=size(weights{ii}); 
for k=1:WD %һ��һ�����   sÿһ����Ȩֵ�����һ����о�����õ�Ds������
    conv_core=weights{ii}(:,:,k);%��k��ӳ���Ȩֵ������ʽ
        for j=1:W
            for i=1:H
            local_image=double(s((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,:));%local_imgָ����һ��С��Χ��ͼ���СΪfilter_size 
            %local_image �Ĵ�СΪHH*WW*Ds
            result=0;
              for K=1:Ds  
                 result=result+sum(sum(conv_core.*local_image(:,:,K))); %����ǰHH*WW*Ds��Ԫͨ����k��Ȩֵ����ӳ��õ���Ȩֵ������
              end
            layers{ii}.V(i,j,k)=result+layers{ii}.V(i,j,k);%���¸�λ�õ�Ȩֵ����
            %�۲��Ƿ�ﵽ��ֵ��������������
            %Ŀǰ������Ч�����ڻ����ƣ�û�з���������
               if  layers{ii}.V(i,j,k)>th && layers{ii}.K_inh(i,j)==1  %�ﵽ��ֵ�Ҳ�����������ʱ
                   V_buff(i,j)=layers{ii}.V(i,j,k);
                   layers{ii}.V(i,j,k)=0;%Ĥ��λ��Ϊ��
               end
            end
        end  
        max_V=max(max(V_buff));
        if max_V>th
            [maxM,maxN] = find(V_buff==max_V);
            layers{ii}.S(maxM,maxN,k)=1;
            layers{ii}.K_inh(i,j)=0;
            layers{ii}.K_STDP(i,j,k)=STDP_time_post;%---------���º���ԪK_STDP��������������STDPѧϰ��
        end
end




end

%�����Ʊ�ʾĳ��Ԫ���ͬһͨ���ڵ�����������Ԫ�������ƣ�������ͨ�����ɵ�����������Ԫ����Ȩ�ظ��£�ʹ��ͬһͨ���ڽ�ѧϰ������Ϊ����ĵ�������
%���������ʾĳ��Ԫ�����������Ԫ�������ƣ�����ͬͨ���е��ض�������Ȼ�ɵ�����������Ԫ����Ȩ�ظ��£�ʹ�ò�ͬͨ����ȡ���Է��ϵ�������