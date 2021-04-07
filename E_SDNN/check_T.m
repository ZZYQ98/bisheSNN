function [label] = check_T(label_T_input)
%UNTITLED5 此处显示有关此函数的摘要
%   此处显示详细说明
[N,Sz]=size(label_T_input);
label=ones(1,N);
for i=1:N
    label_T=label_T_input(i,:);
    kind=5;
    T_min=min(label_T);
    if sum(label_T(1:kind)==T_min)>sum(label_T(kind+1:Sz)==T_min)
        T_label=1;
    elseif sum(label_T(1:kind)==T_min)<sum(label_T(kind+1:Sz)==T_min)
        T_label=2;
    else
        T_label=0;
    end
    label(i)=T_label;
end

