function [  ] =STDP_negative(S,s,K_STDP_post,learning_layer,stride,pad)  
%UNTITLED2 �˴���ʾ�йش˺�����ժҪ
global weights
global STDP_Flag_n
global deta_STDP_minus
global weight_STDP_flag
[~,~,Ds]=size(s);
[H,W,D]=size(S);%D ��WD�Ĵ�С��ͬ
[HH,WW,WD]=size(weights{learning_layer}); 
s_pad=pad_for_conv( s,pad ); %������������������в������
for k=1:WD %һ��һ�����   sÿһ����Ȩֵ�����һ����о�����õ�Ds��
        for j=1:W
            for i=1:H
                local_image=double(s_pad((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,:)); % ��СΪ HH*WW*Ds
                %�ж��ܷ����STDPȨֵ����
                     if sum(sum(sum(local_image)))>0 && K_STDP_post(i,j,k)>0
                       for L=1:Ds
                          for I=1:WW
                             for J=1:HH
                                 if local_image(I,J,L)==1 &&STDP_Flag_n(k)>0
                                     weights{learning_layer}(I,J,k)=weights{learning_layer}(I,J,k)+deta_STDP_minus(K_STDP_post(i,j,k));
                                     if weights{learning_layer}(I,J,k)<0.000001
                                        weights{learning_layer}(I,J,k)=0.000001;
                                     end
                                     weight_STDP_flag(I,J,k)=0;
                                     STDP_Flag_n(k)=STDP_Flag_n(k)-1;
                                     if STDP_Flag_n==0
                                         break
                                     end
                                     
                                 end 
                             end 
                          end 
                       end 
                    end  
            end 
        end
end
            %Ŀǰ������Ч�����ڻ����ƣ�û�з���������
            %�����Ʊ�ʾĳ��Ԫ���ͬһͨ���ڵ�����������Ԫ�������ƣ�������ͨ�����ɵ�����������Ԫ����Ȩ�ظ��£�ʹ��ͬһͨ���ڽ�ѧϰ������Ϊ����ĵ�������
            %���������ʾĳ��Ԫ�����������Ԫ�������ƣ�����ͬͨ���е��ض�������Ȼ�ɵ�����������Ԫ����Ȩ�ظ��£�ʹ�ò�ͬͨ����ȡ���Է��ϵ�������


end



