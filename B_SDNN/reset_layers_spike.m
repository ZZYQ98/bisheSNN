function reset_layers_spike(learning_layer)
%�����������
%total_time Ϊ��ѵ����ʱ��
global layers

 for i=1:learning_layer
     layers{i}.S=uint8(zeros(size(layers{i}.S)));
end

