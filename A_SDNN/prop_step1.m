function [] = prop_step1(st)
global network_struct
global layers
global total_time

%Ŀǰû�Ӳ����ƾ���
for t=1:total_time
    layers{1}.S=st(:,:,t);
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
    
end

end

