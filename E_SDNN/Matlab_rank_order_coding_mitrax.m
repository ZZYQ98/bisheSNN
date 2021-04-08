%Convert to spike times ±àÂë       for matlab
function [M]=Matlab_rank_order_coding_mitrax(out1,total_time)
[m,n]=size(out1);
N=ones(m,n);
Out1=N-out1;
Out1=Out1*35;
Out1=uint16(Out1);
M = zeros(m,n,total_time );
for K=1:total_time
    for i=1:m
        for j=1:n
            if Out1(i,j)==K
%                 i_2=dec2bin(i,8);%  dec2bin(D,N) produces a binary representation with at least N bits.
%                 j_2=dec2bin(j,8);
%                 K_2=dec2bin(K,10);
                M(i,j,K)=1;  
            end
        end
    end
end