function [  ] = train_step( network_struct,total_time,learning_layer,st)%STDP_per_layer��ʾÿ����Խ���STDPѧϰ������������

%ȫ�ֱ�������
global weights
global layers
global STDP_counter
% global STDP_time_pre %STDP����ʱ��
% global STDP_time_post
STDP_counter=0;
global weight_STDP_flag
%global STDP_params
%���������ѵ��
%�Լ������еĲ������ݹ���
%layers��init_layers����
%weights��init_weights����
%train_total_time=total_time;%��ʱ��
%layer_for_learn=learning_layer+1;

%����һ��STDPȨֵ���±�־�Ĵ���������һ��ʱ����ĳЩȨֵδ����STDP��Ҳ�������������壬�����˻������־λ��Ӧ��Ȩֵ������С����С����Ϊa_minus
weight_STDP_flag=ones(size(weights(learning_layer)))*30;
[H,W,D]=size(weights(learning_layer));
for t=1:total_time       %����ʱ��˳��ʹ���������ѧϰ
    %ʱ�����ӣ�STDPѧϰӰ�콵��
    for L=1:learning_layer
        layers{L}.K_STDP=layers{L}.K_STDP-1;
    end
    reset_layers_spike(learning_layer); %�µ�һ��ʱ�̣���Ҫ�����е����������գ��Ӷ������µĴ���
    
    layers{1}.S=st(:,:,t);%stΪ��������尴��ʱ��ֲ��ľ���
    layers{1}.K_STDP=K_STDP_refresh_pre(layers{1}.S,layers{1}.K_STDP);%�����K_STDP������и���

    
%     K_STDP_post=layers{learning_layer}.K_STDP;
%     K_STDP_pre=layers{learning_layer-1}.K_STDP;
    
    for i=2:learning_layer    %
        stride=network_struct{i}.stride;%����
        th=network_struct{i}.th;%��ֵ
        w=weights{i};%Ȩֵ����
        s=layers{i-1}.S;%�������������=��һ���������
        pad=network_struct{i}.pad; %��s������Χ����������Ա��ھ��  s�Ĺ�ģΪH��W��D
        [ s_pad ]=pad_for_conv( s,pad );    %sΪ����ǰһ����������õ���ֵ����ģΪ�����ģ�߽�+���㣬������֮����о������
        
        %���ݲ�ͬ�Ĳ����һЩ����
        if strcmp( network_struct{i}.Type,'conv' )%�ò�Ϊ�����ʱ
            
            %���������Ϊs����pool����input������һ��������K_STDP
           layers{i-1}.K_STDP=K_STDP_update(s,layers{i-1}.K_STDP);%���������ǿ��STDP
           
           conv_step3( i,s_pad,stride,th,pad);
       
        elseif strcmp( network_struct{i}.Type,'pool' )%���ò�Ϊ�ز�ʱ
            pooling1(i,s_pad,w,stride,th);
            layers{i}.K_STDP=K_STDP_refresh_pre(layers{i}.S,layers{i}.K_STDP);%pool����Ϊѧϰ�������㣬������������ͻ��ǰ��Ԫ��K_STDP����Ϊ�Ƿ񷢳�������STDP�ı�־��
        end
    end
    check_Spike=sum(sum(sum(layers{learning_layer-1}.S)));%�۲��ʱ�������������
    %������ϣ�����STDPѧϰ
    if check_Spike
    STDP1(layers{learning_layer}.S,layers{learning_layer-1}.S,layers{learning_layer-1}.K_STDP,...
    layers{learning_layer}.K_STDP,learning_layer,network_struct{learning_layer}.stride,network_struct{learning_layer}.pad);
    end
    
    for k=1:D
        for i=1:H
            for j=1:W
                if weight_STDP_flag(i,j,k)==0
                    weights(i,j,k)=weights(i,j,k)-a_minus(learning_layer);
                    if weights(i,j,k)<1e-6
                        weights(i,j,k)=1e-6;
                    end
                end
            end
        end
    end
    %�Ծ�����и��²���
    weight_STDP_flag=weight_STDP_flag-1;

end
 
end

