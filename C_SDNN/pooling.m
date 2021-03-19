function [S] = pooling(S,s,w,stride,th)
%V_tmp=zeros()
%   此处显示详细说明
[wi,wj,wm]=size(w);
[si,sj,sk]=size(S);
s=double(s);
V_tmp=zeros(si,sj,sk);
S=zeros(size(S));
for i=1:si
    for j=1:sj
        for k=1:sk
            pooling_s=s((i-1)*stride+1:(i-1)*stride+wi,(j-1)*stride+1:(j-1)*stride+wj,k);
            pooling_m=w(:,:,k).*pooling_s;
            max_num=max(max(pooling_m));
            V_tmp(i,j,k)=max_num;
            if V_tmp(i,j,k)>th
                S(i,j,k)=1;
            end
        end
    end
end

end

