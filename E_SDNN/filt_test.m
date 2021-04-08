%filter_调试
img_filted=readNPY("img_filted.npy");
img_bordered=readNPY("img_bordered.npy");
img_threshold=readNPY("img_threshold.npy");
subplot(131),imshow(img_filted)
subplot(132),imshow(img_bordered)
subplot(133),imshow(img_threshold)