function [] = STDP2(S,s,K_STDP_pre,K_STDP_post,learning_layer,stride,pad)%K_STDP_pre卷积层为输入的K_STDP矩阵，K_STDP_post为卷积层输出的K_STDP矩阵
%根据标志位的相对位置对于权值矩阵进行更新
%learning_layer 为当前正在学习的卷积层
%首先进行增强型的STDP学习 需要用到K_STDP_pre 以及卷积层输出脉冲矩阵S
global weights %即将被更新的权值矩阵Sk
global STDP_params
global STDP_counter
global weight_STDP_flag
[HH,WW,DD]=size(weights{learning_layer});
[Si,Sj,Sk]=size(S);%输出脉冲矩阵的规模          S与V的矩阵规模是相等的
[si,sj,sk]=size(s);%输入脉冲矩阵的规模
K_STDP_pre_pad=pad_for_conv( K_STDP_pre,pad );

%增强型STDP
for k=1:Sk
    for i=1:Si
        for j=1:Sj
            if S(i,j,Sk)==1%代表输出矩阵第 i，j，k发射脉冲，
                %需要溯源这个发出的脉冲在前一层进行卷积时，对应的映射区域
                local_K_STDP=K_STDP_pre_pad((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,:);%前一层对应的映射位置           %索引维度超标，原因：K_STDP没有加pad，不经过补零时，经过卷积过程不能得到相同大小的矩阵
                for I=1:HH
                    for J=1:WW
                        for K=1:DD
                        if local_K_STDP(HH,WW,DD)>0
                            weights{learning_layer}(HH,WW,Sk)=weights{learning_layer}(HH,WW,Sk)+deta_STDP_plus(local_K_STDP(HH,WW,DD));  %对这一层的脉冲矩阵进行权值更新
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
%抑制型STDP：后神经元发出脉冲之后前神经元又输入脉冲
%s为输入脉冲急诊
% for k=1:sk
%     for i=1:si
%         for j=1:sj
%             if s(i,j,k)==1
%                 local_k_STDP=K_STDP_post()


end

