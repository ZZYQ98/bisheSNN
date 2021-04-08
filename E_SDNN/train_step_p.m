function [ weights ] = train_step_p( weights,layers,layers_buff,network_struct,total_time,learning_layer,st,STDP_per_layer,deta_STDP_minus,deta_STDP_plus,offset)%STDP_per_layer��ʾÿ����Խ���STDPѧϰ������������


[~,num_layers]=size(layers);

%layersbuff{i}.S�д���һʱ�̸ò�ķ��������壬layer_buff{i-1}ͨ�����ã�������ʱ�̵����������layers{i}.S
%layersbuff{i}.V����������λ�õ���ԪĤ��λֵ

STDP_counter=0;


%����STDP���Ƶľ���STDP_inh
STDP_inh2=ones(size(layers{2}.S));
STDP_inh4=ones(size(layers{4}.S));
STDP_index=cell(STDP_per_layer(learning_layer),1);%Ԥ�ȷ���STDP_index���ڴ�λ�á�
STDP_inh={0,STDP_inh2,0,STDP_inh4};
for t=1:total_time+num_layers       %����ʱ��˳��ʹ���������ѧϰ ������ô����ʱ�䣬���ܱ�֤��������������Ϣ���ݹ�����
  if t<=total_time
    layers{1}.S=st(:,:,t);%stΪ��������尴��ʱ��ֲ��ľ���
    layers{1}.K_STDP=K_STDP_refresh_1(layers{1}.S,layers{1}.K_STDP,t);%�����K_STDP������и���,��ʾ���������ʱ��
  end
    %t-1ʱ�̵�ֵ����layers�У���ʼ����¾�Ϊ��ʼ��ֵ
    %tʱ�̵�ֵ����t-1ʱ��ǰһ���ֵ����
    parfor i=2:learning_layer    
        w=weights{i};
        V=layers{i}.V;       %��һʱ�̵�Ĥ��λֵ
        s=layers_buff{i-1}.S;%��һʱ�̣���һ������
        K_inh=layers{i}.K_inh;
        K_STDP=layers{i}.K_STDP;
        pad=network_struct{i}.pad; %��s������Χ����������Ա��ھ��  s�Ĺ�ģΪH��W��D
        th=network_struct{i}.th;
        stride=network_struct{i}.stride;
        [ s_pad ]=pad_for_conv( s,pad );    %t-1ʱ�̵�ǰһ����������
        %s_padΪ����ǰһ��ǰһʱ�̵��������õ���ֵ����ģΪ�����ģ�߽�+���㣬������֮����о������
        %���ݲ�ͬ�Ĳ����һЩ����
        
        if strcmp( network_struct{i}.Type,'conv' )%�ò�Ϊ�����ʱ  
            [ V_out , S_out ]=conv_only( s_pad, w, V ,stride,th);%V_out�а������������λ�ö�Ӧ��Ĥ��ѹ��λ
             %���������Ϊs����pool����input�������ΪS������һ��������K_STDP
             [S_out_inh ,K_inh_out, K_STDP_out] = lateral_inh1( V_out , S_out , K_inh, K_STDP,t);
        elseif strcmp( network_struct{i}.Type,'pool' )%���ò�Ϊ�ز�ʱ
            [S_out] = pool(layers{i}.S,s_pad,weights{i},stride,th);
            [S_out_inh ,K_inh_out, K_STDP_out] = lateral_inh1(layers{i}.V, S_out, K_inh, K_STDP,t);
            %pool����Ϊѧϰ�������㣬������������ͻ��ǰ��Ԫ��K_STDP����Ϊ�Ƿ񷢳�������STDP�ı�־��
        end
        %���������󣬴���һ����buff�е�ֵ���µĹ��̣�������һʱ�̴���
        layers{i}.V=V_out; %����Ϊ��ʱ�̵�Ĥ��λ
        layers{i}.K_STDP=K_STDP_out;
        layers{i}.K_inh=K_inh_out;
        layers{i}.S=S_out_inh;%ͨ����һʱ����һ�������õ���ʱ�̵����
    end
    for j=1:learning_layer
        layers_buff{j}.S=layers{j}.S;
    end 
     %��ý���STDP�ľ����λ��
        if  sum(sum(sum(layers{learning_layer}.S)))>0 && STDP_counter<STDP_per_layer(learning_layer)
             [STDP_index,STDP_inh{learning_layer},STDP_counter] = get_STDP_idx2(S_out_inh,layers{learning_layer}.V,STDP_index,STDP_inh{learning_layer},STDP_counter,offset(i),STDP_per_layer(learning_layer),t);
             %����п��Խ���STDP�������źţ����ɵõ���Ӧ���������Լ�ʵ��STDP����������
        end 
end    
    
    %������ϣ��õ�����Ҫ���и��µ�STDPλ�ã�����STDPѧϰ 
  [weights] = STDP(layers,learning_layer,STDP_index,STDP_per_layer(learning_layer),weights,network_struct,deta_STDP_minus,deta_STDP_plus);
    
end

