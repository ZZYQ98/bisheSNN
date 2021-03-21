function [ ] = STDP_inactive(learning_layer)
%UNTITLED2 此处显示有关此函数的摘要
global weights
global deta_STDP_minus
global weight_STDP_flag
[H,W,D]=size(weights{learning_layer});
for k=1:D
          for i=1:H
              for j=1:W
                  if weight_STDP_flag(i,j,k)==1
                      weights{learning_layer}(i,j,k)=weights{learning_layer}(i,j,k)-deta_STDP_minus(1);
                      weight_STDP_flag(i,j,k)=0;
                      if weights{learning_layer}(i,j,k)<0.000001
                          weights{learning_layer}(i,j,k)=0.000001;
                      end
                  end
              end 
          end 
end 
end

