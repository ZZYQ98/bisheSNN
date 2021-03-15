function [  ] = train_step( network_struct,total_time,learning_layer,st)%STDP_per_layer��ʾÿ����Խ���STDPѧϰ������������

%ȫ�ֱ�������
global weights
global layers
global STDP_counter
% global STDP_time_pre %STDP����ʱ��
% global STDP_time_post
STDP_counter=0;
%global STDP_params
%���������ѵ��
%�Լ������еĲ������ݹ���
%layers��init_layers����
%weights��init_weights����
%train_total_time=total_time;%��ʱ��
%layer_for_learn=learning_layer+1;

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
%         H=network_struct{i}.shape.H_layer;
%         W=network_struct{i}.shape.W_layer;
%         D=network_struct{i}.shape.num_filters;
%         pad=network_struct{i}.pad;
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
           %[layers{i}.V,layers{i}.S,layers{i}.K_STDP]=conv_step_without_inh(S,V,s_pad,w,stride,th,K_STDP);%�����������Ĥ��λ������£��ﵽ��ֵ�������壬�����ǲ�����
           conv_step3( i,s_pad,stride,th,pad);
          %conv_step2( layers{i}.S,layers{i}.V,s_pad,weights{i},stride,th,layers{i}.K_STDP,layers{i}.K_inh);
          %[layers{i}.V,layers{i}.S,layers{i}.K_STDP,layers{i}.K_inh] = conv_step2( layers{i}.S,layers{i}.V,s_pad,weights{i},stride,th,layers{i}.K_STDP,layers{i}.K_inh) ;%�����ƾ���������
        elseif strcmp( network_struct{i}.Type,'pool' )%���ò�Ϊ�ز�ʱ
            %pooling_inh=layers{i}.pooling_inh; %֮���ٵ��ԣ���������¶�Ӧ�ػ�ֻ�ᷢ��һ������
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

    
    
%     
%     %STDP_learning
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %���¶�stdp��ѧϰ���̽�������
%         lay=learning_layer;  %layerning_layer���ϲ㺯�����壬ltl��layer to learn
%         if strcmp( network_struct{lay}.Type,'conv' )
%             S=layers{lay}.S;%����������               ������������ϲ鿴K_inh���Եõ����Խ���STDP����Ԫ��Ӧ��
%             V=layers{lay}.V;%���½������Ĥ��λֵ
%             K_STDP=layers{lay}.K_STDP;
%             S=double(S);
%             K_STDP=double(K_STDP);
%             valid=S.*V.*K_STDP;%valid��ѧϰ���п��Խ���stdp����tʱ�̷��������
%             if sum(sum(sum(valid)))>0
%                 H=network_struct{lay}.shape.H_layer;
%                 W=network_struct{lay}.shape.W_layer;
%                 D=network_struct{lay}.shape.num_filters;
%                 stride=network_struct{lay}.stride;
%                 offset=STDP_params.offset_STDP(lay);
%                 a_minus=STDP_params.a_minus;
%                 a_plus=STDP_params.a_plus;
%                 
%                 s=layers{lay-1}.S;
%                 ssum=sum(s,4);
%                 s=pad_for_conv( ssum,pad );%���庯�� pad_for_conv����Χ����
%                 w=weights{lay};
%              % [maxval,maxind1,maxind2]=get_STDP_idxs(valid,H,W,D,lay,STDP_per_layer,offset_STDP);%---------����δ����
%             
%         
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            %����CPU��ѧϰ����
%            %����STDPѧϰ����
%            S_sz=size(S);
%            [w,K_STDP_out]=STDP(S_sz,s,w,K_STDP,maxval,maxind1,maxind2,stride,offset,a_minus,a_plus);%����δ����
%            %S_szΪ�������Ĵ�С
%            weights{i}=w;
%            layers{learning_layer}.K_STDP=K_STDP_out;
%            end
%         end
end
 
end

