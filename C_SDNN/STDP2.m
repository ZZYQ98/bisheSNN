function [] = STDP2(S,s,K_STDP_pre,K_STDP_post,learning_layer,stride,pad)%K_STDP_pre�����Ϊ�����K_STDP����K_STDP_postΪ����������K_STDP����
%���ݱ�־λ�����λ�ö���Ȩֵ������и���
%learning_layer Ϊ��ǰ����ѧϰ�ľ����
%���Ƚ�����ǿ�͵�STDPѧϰ ��Ҫ�õ�K_STDP_pre �Լ����������������S
global weights %���������µ�Ȩֵ����Sk
global STDP_params
global STDP_counter
global weight_STDP_flag
[HH,WW,DD]=size(weights{learning_layer});
[Si,Sj,Sk]=size(S);%����������Ĺ�ģ          S��V�ľ����ģ����ȵ�
[si,sj,sk]=size(s);%�����������Ĺ�ģ
K_STDP_pre_pad=pad_for_conv( K_STDP_pre,pad );

%��ǿ��STDP
for k=1:Sk
    for i=1:Si
        for j=1:Sj
            if S(i,j,Sk)==1%������������ i��j��k�������壬
                %��Ҫ��Դ���������������ǰһ����о��ʱ����Ӧ��ӳ������
                local_K_STDP=K_STDP_pre_pad((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,:);%ǰһ���Ӧ��ӳ��λ��           %����ά�ȳ��꣬ԭ��K_STDPû�м�pad������������ʱ������������̲��ܵõ���ͬ��С�ľ���
                for I=1:HH
                    for J=1:WW
                        for K=1:DD
                        if local_K_STDP(HH,WW,DD)>0
                            weights{learning_layer}(HH,WW,Sk)=weights{learning_layer}(HH,WW,Sk)+deta_STDP_plus(local_K_STDP(HH,WW,DD));  %����һ�������������Ȩֵ����
                            weight_STDP_flag(HH,WW,Sk)=20;
                            if weights{learning_layer}(HH,WW,Sk)>1-10e-6
                                weights{learning_layer}(HH,WW,Sk)=1-10e-6;
                            end
                            if STDP_counter>STDP_params.STDP_per_layer(learning_layer)
                                continue
                            else STDP_counter=STDP_counter+1;
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

