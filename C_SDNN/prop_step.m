function [sp_time] = prop_step(st)
global network_struct
global layers
global total_time
global num_layers
%Ŀǰû�Ӳ����ƾ���
[~,~,D]=size(layers{num_layers}.S);
sp_time=zeros(1,D);
for t=1:total_time
    layers{1}.S=st(:,:,:,t);
    for i=2:num_layers
        s=layers{i-1}.S;%�������������=��һ���������
        pad=network_struct{i}.pad; %��s������Χ����������Ա��ھ��  s�Ĺ�ģΪH��W��D
        [ s_pad ]=pad_for_conv( s,pad );    %sΪ����ǰһ����������õ���ֵ����ģΪ�����ģ�߽�+���㣬������֮����о������
        
        if strcmp( network_struct{i}.Type,'conv' )
           conv_step_prop( i,s_pad,network_struct{i}.stride,network_struct{i}.th);%����һ��Ȩֵ����
        elseif strcmp( network_struct{i}.Type,'pool' )
            pooling1(i,s_pad,network_struct{i}.stride,network_struct{i}.th);
        end
        if i==num_layers
            for n=1:D
                if layers{num_layers}.S==1
                    sp_time(n)=t;
                end
            end
        end
    end
    
end

end

