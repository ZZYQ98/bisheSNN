function [ ]=K_STDP_refresh_1()
global STDP_time_pre
global layers
%UNTITLED2 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
[H,W,D]=size(layers{1}.S);

for k=1:D
    for i=1:H
        for j=1:W
            if layers{1}.S(i,j,k)==1
            layers{1}.K_STDP(i,j,k)=STDP_time_pre;
            end
        end
    end
end
end

