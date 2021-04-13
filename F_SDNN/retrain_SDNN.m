function [weights]=retrain_SDNN(weights,layers,network_struct,spike_times_learn,DoG_params,STDP_params,num_img_learn,total_time,STDP_time,retrain_params,label)
%强化学习
                         %retrain_params 为强化学习的学习速率等常�?
 %得到权�?更新dw查找�?
deta_STDP_minus_r=deta_STDP(retrain_params.a_minus_r,STDP_time,retrain_params.tao_minus_r); 
deta_STDP_plus_r =deta_STDP(retrain_params.a_plus_r ,STDP_time,retrain_params.tao_plus_r); 
deta_STDP_minus_p=deta_STDP(retrain_params.a_minus_p,STDP_time,retrain_params.tao_minus_p); 
deta_STDP_plus_p =deta_STDP(retrain_params.a_plus_p ,STDP_time,retrain_params.tao_plus_p); 

global DoG
[~,num_layers]=size(network_struct);
max_iter=retrain_params.retrain_iter;
curr_img=0;%输入即为脉冲矩阵的情况下
n=0;
 fprintf('-------------------- STARTING RETRAIN---------------------\n')  
 for i=1:max_iter  %max_iter 
     perc=i/max_iter;
     fprintf('---------------------LEARNING PROGRESS %1.0f/%1.0f --- %2.4f-------------------- \n',i,max_iter,perc)
     %Ȩֵ�洢--------------------------------------------
     if i==200
         save('weights_retrain_200.mat','weights');
     elseif i==400
         save('weights_retrain_400.mat','weights');
     elseif i==600
         save('weights_retrain_600.mat','weights');
     elseif i==800
         save('weights_retrain_800.mat','weights');
     elseif i==1000
         save('weights_retrain_1000.mat','weights');
     end
     %---------------------------------------------------
     learning_layer=4; 
     layers=reset_layers(layers,num_layers);
     if DoG 
          n=n+1;
        if n<=num_img_learn
            path_img=spike_times_learn{n};  
         else
             n=1;
             path_img=spike_times_learn{n};  
         end    
         st=DoG_filter_to_st(path_img,DoG_params.DoG_size,DoG_params.img_size,total_time,num_layers);%  st = spike_time 输入脉冲时间
     else
         st=spike_times_learn(curr_img,:,:,:,:);  %此处的spike_times_learn是来自于读取的数据，而不用滤波得�?
          if curr_img+1<num_img_learn
             curr_img=curr_img+1;
          else
             curr_img=0;
          end
     end
     layers_buff=init_layers(network_struct);
     weights=retrain_step( weights,layers,layers_buff,network_struct,total_time,learning_layer,st,STDP_params.STDP_per_layer,...
             deta_STDP_minus_p,deta_STDP_plus_p,deta_STDP_minus_r,deta_STDP_plus_r,STDP_params.offset,label(n));

 end
    fprintf('---------------------LEARNING PROGRESS %2.3f------------- \n',perc)
     
    fprintf('-------------------- FINISHED LEARNING---------------------\n')

end