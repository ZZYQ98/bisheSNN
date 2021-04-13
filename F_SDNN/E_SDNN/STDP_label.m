function [weights] = STDP_label(layers,learning_layer,STDP_index,weights,network_struct,deta_STDP_minus_r ,deta_STDP_plus_r,deta_STDP_minus_p,deta_STDP_plus_p,label)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
pad=network_struct{learning_layer}.pad; %将s进行周围补零操作，以便于卷积  s的规模为H×W×D
stride=network_struct{learning_layer}.stride;
[~,~,Sz]=size(layers{learning_layer}.S);
K_STDP=layers{learning_layer-1}.K_STDP; %学习层上�?��的脉冲输入时间矩�?
K_STDP_pad=pad_for_conv( K_STDP,pad );
w=weights{learning_layer};

%  Sk  为输出脉冲的层数，与权�?矩阵的个数有�?
[H,W,D,~]=size(w);
for sk=1:Sz
  if STDP_index{sk}(1)>0
     si=STDP_index{sk}(2);
     sj=STDP_index{sk}(3); %sk=K
     t=STDP_index{sk}(4); %即将进行STDP的位置，按层得到
     local_K_STDP=K_STDP_pad((si-1)*stride+1:(si-1)*stride+H,(sj-1)*stride+1:(sj-1)*stride+W,:);%找到发生更新的位置对应的发生映射关系的前�?��的神经元
     
     if label==1
         if sk<=Sz/2
                    for k=1:D
                        for i=1:H
                            for j=1:W
                                if local_K_STDP(i,j,k)==0
                                    dw=-deta_STDP_minus_r(1)*w(i,j,k,sk);
                                else
                                    if local_K_STDP(i,j,k)>=t
                                        dw=-deta_STDP_minus_r(local_K_STDP(i,j,k)-t+1)*w(i,j,k,sk);
                                    elseif local_K_STDP(i,j,k)<t
                                        dw=deta_STDP_plus_r(t-local_K_STDP(i,j,k))*(1-w(i,j,k,sk));
                                    end
                                end
                                w(i,j,k,sk)=w(i,j,k,sk)+dw;
                                if w(i,j,k,sk)>0.999999
                                    w(i,j,k,sk)=0.999999;
                                elseif w(i,j,k,sk)<0.000001
                                    w(i,j,k,sk)=0.000001;
                                end  
                            end
                        end
                    end
         else
                    for k=1:D
                        for i=1:H
                            for j=1:W
                                if local_K_STDP(i,j,k)==0
                                    dw=-deta_STDP_minus_p(1)*w(i,j,k,sk);
                                else
                                    if local_K_STDP(i,j,k)>=t
                                        dw=-deta_STDP_minus_p(local_K_STDP(i,j,k)-t+1)*w(i,j,k,sk);
                                    elseif local_K_STDP(i,j,k)<t
                                        dw=deta_STDP_plus_p(t-local_K_STDP(i,j,k))*(1-w(i,j,k,sk));
                                    end
                                end
                                w(i,j,k,sk)=w(i,j,k,sk)+dw;
                                if w(i,j,k,sk)>0.999999
                                    w(i,j,k,sk)=0.999999;
                                elseif w(i,j,k,sk)<0.000001
                                    w(i,j,k,sk)=0.000001;
                                end  
                            end
                        end
                    end
         end
     end
     
      
     if label==2
         if sk>Sz/2
                    for k=1:D
                        for i=1:H
                            for j=1:W
                                if local_K_STDP(i,j,k)==0
                                    dw=-deta_STDP_minus_r(1)*w(i,j,k,sk);
                                else
                                    if local_K_STDP(i,j,k)>=t
                                        dw=-deta_STDP_minus_r(local_K_STDP(i,j,k)-t+1)*w(i,j,k,sk);
                                    elseif local_K_STDP(i,j,k)<t
                                        dw=deta_STDP_plus_r(t-local_K_STDP(i,j,k))*(1-w(i,j,k,sk));
                                    end
                                end
                                w(i,j,k,sk)=w(i,j,k,sk)+dw;
                                if w(i,j,k,sk)>0.999999
                                    w(i,j,k,sk)=0.999999;
                                elseif w(i,j,k,sk)<0.000001
                                    w(i,j,k,sk)=0.000001;
                                end  
                            end
                        end
                    end
         else
                    for k=1:D
                        for i=1:H
                            for j=1:W
                                if local_K_STDP(i,j,k)==0
                                    dw=-deta_STDP_minus_p(1);%*w(i,j,k,sk);
                                else
                                    if local_K_STDP(i,j,k)>=t
                                        dw=-deta_STDP_minus_p(local_K_STDP(i,j,k)-t+1)*w(i,j,k,sk);
                                    elseif local_K_STDP(i,j,k)<t
                                        dw=deta_STDP_plus_p(t-local_K_STDP(i,j,k))*(1-w(i,j,k,sk));
                                    end
                                end
                                w(i,j,k,sk)=w(i,j,k,sk)+dw;
                                if w(i,j,k,sk)>0.999999
                                    w(i,j,k,sk)=0.999999;
                                elseif w(i,j,k,sk)<0.000001
                                    w(i,j,k,sk)=0.000001;
                                end  
                            end
                        end
                    end
         end
     end
     
  end 
end
weights{learning_layer}=w;
end

