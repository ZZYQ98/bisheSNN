function [] = weight_range(learning_layer)

global weights
weight_max=max(weights{learning_layer},[],'all');
weight_min=min(weights{learning_layer},[],'all');

 if weight_max>0.999999
    [m,n,k]=find(weight_max>0.999999);
    weights{learning_layer}(m,n,k)=0.999999;
 
 elseif weight_min<0.000001
     [m,n,k]=find(weight_min>0.000001);
     weights{learning_layer}(m,n,k)=0.000001;
 end
end

