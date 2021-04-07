function [STDP_inh] = STDP_inh1(valid,STDP_inh,STDP_index,offset)
%STDP学习抑制
[Si,Sj,D]=size(valid);
for Sz=1:D
    if STDP_index{Sz}(1)>0&&sum(sum(STDP_inh(:,:,Sz)))~=0
    maxM=STDP_index{Sz}(2);
    maxN=STDP_index{Sz}(3);
    
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
        
        STDP_inh(inh_left:inh_right,inh_up:inh_down,:)=0;%STDP学习侧抑制
        STDP_inh(:,:,Sz)=0;%STDP学习相同通道抑制
    end
end

