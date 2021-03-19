function [ V,S,K_STDP ] = conv_step_without_inh( S,V,s,w,stride,th,K_STDP )
global STDP_time_post     %抑制性STDP作用时间，后神经元先发出脉冲，前神经元后发出脉冲，导致权值下降
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
[~,~,Ds]=size(s);
[H,W,~]=size(V);%下一层的总深度D    D=DS*DD 
[HH,WW,DD]=size(w); 
for k=1:DD %一层一层的来                           s每一层与权值的一层进行卷积，得到Ds层的数据，而后与权值的下一层进行卷积
    conv_core=w(:,:,k);%第k层映射的权值矩阵形式
    for i=1:H
        for j=1:W
            for num_s=1:Ds
            local_image=double(s((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,Ds));%local_img指的是一个小范围的图像大小为filter_size
            ks=(k-1)*Ds+num_s;
            result=sum(sum(conv_core.*local_image));
            V(i,j,ks)=result+V(i,j,ks);%输出脉冲矩阵的ks层为除以Ds的商+1等于对应的权值w的层
               if V(i,j,ks)>th
                  V(i,j,ks)=0;
                  S(i,j,ks)=1;%突触后神经元发射脉冲
                  K_STDP(i,j,ks)=STDP_time_post;
               end
            end
        end
    end
end

end
