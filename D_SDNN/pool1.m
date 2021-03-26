function [S] = pool(S,s,weight,V,stride,th)
%池化操作
[wi,wj,~]=size(weight);
[si,sj,sk]=size(S);
V_buff=zeros(size(V));
s=double(s);
for k=1:sk
    for i=1:si
        for j=1:sj
            pooling_s=s((i-1)*stride+1:(i-1)*stride+wi,(j-1)*stride+1:(j-1)*stride+wj,k);
            V(i,j,k)=sum(sum(weight(:,:,k).*pooling_s));
            if  V(i,j,k)>th  %达到阈值且不发生侧抑制
                V_buff(i,j,k)=V(i,j,k);
                V(i,j,k)=0;%膜电位置为零
            end 
        end
    end  
end

end

