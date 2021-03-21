function [] = STDP_positive(S,s,K_STDP_pre,learning_layer,stride,pad)%K_STDP_pre卷积层为输入的K_STDP矩阵，K_STDP_post为卷积层输出的K_STDP矩阵
%根据标志位的相对位置对于权值矩阵进行更新
%learning_layer 为当前正在学习的卷积层
%首先进行增强型的STDP学习 需要用到K_STDP_pre 以及卷积层输出脉冲矩阵S
global weights %即将被更新的权值矩阵S
global weight_STDP_flag
global STDP_Flag_p
global deta_STDP_plus
[HH,WW,DD]=size(weights{learning_layer});
[Si,Sj,Sk]=size(S);%输出脉冲矩阵的规模          S与V的矩阵规模是相等的
K_STDP_pre_pad=pad_for_conv( K_STDP_pre,pad );
[~,~,Ds]=size(s);
%增强型STDP
for sk=1:Sk      %输出矩阵S的第k层对应着输入矩阵的Local_image经过第k层权值映射得到
    for si=1:Si
        for sj=1:Sj
            if S(si,sj,sk)==1%代表输出矩阵第 i，j，k发射脉冲，
                %需要溯源这个发出的脉冲在前一层进行卷积时，对应的映射区域
                local_K_STDP=K_STDP_pre_pad((si-1)*stride+1:(si-1)*stride+HH,(sj-1)*stride+1:(sj-1)*stride+WW,:);%前一层对应的映射位置 大小为HH*WW*Ds
                %对于K_STDP矩阵进行遍历操作
                for I=1:HH
                    for J=1:WW
                        for K=1:Ds
                          if local_K_STDP(I,J,K)>0&&STDP_Flag_p(sk)>0
                             weights{learning_layer}(I,J,sk)=weights{learning_layer}(I,J,sk)+deta_STDP_plus(local_K_STDP(I,J,K));  %对这一层的脉冲矩阵进行权值更新
                             local_K_STDP(I,J,K)=0;%对K_STDP矩阵有一个操作，发生学习后清零
                               if weights{learning_layer}(I,J,sk)>0.999999
                               weights{learning_layer}(I,J,sk)=0.999999;
                               end
                            weight_STDP_flag(I,J,sk)=0;%设置为兴奋状态
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

