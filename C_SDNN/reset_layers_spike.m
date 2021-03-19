function reset_layers_spike(learning_layer)
%将层进行重置
%total_time 为层训练总时间
global layers

 for i=1:learning_layer
     layers{i}.S=uint8(zeros(size(layers{i}.S)));
end

