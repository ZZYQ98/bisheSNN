function reset_layers(num_layers)
%�����������
%total_time Ϊ��ѵ����ʱ��
global layers
[~,num_layers]=size(num_layers);

 for i=1:num_layers
     layers{i}.S=uint8(zeros(size(layers{i}.S)));
     layers{i}.V=double(zeros(size(layers{i}.V)));
     layers{i}.K_STDP=uint8(ones(size(layers{i}.K_STDP)));
     layers{i}.K_inh=uint8(ones(size(layers{i}.K_inh)));
end

