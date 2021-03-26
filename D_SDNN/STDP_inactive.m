function [ weights,weight_STDP_flag] = STDP_inactive(weights,weight_STDP_flag,deta_STDP_minus)
%UNTITLED2 此处显示有关此函数的摘要
[H,W,D]=size(weights);
for k=1:D
          for i=1:H
              for j=1:W
                  if weight_STDP_flag(i,j,k)==1
                      weights(i,j,k)=weights(i,j,k)-deta_STDP_minus(1);
                      weight_STDP_flag(i,j,k)=0;
                      if weights(i,j,k)<0.000001
                          weights(i,j,k)=0.000001;
                      end
                  end
              end 
          end 
end 
end

