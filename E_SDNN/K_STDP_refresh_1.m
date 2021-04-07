function [ K_STDP ]=K_STDP_refresh_1(S,K_STDP,t)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
[H,W,D]=size(S);
for k=1:D
    for i=1:H
        for j=1:W
            if S(i,j,k)==1
            K_STDP(i,j,k)=t;
            end
        end
    end
end
end

