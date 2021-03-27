% 
% W=weights{4};
% weight_img=max(W,[],3);
% weight_img=max(weight_img,[],4);

weights_path_list='weights3.26.mat';
weights_buff=load(weights_path_list);
weights_C1=weights_buff.weights{2};

for i=1:4
    w_img=weights_C1(:,:,:,i);
    subplot(1,4,i),imshow(w_img);
end
