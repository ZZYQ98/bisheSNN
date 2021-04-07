function [M] = DoG_filter_to_st( path_img,filt_size,img_size,total_time,num_layers)
%UNTITLED5 此处显示有关此函数的摘要
%   此处显示详细说明
H=img_size.img_sizeH;
W=img_size.img_sizeW;
image=imread(path_img);
image=imresize(image,[H W]);%对图片大小进行调整
image_for_DoG=double(image);
%对图像进行滤波
filt=load("filt.mat");
filt=filt.filt;
out1=imfilter(image_for_DoG,filt,'replicate','same','conv');

%boarder
border=zeros(H,W);
border(filt_size+1:H-filt_size,filt_size+1:W-filt_size)=1;
out1=out1.*border;

out_threshold=out1;
out_threshold(out1<16)=0;

% for i=1:H
%     for j=1:W
%         out_threshold(i,j)=1/out_threshold(i,j);
%     end
% end
for i=1:H
    for j=1:W
        out_threshold(i,j)=1/out_threshold(i,j);
    end
end
out_S=out_threshold;
%图像大小为H,W
out_x=reshape(out_threshold,[1,H*W]);%矩阵降维，数据按照列的顺序进行填充成为一维矩阵 即第 x个数据=j*H+i
%取倒数

[lat,I] = sort(out_x);  
I(lat==Inf)=[];%删去I中的inf位置，可以认为该位置不发出脉冲
lat(lat==inf)=[];
%I中存储的是索引
[X,Y] = ind2sub([H,W],I);        %将I所存的向量序数转化为矩阵中的行列位置    XY中为out_x中发出脉冲的索引
[~,I_num]=size(I);
out_max=max(lat);%输出最大值
out_min=min(lat);%输出最小值

t_step=zeros(size(out_S))*total_time;
for i=1:I_num
t_step(X(i),Y(i))=floor((out_max-out_S(X(i),Y(i)))/(out_max-out_min)*(total_time-num_layers))+1;%t_step存储了发出脉冲时刻的值
end

M = zeros(H,W,total_time );
for K=1:total_time
    for i=1:H
        for j=1:W
            if t_step(i,j)==K
                M(i,j,K)=1;  
            end
        end
    end
end
end

