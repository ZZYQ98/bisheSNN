function [weights,K_STDP_pre,weight_STDP_flag] = STDP_positive(S,s,K_STDP_pre,stride,pad,weight_STDP_flag,weights,deta_STDP_plus)%K_STDP_pre�����Ϊ�����K_STDP����K_STDP_postΪ����������K_STDP����
%���ݱ�־λ�����λ�ö���Ȩֵ������и���
%learning_layer Ϊ��ǰ����ѧϰ�ľ����
%���Ƚ�����ǿ�͵�STDPѧϰ ��Ҫ�õ�K_STDP_pre �Լ����������������S
%weights Ϊ���������µ�Ȩֵ����S
global STDP_Flag_p
[HH,WW,DD]=size(weights);
[Si,Sj,Sk]=size(S);%����������Ĺ�ģ          S��V�ľ����ģ����ȵ�
K_STDP_pre_pad=pad_for_conv( K_STDP_pre,pad );
[~,~,Ds]=size(s);

V_buff %�洢��������λ�ö�Ӧ��Ȩֵ    V_buff�Ĵ�С��V��ͬ



%��ǿ��STDP
for sk=1:Sk      %�������S�ĵ�k���Ӧ����������Local_image������k��Ȩֵӳ��õ�
    V_max=max(max(V_buff(:,:,sk)));
    [Mmax,Nmax]=find(V_max==V_buff(:,:,sk));
    for si=1:Si
        for sj=1:Sj
            if si==Mmax && sj==Nmax%������������ i��j��k��������
                %��Ҫ��Դ���������������ǰһ����о��ʱ����Ӧ��ӳ������
                local_K_STDP=K_STDP_pre_pad((si-1)*stride+1:(si-1)*stride+HH,(sj-1)*stride+1:(sj-1)*stride+WW,:);%ǰһ���Ӧ��ӳ��λ�� ��СΪHH*WW*Ds
                %����K_STDP������б�������    local_K_STDP�����С��Ȩֵ�����С��ͬ
                for I=1:HH
                    for J=1:WW
                        for K=1:Ds 
                          if local_K_STDP(I,J,K)>0 && STDP_Flag_p(sk)>0 &&STDP_inh((si-1)*stride+I,(sj-1)*stride+J)
                                                                         %STDP_inhΪһ����ά���󣬴�СΪSi*Sj�����ڶ��巢����STDPѧϰ�����Ԫ�������ͬλ����Χ��������Ԫ��ѧϰ����Ӱ��
                             weights(I,J,sk)=weights(I,J,sk)+deta_STDP_plus(local_K_STDP(I,J,K));  %����һ�������������Ȩֵ���� 
                             STDP_inh
                               if weights(I,J,sk)>0.999999
                               weights(I,J,sk)=0.999999;
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

