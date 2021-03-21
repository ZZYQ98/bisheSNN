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
for sk=1:Sk      %�������S�ĵ�k���Ӧ����������Local_image������k��Ȩֵӳ��õ�
    for si=1:Si
        for sj=1:Sj
            if S(si,sj,sk)==1%������������ i��j��k�������壬
                %��Ҫ��Դ���������������ǰһ����о��ʱ����Ӧ��ӳ������
                local_K_STDP=K_STDP_pre_pad((si-1)*stride+1:(si-1)*stride+HH,(sj-1)*stride+1:(sj-1)*stride+WW,:);%ǰһ���Ӧ��ӳ��λ�� ��СΪHH*WW*Ds
                %����K_STDP������б�������
                for I=1:HH
                    for J=1:WW
                        for K=1:Ds
                          if local_K_STDP(I,J,K)>0&&STDP_Flag_p(sk)>0
                             weights{learning_layer}(I,J,sk)=weights{learning_layer}(I,J,sk)+deta_STDP_plus(local_K_STDP(I,J,K));  %����һ�������������Ȩֵ����
                             local_K_STDP(I,J,K)=0;%��K_STDP������һ������������ѧϰ������
                               if weights{learning_layer}(I,J,sk)>0.999999
                               weights{learning_layer}(I,J,sk)=0.999999;
                               end
                            weight_STDP_flag(I,J,sk)=0;%����Ϊ�˷�״̬
                            STDP_Flag_p(sk)=STDP_Flag_p(sk)-1;
                          end
                        end
                    end
                end
            end
        end
    end
end



end

