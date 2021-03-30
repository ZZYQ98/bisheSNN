function [outputArg1,outputArg2] = STDP_inh(inputArg1,inputArg2)
%若某个位置将发生STDP 则产生对于周围神经元的抑制效应
%   此处显示详细说明

STDP_I=ones(size(S));一个S大小的矩阵，记录那个位置可以发生STDP,在发生STDP后进行

for D=1:DD     %DD为S的深度
    V_buff_lay=V_buff(:,:,D);
V_max=max(max(V_buff_lay));
[Mmax,Nmax]=find(V_max==V_buff_lay);
end
end

