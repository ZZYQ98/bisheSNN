function [weights]=train_SDNN(weights,layers,network_struct,spike_times_learn,DoG_params,STDP_params,num_img_learn,learnable_layers,learn_buffer,total_time,deta_STDP_minus,deta_STDP_plus)
global DoG
%UNTITLED2 �˴���ʾ�йش˺�����ժҪ.
%   �˴���ʾ��ϸ˵��
% STDP_per_layer=STDP_params.STDP_per_layer;
% offset_STDP=STDP_params.offset_STDP;
[~,num_layers]=size(network_struct);
max_iter=STDP_params.max_iter;
curr_lay_idx=1;
curr_img=0;%���뼴Ϊ�������������
learning_layer=learnable_layers(1);%ѵ�����Ӧ�Ĳ���
counter=0;
n=3;
filt=DOG_creat(DoG_params);
 fprintf('-------------------- STARTING LEARNING---------------------\n')             %��ʼѵ����֮����е���
 for i=1:max_iter  %max_iter Ϊ����������
     perc=i/max_iter;
     fprintf('---------------------LEARNING PROGRESS %1.0f/%1.0f --- %2.4f-------------------- \n',i,max_iter,perc)  %��ʾ��ǰ��ѵ������
      
      
     if counter>STDP_params.max_learning_iter(learning_layer)      %max_learning_iter������������壬��ʾ���ĵ�������
         curr_lay_idx=curr_lay_idx+1;%�л�����һ��ѧϰ��
         learning_layer=learnable_layers(curr_lay_idx);%learning layer�Ķ��壬�õ����ڵ�ǰѧϰ�ľ���
         counter=0;
     end
      counter=counter+1;
     %���ú��� reset_layers
     reset_layers(layers,num_layers);%�����еĲ���лָ�
     
      %�õ������������
     if DoG  % �Ƿ�����˲�
          path_img=learn_buffer{n};
              if n<num_img_learn
                  n=n+1;
              else
                  n=3;
              end    
             st=DoG_filter_to_st(path_img,filt,DoG_params.img_size,total_time);%  st = spike_time ��������ʱ��
     else
         st=spike_times_learn(curr_img,:,:,:,:);  %�˴���spike_times_learn�������ڶ�ȡ�����ݣ��������˲��õ�
          if curr_img+1<num_img_learn
             curr_img=curr_img+1;
          else
             curr_img=0;
          end
     end
     layers_buff=init_layers(network_struct);%��ˮ�߽ṹ
     weights=train_step2( weights,layers,layers_buff,network_struct,total_time,learning_layer,st,STDP_params.STDP_per_layer,deta_STDP_minus,deta_STDP_plus,STDP_params.offset); %���� ����train_step()  ��������Ϊst��������ʱ����Ϣ������������忪ʼ����Ȩֵѵ��

 end
    fprintf('---------LEARNING PROGRESS %2.3f------------- \n',perc)
     
    fprintf('-------------------- FINISHED LEARNING---------------------')

end

