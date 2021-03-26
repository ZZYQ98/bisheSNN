function [STDP_index,STDP_inh] = get_STDP_idx(S,V_buff,STDP_index,STDP_inh,offset,t)
global STDP_Flag
[Si,Sj,D]=size(S);
%   此处显示详细说明
valid=double(S(:,:,:)).*V_buff(:,:,:).*STDP_inh;%可以进行STDP的神经元 
if sum(sum(sum(valid)))>0
  for k=1:D    
        valid_layer=valid(:,:,k);
        maxV=max(max(valid_layer));
        if maxV~=0 && STDP_Flag(k)~=0%可以进行STDP学习
              [maxM,maxN]=find(maxV==valid_layer);
              Mmax=maxM(1);
              Nmax=maxN(1);
              STDP_index{k}=[Mmax,Nmax,k,t];%更新index矩阵，内容为可以发生STDP学习的位置，以及对应的发生学习的时间
              STDP_Flag(k)=STDP_Flag(k)-1;
             %而后进行STDP矩阵抑制，更新STDP_inh          
             %发生STDP的位置为S矩阵中的（Mmax，Nmax，D）位置
             if Mmax-offset<1
                 inh_left=1;
             else
                 inh_left=Mmax-offset;
             end

             if Mmax+offset>Si
                 inh_right=Si;
             else
                 inh_right=Mmax+offset;
             end

             if Nmax-offset<1
                 inh_up=1;
             else
                 inh_up=Nmax-offset;
             end
             if Nmax+offset>Sj
                 inh_down=Sj;
             else
                 inh_down=Nmax+offset;
             end
            STDP_inh(inh_left:inh_right,inh_up:inh_down,:)=0; 
            valid(inh_left:inh_right,inh_up:inh_down,:)=0;
        end
  end  
end
end
