function [M] = DoG_filter_to_st( path_img,filt_size,img_size,total_time,num_layers)
%UNTITLED5 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
H=img_size.img_sizeH;
W=img_size.img_sizeW;
image=imread(path_img);
image=imresize(image,[H W]);%��ͼƬ��С���е���
image_for_DoG=double(image);
%��ͼ������˲�
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
%ͼ���СΪH,W
out_x=reshape(out_threshold,[1,H*W]);%����ά�����ݰ����е�˳���������Ϊһά���� ���� x������=j*H+i
%ȡ����

[lat,I] = sort(out_x);  
I(lat==Inf)=[];%ɾȥI�е�infλ�ã�������Ϊ��λ�ò���������
lat(lat==inf)=[];
%I�д洢��������
[X,Y] = ind2sub([H,W],I);        %��I�������������ת��Ϊ�����е�����λ��    XY��Ϊout_x�з������������
[~,I_num]=size(I);
out_max=max(lat);%������ֵ
out_min=min(lat);%�����Сֵ

t_step=zeros(size(out_S))*total_time;
for i=1:I_num
t_step(X(i),Y(i))=floor((out_max-out_S(X(i),Y(i)))/(out_max-out_min)*(total_time-num_layers))+1;%t_step�洢�˷�������ʱ�̵�ֵ
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

