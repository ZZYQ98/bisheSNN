function [STDP_index,STDP_inh] = get_STDP_idx1(S,V_buff,STDP_index,STDP_inh,offset,t)
global STDP_Flag
[Si,Sj,~]=size(S);

valid=double(S(:,:,:)).*V_buff(:,:,:).*STDP_inh;%可以进行STDP的神经元 

%valid大小与S大小相同

    %找到神经元位置
     [maxval,maxidx]=max(valid,[],3);
     maxV=max(max(maxval));
while maxV~=0
     [maxM,maxN]=find(maxV==maxval);
     maxM=maxM(1); maxN=maxN(1);
     maxK=maxidx(maxM,maxN);
    if maxV>0 && valid(maxM,maxN,maxK)~=0&& STDP_Flag(maxK)~=0%可以进行STDP学习
          STDP_index{maxK}=[maxM,maxN,maxK,t];%更新index矩阵，内容为可以发生STDP学习的位置，以及对应的发出脉冲，产生学习的时间
          STDP_Flag(maxK)=STDP_Flag(maxK)-1;
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
        
        [maxval,maxidx]=max(valid,[],3);
         maxV=max(max(maxval));
         
    end
    if sum(STDP_Flag)==0
        break
    end
end   


end