function [] = conv_step5( ii,s,stride,th)         
global STDP_time_post     %抑制性STDP作用时间，后神经元先发出脉冲，前神经元后发出脉冲，导致权值下降
global layers 
global weights
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
[~,~,Ds]=size(s);
[H,W,D]=size(layers{ii}.V);%D 与WD的大小相同
V_buff=zeros(H,W);
[HH,WW,WD]=size(weights{ii}); 
for k=1:WD %一层一层的来   s每一层与权值矩阵的一层进行卷积，得到Ds层数据
    conv_core=weights{ii}(:,:,k);%第k层映射的权值矩阵形式
        for j=1:W
            for i=1:H
            local_image=double(s((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,:));%local_img指的是一个小范围的图像大小为filter_size 
            %local_image 的大小为HH*WW*Ds
            result=0;
              for K=1:Ds  
                 result=result+sum(sum(conv_core.*local_image(:,:,K))); %经过前HH*WW*Ds神经元通过第k层权值进行映射得到的权值更新量
              end
            layers{ii}.V(i,j,k)=result+layers{ii}.V(i,j,k);%更新该位置的权值矩阵
            %观察是否达到阈值，进而发射脉冲
            %目前的抑制效果属于互抑制，没有发生自抑制
               if  layers{ii}.V(i,j,k)>th && layers{ii}.K_inh(i,j)==1  %达到阈值且不发生侧抑制时
                   V_buff(i,j)=layers{ii}.V(i,j,k);
                   layers{ii}.V(i,j,k)=0;%膜电位置为零
               end
            end
        end  
        max_V=max(max(V_buff));
        if max_V>th
            [maxM,maxN] = find(V_buff==max_V);
            layers{ii}.S(maxM,maxN,k)=1;
            layers{ii}.K_inh(i,j)=0;
            layers{ii}.K_STDP(i,j,k)=STDP_time_post;%---------更新后神经元K_STDP矩阵，用于抑制型STDP学习。
        end
end




end

%自抑制表示某神经元会对同一通道内的所有其他神经元产生抑制，即单个通道今由单个首脉冲神经元出发权重更新，使得同一通道内仅学习与其最为相符的单个特征
%互抑制则表示某神经元还会对其他神经元产生抑制，即不同通道中的特定区域仍然由单个首脉冲神经元触发权重更新，使得不同通道提取各自符合的特征。