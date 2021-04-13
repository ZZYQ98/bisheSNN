function [X,T_features] = get_feature(weights,layers,network_struct,spike_times,num_img,DoG_params,total_time)
%���һ��N*M�ľ���NΪѵ������������MΪ���һ��Ĳ�������ÿһ�б���ѵ�����
[~,num_layers]=size(network_struct);
n=1; 
[~,~,n_featuers]=size(layers{num_layers}.V);
X=zeros(num_img,n_featuers);
T_features=zeros(num_layers,n_featuers);
Sz=n_featuers; %���һ���������Ȳ���



       
       fprintf('-------------------------------------------------------------\n')
       fprintf('--------------EXTRACTING TRAINING FEATURES-------------------\n')
       fprintf('-------------------------------------------------------------\n')
       for ii=1:num_img
           perc=ii/num_img;
            fprintf('---------------------TRAINING PROGRESS %2.3f----------------- \n',perc)
            %reset layers
            layers=reset_layers(layers,num_layers);
            layers_buff=init_layers(network_struct);
           T=(total_time+num_layers)*ones(1,Sz); %���ڴ洢������ʱ������� T
             path_img=spike_times{n};
              if n<num_img
                  n=n+1;
              else
                  n=1;
              end    
                 st=DoG_filter_to_st(path_img,DoG_params.DoG_size,DoG_params.img_size,total_time,num_layers);%  st = spike_time ��������ʱ��
           
%           [si,sj,sz]=size(layers{2}.S);
%           S_record=zeros(si,sj,sz);
       
%���崫������prop_step()----------------------------------------------------------------------------------------------------------------------------------------
            for t=1:total_time+num_layers       %����ʱ��˳��ʹ���������ѧϰ ������ô����ʱ�䣬���ܱ�֤��������������Ϣ���ݹ�����
              if t<=total_time
                layers{1}.S=st(:,:,t);%stΪ��������尴��ʱ��ֲ��ľ���
                layers{1}.K_STDP=K_STDP_refresh_1(layers{1}.S,layers{1}.K_STDP,t);%�����K_STDP������и���
              end
                %t-1ʱ�̵�ֵ����layers�У���ʼ����¾�Ϊ��ʼ��ֵ
                %tʱ�̵�ֵ����t-1ʱ��ǰһ���ֵ����
                for i=2:num_layers    
                    V=layers{i}.V;
                    s=layers_buff{i-1}.S;
                    K_inh=layers{i}.K_inh;
                    K_STDP=layers{i}.K_STDP;
                    pad=network_struct{i}.pad; %��s������Χ����������Ա��ھ��  s�Ĺ�ģΪH��W��D
                    th=network_struct{i}.th;
                    stride=network_struct{i}.stride;
                    [ s_pad ]=pad_for_conv( s,pad );    %t-1ʱ�̵�ǰһ����������
                    %s_padΪ����ǰһ��ǰһʱ�̵��������õ���ֵ����ģΪ�����ģ�߽�+���㣬������֮����о������
                    %���ݲ�ͬ�Ĳ����һЩ����

                    if strcmp( network_struct{i}.Type,'conv' )%�ò�Ϊ�����ʱ  
                        [ V_out , S_out ]=conv_only( s_pad, weights{i}, V ,stride,th);%V_out�а������������λ�ö�Ӧ��Ĥ��ѹ��λ,����get_STDP_index���ҵ�����STDPѧϰ����Ԫλ��
                         %���������Ϊs����pool����input�������ΪS������һ��������K_STDP
                         [S_out_inh ,K_inh_out, K_STDP_out] = lateral_inh1( V_out , S_out , K_inh, K_STDP,t);
                    elseif strcmp( network_struct{i}.Type,'pool' )%���ò�Ϊ�ز�ʱ
                        [S_out] = pool(layers{i}.S,s_pad,weights{i},stride,th);
                        [S_out_inh ,K_inh_out, K_STDP_out] = lateral_inh1(layers{i}.V, S_out, K_inh, K_STDP,t);
                        %pool����Ϊѧϰ�������㣬������������ͻ��ǰ��Ԫ��K_STDP����Ϊ�Ƿ񷢳�������STDP�ı�־��
                    end
                    %���������󣬴���һ����buff�е�ֵ���µĹ��̣�������һʱ�̴���
                    layers{i}.V=V_out;
                    layers{i}.K_STDP=K_STDP_out;
                    layers{i}.K_inh=K_inh_out;
                    layers{i}.S=S_out_inh;
                    if i==num_layers
                        for k=1:Sz
                            if sum(sum(layers{i}.S(:,:,k)))>0 && t<T(k)
                                T(k)=t;
                            end
                        end
                    end
                end
                %չʾ�������
                for j=1:num_layers
                    layers_buff{j}.S=layers{j}.S;
                end 
%                      S_record=S_record+layers{2}.S;
%                      imshow(sum(S_record,3))
            end
        % Obtain maximum potential per map in last layer      
        features=layers{num_layers}.V;%���һ��V��ֵ��һ��1*1*D����ά����
        features1=max(features,[],1);
        features=max(features1,[],2);
        X(ii,:)=features;%�����������
        T_features(ii,:)=T;
       end

       fprintf('---------------------TRAINING PROGRESS %2.3f----------------- \n',num_img/num_img)
       fprintf('-------------------------------------------------------------\n')
       fprintf('---------------TRAINING FEATURES EXTRACTED-------------------\n')
       fprintf('-------------------------------------------------------------\n')

end

