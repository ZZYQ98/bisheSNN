function [V,S_out] = conv_only( s,weight,V,stride,th)         
%STDP_time_post抑制性STDP作用时间，后神经元先发出脉冲，前神经元后发出脉冲，导致权值下降

%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
S_out=zeros(size(V));%输出脉冲矩阵大小与膜电位矩阵大小相同
[Vi,Vj,Vk]=size(V);
[HH,WW,~,~]=size(weight);   %MM=Ds  上一层的层数     Vk=DD  

for k=1:Vk %  输入脉冲矩阵s每一层与权值矩阵的Ds层进行卷积，得到Ds层数据
        for i=1:Vi
            for j=1:Vj
              if  V(i,j,k)>th %上一个时刻中，神经元的膜电压达到阈值
                  V(i,j,k)=0;%当前时刻膜电位置清零
              end
              
              local_image=double(s((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,:));%local_img指的是一个小范围的图像大小为filter_size 
              %local_image 的大小为HH*WW*Ds
              result=sum(sum(sum(weight(:,:,:,k).*local_image))); %经过前HH*WW*Ds神经元通过第k层权值进行映射得到的权值更新量
              
              V(i,j,k)=result+V(i,j,k);%更新该位置的权值矩阵
                   %观察是否达到阈值，进而发射脉冲
                   %目前的抑制效果属于互抑制，没有发生自抑制
              if V(i,j,k)>th%膜电位大于阈值
                 S_out(i,j,k)=1;%发出脉冲
               end
            end  
        end  
end   
end

%自抑制表示某神经元会对同一通道内的所有其他神经元产生抑制，即单个通道今由单个首脉冲神经元出发权重更新，使得同一通道内仅学习与其最为相符的单个特征
%互抑制则表示某神经元还会对其他神经元产生抑制，即不同通道中的特定区域仍然由单个首脉冲神经元触发权重更新，使得不同通道提取各自符合的特征。