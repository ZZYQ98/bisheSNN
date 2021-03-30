function [M] = DoG_filter_to_st( path_img,filt,img_size,total_time)
%UNTITLED5 此处显示有关此函数的摘要
%   此处显示详细说明
image=imread(path_img);
image=imresize(image,[img_size.img_sizeH img_size.img_sizeW]);%对图片大小进行调整
image_for_DoG=double(image);
%对图像进行滤波
out1=imfilter(image_for_DoG,filt,'replicate','same','conv');
out1=mapminmax(out1,0,1);%归一化处理
%转化为脉冲发放时间
M=Matlab_rank_order_coding_mitrax(out1,total_time);
end

