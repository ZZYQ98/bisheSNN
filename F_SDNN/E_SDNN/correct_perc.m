function [perc] = correct_perc(label,SVMresult)
%UNTITLED2 此处显示有关此函数的摘要
sum=0;
[~,total_num]=size(label);
for i=1:total_num
if SVMresult{i,1}(1)==label{1,i}(1)
sum=sum+1;
end
perc=(sum)/total_num;
end

