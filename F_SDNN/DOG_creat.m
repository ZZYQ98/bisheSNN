function filt=DOG_creat(DoG_params)
%��˹����˲����Ĵ���
%��СΪDOG_size,��׼��Ϊstd1��std2
DOG_size=DoG_params.DoG_size;
std1=DoG_params.std1;
std2=DoG_params.std2;

H1=fspecial('gaussian', DOG_size, std1);
H2=fspecial('gaussian', DOG_size, std2);
filt=H1-H2;
end