function [] = STDP_positive(S,s,K_STDP_pre,learning_layer,stride,pad)%K_STDP_pre�����Ϊ�����K_STDP����K_STDP_postΪ����������K_STDP����
%���ݱ�־λ�����λ�ö���Ȩֵ������и���
%learning_layer Ϊ��ǰ����ѧϰ�ľ����
%���Ƚ�����ǿ�͵�STDPѧϰ ��Ҫ�õ�K_STDP_pre �Լ����������������S
global weights %���������µ�Ȩֵ����S
global weight_STDP_flag
global STDP_Flag_p
global deta_STDP_plus
[HH,WW,DD]=size(weights{learning_layer});
[Si,Sj,Sk]=size(S);%����������Ĺ�ģ          S��V�ľ����ģ����ȵ�
K_STDP_pre_pad=pad_for_conv( K_STDP_pre,pad );
[~,~,Ds]=size(s);
%��ǿ��STDP
for k=1:Sk      %�������S�ĵ�k���Ӧ����������Local_image������k��Ȩֵӳ��õ�
    for i=1:Si
        for j=1:Sj
            if S(i,j,k)==1%������������ i��j��k�������壬
                %��Ҫ��Դ���������������ǰһ����о��ʱ����Ӧ��ӳ������
                local_K_STDP=K_STDP_pre_pad((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,:);%ǰһ���Ӧ��ӳ��λ�� ��СΪHH*WW*Ds
                for I=1:HH
                    for J=1:WW
                        for K=1:Ds
                          if local_K_STDP(I,J,K)>0&&STDP_Flag_p(k)==1
                            weights{learning_layer}(I,J,k)=weights{learning_layer}(I,J,k)+deta_STDP_plus(local_K_STDP(I,J,K));  %����һ�������������Ȩֵ����
                            weight_STDP_flag(I,J,k)=100;
                            STDP_Flag_p(k)=0;
                            if weights{learning_layer}(I,J,k)>1-10e-6
                                weights{learning_layer}(I,J,k)=1-10e-6;
                            end
                          end
                        end
                    end
                end
            end
        end
    end
end
%������STDP������Ԫ��������֮��ǰ��Ԫ����������
%sΪ�������弱��
% for k=1:sk
%     for i=1:si
%         for j=1:sj
%             if s(i,j,k)==1
%                 local_k_STDP=K_STDP_post()


end

