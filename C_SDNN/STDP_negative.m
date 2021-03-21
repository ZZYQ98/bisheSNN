function [  ] =STDP_negative(S,s,K_STDP_post,learning_layer,stride,pad)  
%UNTITLED2 此处显示有关此函数的摘要
global weights
global STDP_Flag_n
global deta_STDP_minus
global weight_STDP_flag
[~,~,Ds]=size(s);
[H,W,D]=size(S);%D 与WD的大小相同
[HH,WW,WD]=size(weights{learning_layer}); 
s_pad=pad_for_conv( s,pad ); %对于输入的脉冲矩阵进行补零操作
for k=1:WD %一层一层的来   s每一层与权值矩阵的一层进行卷积，得到Ds层
        for j=1:W
            for i=1:H
                local_image=double(s_pad((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,:)); % 大小为 HH*WW*Ds
                %判断能否进行STDP权值更新
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
            %目前的抑制效果属于互抑制，没有发生自抑制
            %自抑制表示某神经元会对同一通道内的所有其他神经元产生抑制，即单个通道今由单个首脉冲神经元出发权重更新，使得同一通道内仅学习与其最为相符的单个特征
            %互抑制则表示某神经元还会对其他神经元产生抑制，即不同通道中的特定区域仍然由单个首脉冲神经元触发权重更新，使得不同通道提取各自符合的特征。


end



