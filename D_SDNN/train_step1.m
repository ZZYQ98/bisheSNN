function [ weights ] = train_step1( weights,layers,network_struct,total_time,learning_layer,st,STDP_per_layer,deta_STDP_minus,deta_STDP_plus,offset)%STDP_per_layer��ʾÿ����Խ���STDPѧϰ������������

%ȫ�ֱ�������
global STDP_Flag
%global STDP_params
%���������ѵ��
%�Լ������еĲ������ݹ���
%layers��init_layers����
%weights��init_weights����
%train_total_time=total_time;%��ʱ��
%layer_for_learn=learning_layer+1;

layers_buff=init_layers(network_struct);

[~,~,~,D]=size(weights{learning_layer});
STDP_Flag=ones(1,D)*STDP_per_layer(learning_layer);%������е�ÿһС��Ȩֵ���Է����仯������

%����STDP���Ƶľ���STDP_inh
STDP_inh2=ones(size(layers{2}.S));
STDP_inh4=ones(size(layers{4}.S));
STDP_index=cell(STDP_per_layer(learning_layer),D);
STDP_inh={0,STDP_inh2,0,STDP_inh4};
for t=1:total_time       %����ʱ��˳��ʹ���������ѧϰ

    layers_buff{1}.S=st(:,:,t);%stΪ��������尴��ʱ��ֲ��ľ���
    layers{1}.K_STDP=K_STDP_refresh_1(layers_buff{1}.S,layers{1}.K_STDP,t);%�����K_STDP������и���

    %t-1ʱ�̵�ֵ����layers�У���ʼ����¾�Ϊ��ʼ��ֵ
    %tʱ�̵�ֵ����t-1ʱ��ǰһ���ֵ����
    for i=2:learning_layer    
        V=layers{i}.V;      %Ĥ��λ����
       % S=zeros(size(layers{i}.S));     %����������
        K_STDP=layers{i}.K_STDP;
        K_inh=layers{i}.K_inh;%�����ƾ���
        pad=network_struct{i}.pad; %��s������Χ����������Ա��ھ��  s�Ĺ�ģΪH��W��D
        th=network_struct{i}.th;
        stride=network_struct{i}.stride;
        [ s_pad ]=pad_for_conv( layers_buff{i-1}.S,pad );    %s_padΪ����ǰһ��ǰһʱ�̵��������õ���ֵ����ģΪ�����ģ�߽�+���㣬������֮����о������
        %���ݲ�ͬ�Ĳ����һЩ����
        
        if strcmp( network_struct{i}.Type,'conv' )%�ò�Ϊ�����ʱ  
            [V,S,V_buff]=conv_only( s_pad,weights{i},V,layers{i}.S,stride,th);%V_buffΪ�������λ�ö�Ӧ��Ĥ��ѹ��λ��VΪ��ԪĤ��λ���󣨷������岿�ֹ����ˣ�
             %���������Ϊs����pool����input�������ΪS������һ��������K_STDP
             [S,K_inh,K_STDP] = lateral_inh1(V_buff,S,K_inh,K_STDP,t);
             layers_buff{i}.S=S;
        elseif strcmp( network_struct{i}.Type,'pool' )%���ò�Ϊ�ز�ʱ
            [S,V_buff] = pool(layers{i}.S,s_pad,weights{i},V,stride,th);
            [S,K_inh,K_STDP] = lateral_inh1(V_buff,S,K_inh,K_STDP,t);
            layers_buff{i}.S=S;
            %pool����Ϊѧϰ�������㣬������������ͻ��ǰ��Ԫ��K_STDP����Ϊ�Ƿ񷢳�������STDP�ı�־��
        end
        layers{i}.S=S;
        layers{i}.V=V;
        layers{i}.K_STDP=K_STDP;       %K_STDP�����д洢���巢��ʱ��
        layers{i}.K_inh=K_inh;
        
    end
    
    
     %��ý���STDP�ľ����λ��
        if  sum(sum(sum(S)))>0 && sum(STDP_Flag)>0
             [STDP_index,STDP_inh{i}] = get_STDP_idx1(layers{learning_layer}.S,V_buff,STDP_index,STDP_inh{i},offset(i),t);%����п��Խ���STDP�������źţ����ɵõ���Ӧ���������Լ�ʵ��STDP����������
        end 
end    
    
    %������ϣ��õ�����Ҫ���и��µ�STDPλ�ã�����STDPѧϰ 
  [weights] = STDP(layers,learning_layer,STDP_index,weights,network_struct,deta_STDP_minus,deta_STDP_plus);
    
    
    
    
    
%     %STDP  positive negative ���в���������Ȩֵ���и��¡�
%    [ weights{learning_layer},layers{learning_layer-1}.K_STDP,weight_STDP_flag ] =STDP_positive(layers{learning_layer}.S,layers{learning_layer-1}.S,layers{learning_layer-1}.K_STDP,...
%     network_struct{learning_layer}.stride,network_struct{learning_layer}.pad,weight_STDP_flag,weights{learning_layer},deta_STDP_plus);



   
%  %�����STDP_inh��STDPѧϰ����
%  [weights{learning_layer},weight_STDP_flag] = STDP_pos(layers{learning_layer}.S,weights{learning_layer},V_buff,layers{learning_layer-1}.K_STDP,...
%   network_struct{learning_layer}.stride,network_struct{learning_layer}.pad,weight_STDP_flag,deta_STDP_plus,offset(learning_layer) );
%  
%  [ weights{learning_layer},layers{learning_layer}.K_STDP,weight_STDP_flag ]=STDP_negative(layers{learning_layer}.S,layers{learning_layer-1}.S,layers{learning_layer}.K_STDP  ,...
%  network_struct{learning_layer}.stride,network_struct{learning_layer}.pad,weight_STDP_flag,weights{learning_layer},deta_STDP_minus) ;

 
  


end

