function DiffGauss = DOG_creat(DOG_size,std1,std2)
%��˹����˲����Ĵ���
%��СΪDOG_size,��׼��Ϊstd1��std2
H1=fspecial('gaussian', DOG_size, std1);
H2=fspecial('gaussian', DOG_size, std2);
DiffGauss=H1-H2;
end
