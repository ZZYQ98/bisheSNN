function [] = prop_step(st)
global network_struct
global layers
global total_time
global num_layers
global weights
%Ŀǰû�Ӳ����ƾ���
for t=1:total_time
    layers{1}.S=st(:,:,:,t);
    for i=2:num_layers
        stride=network_struct{i}.stride;%����
        th=network_struct{i}.th;%��ֵ
        w=weights{i};%Ȩֵ����
        s=layers{i-1}.S;%�������������=��һ���������
        pad=network_struct{i}.pad; %��s������Χ����������Ա��ھ��  s�Ĺ�ģΪH��W��D
        [ s_pad ]=pad_for_conv( s,pad );    %sΪ����ǰһ����������õ���ֵ����ģΪ�����ģ�߽�+���㣬������֮����о������
        
        if strcmp( network_struct{i}.Type,'conv' );
           conv_step_prop( i,s_pad,stride,th);%����һ��Ȩֵ����
        elseif strcmp( network_struct{i}.Type,'pool' );
            pooling1(i,s_pad,w,stride,th);
        end
    end
    
end

end

