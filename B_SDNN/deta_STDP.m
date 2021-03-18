function [ deta] = deta_STDP( a,time,tao)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
deta=zeros(1,time);
for i=1:time
    deta(i)=a*exp(-(time-i)/tao);
end

end

