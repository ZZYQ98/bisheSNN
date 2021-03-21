function [] = pooling1(ii,s,stride,th)
global layers
global weights
global STDP_time_pre
w=weights{ii};
[wi,wj,~]=size(w);
[si,sj,sk]=size(layers{ii}.S);
s=double(s);
for k=1:sk
    for i=1:si
        for j=1:sj
            pooling_s=s((i-1)*stride+1:(i-1)*stride+wi,(j-1)*stride+1:(j-1)*stride+wj,k);
            layers{ii}.V(i,j,k)=w(:,:,k).*pooling_s;
        end
    end
     max_V=max(max( layers{ii}.V(:,:,k)));
     if  max_V>th && layers{ii}.K_inh(i,j)==1
         [maxM,maxN] = find(V_buff==max_V);
         layers{ii}.S(maxM,maxN,k)=1;
         layers{ii}.K_inh(maxM,maxN)=0;
         layers{ii}.K_STDP(maxM,maxN,k)=STDP_time_pre;  
     end 
    
end

end

