function [ image_pad ] = pad_for_K_STDP( input_image,pad )
%UNTITLED5 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
global total_time
[H,W,D]=size(input_image);
 for j=1:D
            image=input_image(:,:,j);
            aUp = ones(pad, pad + W + pad)*total_time;   %
            aLeft = ones( H, pad )*total_time;           %
            aMiddle = [aLeft, image, aLeft];    %
            tempImage = [aUp; aMiddle; aUp];    %��չ֮���ͼ������
            if j==1
                 image_pad=tempImage;
            else
                 image_pad=cat(3,image_pad,tempImage);
            end
 end

end

