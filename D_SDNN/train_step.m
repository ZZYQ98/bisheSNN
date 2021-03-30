function [ weights ] = train_step( weights,layers,network_struct,total_time,learning_layer,st,STDP_per_layer,deta_STDP_minus,deta_STDP_plus,offset)%STDP_per_layer��ʾÿ����Խ���STDPѧϰ������������

%ȫ�ֱ�������
global STDP_Flag_p
global STDP_Flag_n
global STDP_time_pre %STDP����ʱ��
global STDP_time_post
%global STDP_params
%���������ѵ��
%�Լ������еĲ������ݹ���
%layers��init_layers����
%weights��init_weights����
%train_total_time=total_time;%��ʱ��
%layer_for_learn=learning_layer+1;

weight_STDP_flag=ones(size(weights{learning_layer}));%����һ��STDPȨֵ���±�־�Ĵ�������ѧϰ������ĳЩȨֵδ����STDP��Ҳ�������������壬�����˻������־λ��Ӧ��Ȩֵ������С

[~,~,D]=size(weights{learning_layer});
STDP_Flag_p=ones(1,D)*STDP_per_layer(learning_layer);%������е�ÿһС��Ȩֵ���Է����仯������
STDP_Flag_n=ones(1,D)*STDP_per_layer(learning_layer);

for t=1:total_time       %����ʱ��˳��ʹ���������ѧϰ
    %ʱ�����ӣ�STDPѧϰӰ�콵��
    for L=1:learning_layer
        layers{L}.K_STDP=layers{L}.K_STDP-1;%ÿһʱ�̿�ʼK_STDP�����һ���������ڵ�������ʱ���С
        layers{L}.S=uint8(zeros(size(layers{L}.S)));%ÿһʱ�̿�ʼ������������㣬�Ա���һʱ�̵�������д���
    end
    
    layers{1}.S=st(:,:,t);%stΪ��������尴��ʱ��ֲ��ľ���
    layers{1}.K_STDP=K_STDP_refresh_1(layers{1}.S,layers{1}.K_STDP,STDP_time_pre);%�����K_STDP������и���

    
    for i=2:learning_layer    
        s=layers{i-1}.S;    %�������������=��һ���������
%         weight=weights{i};  %Ȩֵ����
        V=layers{i}.V;      %Ĥ��λ����
        S=layers{i}.S;      %����������
        K_STDP=layers{i}.K_STDP;
        K_inh=layers{i}.K_inh;%�����ƾ���
        pad=network_struct{i}.pad; %��s������Χ����������Ա��ھ��  s�Ĺ�ģΪH��W��D
        th=network_struct{i}.th;
        stride=network_struct{i}.stride;
        [ s_pad ]=pad_for_conv( s,pad );    %sΪ����ǰһ����������õ���ֵ����ģΪ�����ģ�߽�+���㣬������֮����о������
        %���ݲ�ͬ�Ĳ����һЩ����
        
        if strcmp( network_struct{i}.Type,'conv' )%�ò�Ϊ�����ʱ  
            [V,S,V_buff]=conv_only( s_pad,weights{i},V,S,stride,th);
             %���������Ϊs����pool����input�������ΪS������һ��������K_STDP
             [S,K_inh,K_STDP] = lateral_inh1(V_buff,S,K_inh,K_STDP,STDP_time_post);
        elseif strcmp( network_struct{i}.Type,'pool' )%���ò�Ϊ�ز�ʱ
            [S,V_buff] = pool(S,s_pad,weights{i},V,stride,th);
            [S,K_inh,K_STDP] = lateral_inh1(V_buff,S,K_inh,K_STDP,STDP_time_pre);
            %pool����Ϊѧϰ�������㣬������������ͻ��ǰ��Ԫ��K_STDP����Ϊ�Ƿ񷢳�������STDP�ı�־��
        end
        layers{i}.S=S;
        layers{i}.V=V;
        layers{i}.K_STDP=K_STDP;
        layers{i}.K_inh=K_inh;
    end
    
    %������ϣ�����STDPѧϰ 
%     %STDP  positive negative ���в���������Ȩֵ���и��¡�
%    [ weights{learning_layer},layers{learning_layer-1}.K_STDP,weight_STDP_flag ] =STDP_positive(layers{learning_layer}.S,layers{learning_layer-1}.S,layers{learning_layer-1}.K_STDP,...
%     network_struct{learning_layer}.stride,network_struct{learning_layer}.pad,weight_STDP_flag,weights{learning_layer},deta_STDP_plus);



   
 %�����STDP_inh��STDPѧϰ����
 [weights{learning_layer},weight_STDP_flag] = STDP_pos(layers{learning_layer}.S,weights{learning_layer},V_buff,layers{learning_layer-1}.K_STDP,...
  network_struct{learning_layer}.stride,network_struct{learning_layer}.pad,weight_STDP_flag,deta_STDP_plus,offset(learning_layer) );
 
 [ weights{learning_layer},layers{learning_layer}.K_STDP,weight_STDP_flag ]=STDP_negative(layers{learning_layer}.S,layers{learning_layer-1}.S,layers{learning_layer}.K_STDP  ,...
 network_struct{learning_layer}.stride,network_struct{learning_layer}.pad,weight_STDP_flag,weights{learning_layer},deta_STDP_minus) ;

 
   
    %�Ծ�����и��²���
%     weight_STDP_flag=weight_STDP_flag-1;
   if sum(STDP_Flag_p)+sum(STDP_Flag_n)==0       %�ж������ѧϰ�Ƿ��Ѿ�����
      continue 
   end
end
[ weights{learning_layer},weight_STDP_flag]=STDP_inactive(weights{learning_layer},weight_STDP_flag,deta_STDP_minus);

end

