function [rate] = correct_rate(label,result,num)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
counter=0;
for i=1:num
    if label(i)==result(i)
        counter=counter+1;
    end
end
rate=counter/num;
end

