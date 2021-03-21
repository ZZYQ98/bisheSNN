function [] = pooling1(ii,s,stride,th)
global layers
global weights
global STDP_time_pre
w=weights{ii};
[wi,wj,~]=size(w);
[si,sj,sk]=size(layers{ii}.S);
V_buff=zeros(si,sj);
s=double(s);
for k=1:sk
    for i=1:si
        for j=1:sj
            pooling_s=s((i-1)*stride+1:(i-1)*stride+wi,(j-1)*stride+1:(j-1)*stride+wj,k);
            layers{ii}.V(i,j,k)=sum(sum(w(:,:,k).*pooling_s));
            if  layers{ii}.V(i,j,k)>th && layers{ii}.K_inh(i,j)==1  %达到阈值且不发生侧抑制时
                V_buff(i,j)=layers{ii}.V(i,j,k);
                layers{ii}.V(i,j,k)=0;%膜电位置为零
            end 
        end
    end
     max_V=max(max( layers{ii}.V(:,:,k)));
     if  max_V>th
         [maxM,maxN] = find(V_buff==max_V);
         layers{ii}.S(maxM,maxN,k)=1;
         layers{ii}.K_inh(maxM,maxN)=0;
         layers{ii}.K_STDP(maxM,maxN,k)=STDP_time_pre;  
     end 
    
end

end

