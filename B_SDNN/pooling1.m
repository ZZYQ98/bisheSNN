function [] = pooling1(ii,s,w,stride,th)
global layers

%V_tmp=zeros()
%   此处显示详细说明
[wi,wj]=size(w);
[si,sj,sk]=size(layers{ii}.S);
s=double(s);
for k=1:sk
    for i=1:si
        for j=1:sj
            pooling_s=s((i-1)*stride+1:(i-1)*stride+wi,(j-1)*stride+1:(j-1)*stride+wj,k);
            pooling_m=w.*pooling_s;
            if  max(max(pooling_m))>th
                layers{ii}.S(i,j,k)=1;
            end
        end
    end
end

end

