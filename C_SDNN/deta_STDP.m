function [ deta] = deta_STDP( a,time,tao)
%UNTITLED2 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
deta=zeros(1,time);
for i=1:time
    deta(i)=a*exp(-(time-i)/tao);
end

end

