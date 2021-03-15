function [] = conv_step3( ii,s,stride,th,pad)
global STDP_time_post     %������STDP����ʱ�䣬����Ԫ�ȷ������壬ǰ��Ԫ�󷢳����壬����Ȩֵ�½�
global layers 
global weights
global a_minus
%UNTITLED2 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
aminus=a_minus(ii);
[~,~,Ds]=size(s);
[H,W,D]=size(layers{ii}.V);%��һ��������D    DD=Ds*WD
[HH,WW,WD]=size(weights{ii}); 
K_STDP_pre_pad=pad_for_conv( layers{ii-1}.K_STDP,pad );
ks=0;
for k=1:WD %һ��һ�����   sÿһ����Ȩֵ�����һ����о�����õ�Ds������
    conv_core=weights{ii}(:,:,k);%��k��ӳ���Ȩֵ������ʽ
    for num_s=1:Ds                            %��֪��Ϊʲô��k����11��
       ks=ks+1;
        for j=1:W
            for i=1:H
            local_image=double(s((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,num_s));%local_imgָ����һ��С��Χ��ͼ���СΪfilter_size
            %���������STDP������·���
            local_K_STDP=K_STDP_pre_pad((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,num_s);
           %ks=(k-1)*Ds+num_s;%����������ĵ�ks�� �ǵ�k��Ȩֵ�������num_s���ӳ��
            result=sum(sum(conv_core.*local_image));
            layers{ii}.V(i,j,ks)=result+layers{ii}.V(i,j,ks);
               if layers{ii}.V(i,j,ks)>th   %�ﵽ��ֵ�Ҳ�����������ʱ
                  layers{ii}.V(i,j,ks)=0;%Ĥ��λ��Ϊ��
                  if layers{ii}.K_inh(i,j,k)==1
                     layers{ii}.S(i,j,ks)=1;%ͻ������Ԫ��������
                     layers{ii}.K_inh(i,j,k)=0;%��λ�÷��������ƣ�������ͬȨֵ����ӳ������������ͬλ�÷�������
                     layers{ii}.K_STDP(i,j,ks)=STDP_time_post;  %���º���ԪK_STDP��������������STDPѧϰ��
                  end
                  if layers{ii}.S(i,j,ks)==1
                      for I=1:HH
                          for J=1:WW
                              if local_K_STDP>0
                                  weights{ii}(I,J,k)=weights{ii}(I,J,k)+aminus*weights{ii}(I,J,k)*(1-weights{ii}(I,J,k));
                              end
                          end
                      end
                  end
                end
             end
         end
     end
end
end

