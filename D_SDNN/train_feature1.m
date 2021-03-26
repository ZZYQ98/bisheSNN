function [X_train] = train_feature1(weights,layers,network_struct,spike_times_train,DoG_params,num_img_learn,total_time)
global DoG
[~,num_layers]=size(network_struct);
curr_img=0;
n=3;
filt=DOG_creat1(DoG_params);
featrues_in_train=[];
%  X_train: Training features of size (N, M) where N is the number of training samples and M is the number of maps in the last layer
       network_struct{3}.th=100000; % Set threshold of last layer to inf         �ȶԲ�3����train
       fprintf('-------------------------------------------------------------\n')
       fprintf('--------------EXTRACTING TRAINING FEATURES-------------------\n')
       fprintf('-------------------------------------------------------------\n')
       for ii=1:num_img_train
           perc=ii/num_img_train;
            fprintf('---------------------TRAINING PROGRESS %2.3f----------------- \n',perc)
            %reset layers
            reset_layers(num_layers);
            
           if DoG   % �Ƿ����DoG��������������st
             path_img=spike_times_train{n};
              if n<num_img_train
                  n=n+1;
              else
                  n=3;
              end    
                 st=DoG_filter_to_st(path_img,filt,DoG_params.img_size,total_time);%  st = spike_time ��������ʱ��
           else
                 st=spike_times_train(curr_img,:,:,:,:);  %�˴���spike_times_learn�������ڶ�ȡ�����ݣ��������˲��õ�
                 if curr_img+1<num_img_learn
                   curr_img=curr_img+1;
                 else
                  curr_img=0;
                 end
           end
          %���崫������
        for t=1:total_time+num_layers      %����ʱ��˳��ʹ���������ѧϰ

            layers{1}.S=st(:,:,t);%stΪ��������尴��ʱ��ֲ��ľ���
            layers{1}.K_STDP=K_STDP_refresh_1(layers{1}.S,layers{1}.K_STDP,t);%�����K_STDP������и���

            %t-1ʱ�̵�ֵ����layers�У���ʼ����¾�Ϊ��ʼ��ֵ
            %tʱ�̵�ֵ����t-1ʱ��ǰһ���ֵ����
            for i=2:learning_layer    
                V=layers{i}.V;      %Ĥ��λ����
                S=layers{i}.S;      %����������
                K_STDP=layers{i}.K_STDP;
                K_inh=layers{i}.K_inh;%�����ƾ���
                pad=network_struct{i}.pad; %��s������Χ����������Ա��ھ��  s�Ĺ�ģΪH��W��D
                th=network_struct{i}.th;
                stride=network_struct{i}.stride;
                [ s_pad ]=pad_for_conv( layers{i-1}.S,pad );    %s_padΪ����ǰһ��ǰһʱ�̵��������õ���ֵ����ģΪ�����ģ�߽�+���㣬������֮����о������
                %���ݲ�ͬ�Ĳ����һЩ����

                if strcmp( network_struct{i}.Type,'conv' )%�ò�Ϊ�����ʱ  
                    [V,S,V_buff]=conv_only( s_pad,weights{i},V,layers{i}.S,stride,th);%V_buffΪ�������λ�ö�Ӧ��Ĥ��ѹ��λ
                     %���������Ϊs����pool����input�������ΪS������һ��������K_STDP
                     [S,K_inh,K_STDP] = lateral_inh1(V_buff,S,K_inh,K_STDP,t);
                elseif strcmp( network_struct{i}.Type,'pool' )%���ò�Ϊ�ز�ʱ
                    [S,V_buff] = pool(layers{i}.S,s_pad,weights{i},V,stride,th);
                    [S,K_inh,K_STDP] = lateral_inh1(V_buff,S,K_inh,K_STDP,t);
                    %pool����Ϊѧϰ�������㣬������������ͻ��ǰ��Ԫ��K_STDP����Ϊ�Ƿ񷢳�������STDP�ı�־��
                end
                layers{i}.S=S;
                layers{i}.V=V;
                layers{i}.K_STDP=K_STDP;       %K_STDP�����д洢���巢��ʱ��
                layers{i}.K_inh=K_inh;
            end
        end    
        
        % Obtain maximum potential per map in last layer      
        per_features_train=layers{num_layers}.V;%���һ��V��ֵ��һ��1*1*D����ά����
        [~,n_features]=size(sp_time);
        featrues_in_train=[featrues_in_train,per_features_train];%�����������
       end
       X_train=reshape(featrues_in_train,[num_img_train,n_features]);  %������ת��Ϊ������ʽ
       fprintf('---------------------TRAINING PROGRESS %2.3f----------------- \n',num_img_train/num_img_train)
       fprintf('-------------------------------------------------------------')
       fprintf('---------------TRAINING FEATURES EXTRACTED-------------------')
       fprintf('-------------------------------------------------------------')

end

