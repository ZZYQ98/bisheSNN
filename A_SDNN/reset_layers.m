function reset_layers(num_layers)
%将层进行重置
%total_time 为层训练总时间
global layers
[~,num_layers]=size(num_layers);

 for i=1:num_layers
     layers{i}.S=uint8(zeros(size(layers{i}.S)));
     layers{i}.V=double(zeros(size(layers{i}.V)));
     layers{i}.K_STDP=uint8(ones(size(layers{i}.K_STDP)));
     layers{i}.K_inh=uint8(ones(size(layers{i}.K_inh)));
end

