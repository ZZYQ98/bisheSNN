function [ ] =conv_step_prop( ii,s,stride,th)
global layers 
global weights
[~,~,Ds]=size(s);
[H,W,D]=size(layers{ii}.V);%D 与WD的大小相同
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
               if layers{ii}.V(i,j,k)>th%达到阈值且不发生侧抑制时
                  layers{ii}.V(i,j,k)=0;%膜电位置为零
                  if layers{ii}.K_inh(i,j)==1%该位置未发生侧抑制
                     layers{ii}.S(i,j,k)=1;%突触后神经元发射脉冲
                     layers{ii}.K_inh(i,j)=0;%设置该位置以后将发生侧抑制，抑制相同权值矩阵映射的其他层的相同位置发射脉冲
                  end
                end
             end
        end  
end

end

