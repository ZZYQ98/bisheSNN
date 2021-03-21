function [  ] = train_step( network_struct,total_time,learning_layer,st)%STDP_per_layer��ʾÿ����Խ���STDPѧϰ������������

%ȫ�ֱ�������
global weights
global layers
global STDP_counter
global STDP_Flag_p
global STDP_Flag_n
% global STDP_time_pre %STDP����ʱ��
% global STDP_time_post
STDP_counter=0;
global weight_STDP_flag
global STDP_per_layer
%global STDP_params
%���������ѵ��
%�Լ������еĲ������ݹ���
%layers��init_layers����
%weights��init_weights����
%train_total_time=total_time;%��ʱ��
%layer_for_learn=learning_layer+1;

%����һ��STDPȨֵ���±�־�Ĵ�������ѧϰ������ĳЩȨֵδ����STDP��Ҳ�������������壬�����˻������־λ��Ӧ��Ȩֵ������С
weight_STDP_flag=ones(size(weights{learning_layer}));

[~,~,D]=size(weights{learning_layer});
STDP_Flag_p=ones(1,D)*STDP_per_layer(learning_layer);%������е�ÿһС��Ȩֵ���Է����仯������
STDP_Flag_n=ones(1,D)*STDP_per_layer(learning_layer);

for t=1:total_time       %����ʱ��˳��ʹ���������ѧϰ
    %ʱ�����ӣ�STDPѧϰӰ�콵��
    for L=1:learning_layer
        layers{L}.K_STDP=layers{L}.K_STDP-1;
    end
    reset_layers_spike(learning_layer); %�µ�һ��ʱ�̣���Ҫ�����е����������գ��Ӷ������µĴ���
    
    
    layers{1}.S=st(:,:,t);%stΪ��������尴��ʱ��ֲ��ľ���
    K_STDP_refresh_1();%�����K_STDP������и���

    
    for i=2:learning_layer    %
        s=layers{i-1}.S;%�������������=��һ���������
        pad=network_struct{i}.pad; %��s������Χ����������Ա��ھ��  s�Ĺ�ģΪH��W��D
        [ s_pad ]=pad_for_conv( s,pad );    %sΪ����ǰһ����������õ���ֵ����ģΪ�����ģ�߽�+���㣬������֮����о������
        %���ݲ�ͬ�Ĳ����һЩ����
        if strcmp( network_struct{i}.Type,'conv' )%�ò�Ϊ�����ʱ  
            conv_step5(i,s_pad,network_struct{i}.stride,network_struct{i}.th);
             %���������Ϊs����pool����input�������ΪS������һ��������K_STDP
        elseif strcmp( network_struct{i}.Type,'pool' )%���ò�Ϊ�ز�ʱ
            pooling1(i,s_pad,network_struct{i}.stride,network_struct{i}.th);
            %pool����Ϊѧϰ�������㣬������������ͻ��ǰ��Ԫ��K_STDP����Ϊ�Ƿ񷢳�������STDP�ı�־��
        end
    end
    
    %������ϣ�����STDPѧϰ 
    %STDP  positive negative ���в���������Ȩֵ���и��¡�
    STDP_positive(layers{learning_layer}.S,layers{learning_layer-1}.S,layers{learning_layer-1}.K_STDP,learning_layer,network_struct{learning_layer}.stride,network_struct{learning_layer}.pad);
    STDP_negative(layers{learning_layer}.S,layers{learning_layer-1}.S,layers{learning_layer}.K_STDP  ,learning_layer,network_struct{learning_layer}.stride,network_struct{learning_layer}.pad) ;
    STDP_inactive(learning_layer);
   % weight_range(learning_layer);
    %�Ծ�����и��²���
    weight_STDP_flag=weight_STDP_flag-1;
   if sum(STDP_Flag_p)+sum(STDP_Flag_n)==0       %�ж������ѧϰ�Ƿ��Ѿ�����
      continue 
   end
end
 
end

