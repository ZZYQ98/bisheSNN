function [] = conv_step3( ii,s,stride,th,pad)
global STDP_time_post     %抑制性STDP作用时间，后神经元先发出脉冲，前神经元后发出脉冲，导致权值下降
global layers 
global weights
global a_minus
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
aminus=a_minus(ii);
[~,~,Ds]=size(s);
[H,W,D]=size(layers{ii}.V);%下一层的总深度D    DD=Ds*WD
[HH,WW,WD]=size(weights{ii}); 
K_STDP_pre_pad=pad_for_conv( layers{ii-1}.K_STDP,pad );
ks=0;
for k=1:WD %一层一层的来   s每一层与权值矩阵的一层进行卷积，得到Ds层数据
    conv_core=weights{ii}(:,:,k);%第k层映射的权值矩阵形式
    for num_s=1:Ds                            %不知道为什么，k等于11了
       ks=ks+1;
        for j=1:W
            for i=1:H
            local_image=double(s((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,num_s));%local_img指的是一个小范围的图像大小为filter_size
            %设计抑制型STDP矩阵更新方法
            local_K_STDP=K_STDP_pre_pad((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,num_s);
           %ks=(k-1)*Ds+num_s;%输出脉冲矩阵的第ks层 是第k层权值对输入第num_s层的映射
            result=sum(sum(conv_core.*local_image));
            layers{ii}.V(i,j,ks)=result+layers{ii}.V(i,j,ks);
               if layers{ii}.V(i,j,ks)>th   %达到阈值且不发生侧抑制时
                  layers{ii}.V(i,j,ks)=0;%膜电位置为零
                  if layers{ii}.K_inh(i,j,k)==1
                     layers{ii}.S(i,j,ks)=1;%突触后神经元发射脉冲
                     layers{ii}.K_inh(i,j,k)=0;%该位置发生侧抑制，抑制相同权值矩阵映射的其他层的相同位置发射脉冲
                     layers{ii}.K_STDP(i,j,ks)=STDP_time_post;  %更新后神经元K_STDP矩阵，用于抑制型STDP学习。
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

