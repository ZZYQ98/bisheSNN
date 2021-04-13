function [weights]=train_SDNN(weights,layers,network_struct,spike_times_learn,DoG_params,STDP_params,num_img_learn,learnable_layers,total_time,deta_STDP_minus,deta_STDP_plus)
%UNTITLED2 此处显示有关此函数的摘要.
%   此处显示详细说明
% STDP_per_layer=STDP_params.STDP_per_layer;
% offset_STDP=STDP_params.offset_STDP;
[~,num_layers]=size(network_struct);
max_iter=STDP_params.max_iter;
curr_lay_idx=1;
learning_layer=learnable_layers(1);%训练层对应的层数
counter=1;
n=1;
 fprintf('-------------------- STARTING LEARNING---------------------\n')             %开始训练，之后进行迭代
 for i=1:max_iter  %max_iter 为最大迭代次数
     perc=i/max_iter;
     fprintf('---------------------LEARNING PROGRESS %1.0f/%1.0f --- %2.4f-------------------- \n',i,max_iter,perc)  %显示当前的训练进度
      
      
     if counter>STDP_params.max_learning_iter(learning_layer)      %max_learning_iter由输入参数定义，表示最大的迭代次数
        curr_lay_idx=curr_lay_idx+1;%切换到下一个学习层         
        learning_layer=learnable_layers(curr_lay_idx);%learning layer的定义，得到用于当前学习的矩阵

        counter=1;
     end
      counter=counter+1;
     %调用函数 reset_layers
     layers=reset_layers(layers,num_layers);%将所有的层进行恢复
     
      %得到输入脉冲矩阵
     path_img=spike_times_learn{n};
      if n<num_img_learn
          n=n+1;
      else
          n=1;
      end    
     st=DoG_filter_to_st(path_img,DoG_params.DoG_size,DoG_params.img_size,total_time,num_layers);%  st = spike_time 输入脉冲时间

     layers_buff=init_layers(network_struct);%流水线结构
     weights=train_step3( weights,layers,layers_buff,network_struct,total_time,learning_layer,st,STDP_params.STDP_per_layer,deta_STDP_minus,deta_STDP_plus,STDP_params.offset); %调用 函数train_step()  输入脉冲为st，包含了时间信息，针对输入脉冲开始进行权值训练

 end
    fprintf('---------LEARNING PROGRESS %2.3f------------- \n',perc)
     
    fprintf('-------------------- FINISHED LEARNING---------------------\n')

end

