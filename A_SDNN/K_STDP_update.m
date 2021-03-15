function [K_STDP] =K_STDP_update(spike_array,K_STDP)
%K_STDP ¸üÐÂ³ÌÐò
global STDP_time_pre
[Ki,Kj,Kk]=size(K_STDP);
 for k=1:Kk
     for i=1:Ki
         for j=1:Kj
             if spike_array(Ki,Kj,Kk)==1
                 K_STDP(Ki,Kj,Kk)=STDP_time_pre;
             end
         end
     end
 end
 
             
end

