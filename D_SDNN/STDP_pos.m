function [weights,weight_STDP_flag] = STDP_pos(S,weights,V_buff,K_STDP_pre,stride,pad,weight_STDP_flag,deta_STDP_plus,offset)    
%定义STDP_inh矩阵，用于进行层间STDP抑制
global STDP_Flag_p
[Si,Sj,Sk]=size(S);
STDP_inh=ones(Si,Sj);
[~,~,Ds]=size(K_STDP_pre);
K_STDP_pre_pad=pad_for_conv( K_STDP_pre,pad );
[HH,WW,~]=size(weights);

%get_STDP_index
for k=1:Sk
    valid=double(S(:,:,k)).*V_buff(:,:,k).*STDP_inh;
    maxV=max(max(valid));
    if maxV~=0 && STDP_Flag_p(k)~=0
    [Mmax,Nmax]=find(maxV==valid);
    V_buff(Mmax,Nmax,k)=0;
    local_K_STDP=K_STDP_pre_pad((Mmax-1)*stride+1:(Mmax-1)*stride+HH,(Nmax-1)*stride+1:(Nmax-1)*stride+WW,:);%前一层对应的映射位置 大小为HH*WW*Ds
    for I=1:HH
         for J=1:WW
             for K=1:Ds    
                 if local_K_STDP(I,J,K)>0 && STDP_Flag_p(k)>0
                     weights(I,J,k)=weights(I,J,k)+deta_STDP_plus(local_K_STDP(I,J,K));  %对这一层的脉冲矩阵进行权值更新
                     weight_STDP_flag(I,J,k)=0;%设置为兴奋状态
                     STDP_Flag_p(k)=STDP_Flag_p(k)-1;
                     if weights(I,J,k)>0.999999
                        weights(I,J,k)=0.999999;
                     end
                     %而后进行STDP矩阵抑制，更新STDP_inh          
                     %发生STDP的位置为S矩阵中的（Mmax，Nmax）位置
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
                    STDP_inh(inh_left:inh_right,inh_up:inh_down)=0; 
                 end
             end
         end
    end
    end
end

end



