function [] = prop_step1(st)
global network_struct
global layers
global total_time
global weights
%Ŀǰû�Ӳ����ƾ���
for t=1:total_time
    layers{1}.S=st(:,:,t);
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
           conv_step_prop( i,s_pad,stride,th,pad);
        elseif strcmp( network_struct{i}.Type,'pool' )%���ò�Ϊ�ز�ʱ
            pooling1(i,s_pad,w,stride,th);
        end
    end
    
end

end

