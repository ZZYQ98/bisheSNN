function []=weights_img(weights)
%weights一般为C2层的权值

weight_img=max(weights,[],3);
weight_img=max(weight_img,[],4);
imshow(weight_img)
end

