function [M] = DoG_filter_to_st( path_img,filt,img_size,total_time)
%UNTITLED5 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
image=imread(path_img);
image=imresize(image,[img_size.img_sizeH img_size.img_sizeW]);%��ͼƬ��С���е���
image_for_DoG=double(image);
%��ͼ������˲�
out1=imfilter(image_for_DoG,filt,'replicate','same','conv');
out1=mapminmax(out1,0,1);%��һ������
%ת��Ϊ���巢��ʱ��
M=Matlab_rank_order_coding_mitrax(out1,total_time);
end

