function [ V,S,K_STDP,K_inh ] = conv_step1( S,V,s,w,stride,th,K_STDP,K_inh )
global STDP_time_post     %抑制性STDP作用时间，后神经元先发出脉冲，前神经元后发出脉冲，导致权值下降
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
[~,~,Ds]=size(s);
[H,W,~]=size(V);%下一层的总深度D    D=DS*DD 
[HH,WW,DD]=size(w); 
ks=1;
for k=1:DD %一层一层的来                           s每一层与权值的一层进行卷积，得到Ds层数据
    conv_core=w(:,:,k);%第k层映射的权值矩阵形式
    for i=1:H
        for j=1:W
            for num_s=1:Ds
            local_image=double(s((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,num_s));%local_img指的是一个小范围的图像大小为filter_size
           %ks=(k-1)*Ds+num_s;%输出脉冲矩阵的第ks层 是第k层权值对输入第num_s层的映射
            
            result=sum(sum(conv_core.*local_image));
            V(i,j,ks)=result+V(i,j,ks);
               if V(i,j,ks)>th && K_inh(i,j,k)==1    %达到阈值且不发生侧抑制时
                  V(i,j,ks)=0;%膜电位置为零
                  S(i,j,ks)=1;%突触后神经元发射脉冲
                  K_inh(i,j,k)=0;%该位置发生侧抑制，抑制相同权值矩阵映射的其他层的相同位置发射脉冲
                  K_STDP(i,j,ks)=STDP_time_post;
               end
               ks=ks+1;
            end
        end
    end
end

end
