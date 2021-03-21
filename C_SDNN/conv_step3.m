function [] = conv_step3( ii,s,stride,th,pad)
global STDP_time_post     %������STDP����ʱ�䣬����Ԫ�ȷ������壬ǰ��Ԫ�󷢳����壬����Ȩֵ�½�
global layers 
global weights
global weight_STDP_flag
global deta_STDP_minus
%UNTITLED2 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
[~,~,Ds]=size(s);
[H,W,D]=size(layers{ii}.V);%D ��WD�Ĵ�С��ͬ
[HH,WW,WD]=size(weights{ii}); 
K_STDP_pre_pad=pad_for_conv( layers{ii-1}.K_STDP,pad );
for k=1:WD %һ��һ�����   sÿһ����Ȩֵ�����һ����о������õ�Ds������
    conv_core=weights{ii}(:,:,k);%��k��ӳ���Ȩֵ������ʽ
        for j=1:W
            for i=1:H
            local_image=double(s((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,:));%local_imgָ����һ��С��Χ��ͼ���СΪfilter_size 
            %local_image �Ĵ�СΪHH*WW*Ds
            %���������STDP������·���
            local_K_STDP=K_STDP_pre_pad((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,:); %localSTDP��local image��С��ͬ
            result=0;
              for K=1:Ds  
                 result=result+sum(sum(conv_core.*local_image(:,:,K))); %����ǰHH*WW*Ds��Ԫͨ����k��Ȩֵ����ӳ��õ���Ȩֵ������
              end
            layers{ii}.V(i,j,k)=result+layers{ii}.V(i,j,k);%���¸�λ�õ�Ȩֵ����
            %�۲��Ƿ�ﵽ��ֵ��������������
            
            %Ŀǰ������Ч�����ڻ����ƣ�û�з���������
            %�����Ʊ�ʾĳ��Ԫ���ͬһͨ���ڵ�����������Ԫ�������ƣ�������ͨ�����ɵ�����������Ԫ����Ȩ�ظ��£�ʹ��ͬһͨ���ڽ�ѧϰ������Ϊ����ĵ�������
            %���������ʾĳ��Ԫ�����������Ԫ�������ƣ�����ͬͨ���е��ض�������Ȼ�ɵ�����������Ԫ����Ȩ�ظ��£�ʹ�ò�ͬͨ����ȡ���Է��ϵ�������
               if layers{ii}.V(i,j,k)>th   %�ﵽ��ֵ�Ҳ�����������ʱ
                  layers{ii}.V(i,j,k)=0;%Ĥ��λ��Ϊ��
                  if layers{ii}.K_inh(i,j)==1%��λ��δ����������
                     layers{ii}.S(i,j,k)=1;%ͻ������Ԫ��������
                     layers{ii}.K_inh(i,j)=0;%���ø�λ���Ժ󽫷��������ƣ�������ͬȨֵ����ӳ������������ͬλ�÷�������
                     layers{ii}.K_STDP( i,j,k)=STDP_time_post;  %���º���ԪK_STDP��������������STDPѧϰ��
                  end
                  
                   %������STDP����Ȩֵ
                   if layers{ii}.S(i,j,k)==1
                        for L=1:Ds
                            for I=1:WW
                                for J=1:HH
                                if local_K_STDP(I,J,L)>0
                                   weights{ii}(I,J,k)=weights{ii}(I,J,k)+deta_STDP_minus(local_K_STDP(I,J,L));
                                   weight_STDP_flag(I,J,k)=20;
                                    %weights{ii}(I,J,k)=weights{ii}(I,J,k)-aminus*exp(local_K_STDP/tao_minus);
                                    if weights{ii}(I,J,k)<1e-6
                                        weights{ii}(I,J,k)=1e-6;
                                    end
                                end
                                end
                            end
                        end
                    end%end if
                end
             end
        end   
end

end
