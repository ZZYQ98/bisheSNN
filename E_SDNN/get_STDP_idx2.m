function [STDP_index,STDP_inh,STDP_counter] = get_STDP_idx2(valid,STDP_index,STDP_inh,STDP_counter,offset,STDP_per_layer,t)
[Si,Sj,~]=size(S);
%STDP_index为之前定义的用于存储将发生STDP权值更新的神经元的位置。
%找到可以进行STDP的神经元的位置
[mxv,mxi]=max(valid,[],3);
maxV=max(max(mxv));
while sum(sum(maxV))~=0
     [maxM,maxN]=find(maxV==mxv);
     maxM=maxM(1); maxN=maxN(1);
     maxK=mxi(maxM,maxN);
    if maxV>0 && valid(maxM,maxN,maxK)~=0 && STDP_counter<STDP_per_layer%可以进行STDP学习
        STDP_counter=STDP_counter+1;
         STDP_index{STDP_counter}=[maxM,maxN,maxK,t];%更新index矩阵，内容为可以发生STDP学习的位置，以及对应的发出脉冲，产生学习的时间 
         
         %而后进行STDP矩阵抑制，更新STDP_inh          
         %发生STDP的位置为S矩阵中的（Mmax，Nmax，D）位置
         if maxM-offset<1
             inh_left=1;
         else
             inh_left=maxM-offset;
         end

         if maxM+offset>Si
             inh_right=Si;
         else
             inh_right=maxM+offset;
         end

         if maxN-offset<1
             inh_up=1;
         else
             inh_up=maxN-offset;
         end
         if maxN+offset>Sj
             inh_down=Sj;
         else
             inh_down=maxN+offset;
         end 
        valid(inh_left:inh_right,inh_up:inh_down,:)=0;
        valid(:,:,maxK)=0;
        
        STDP_inh(inh_left:inh_right,inh_up:inh_down,:)=0;%STDP学习侧抑制
        STDP_inh(:,:,maxK)=0;%STDP学习相同通道抑制
        
        [mxv,mxi]=max(valid,[],3);
         maxV=max(max(mxv));
         
    end
    if STDP_counter==STDP_per_layer
        break
    end
end   


end