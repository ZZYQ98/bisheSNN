function [S] = pool(S,s,weight,stride,th)
%池化操作
[wi,wj,~]=size(weight);
[si,sj,sk]=size(S);
s=double(s);
for k=1:sk
    for i=1:si
        for j=1:sj
            pooling_s=s((i-1)*stride+1:(i-1)*stride+wi,(j-1)*stride+1:(j-1)*stride+wj,k);
            result=sum(sum(weight(:,:,k).*pooling_s));
            if  result>th  %达到阈值
                S(i,j,k)=1;
            end 
        end
    end  
end

end

