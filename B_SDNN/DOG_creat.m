function DiffGauss = DOG_creat(DOG_size,std1,std2)
%高斯差分滤波窗的创建
%大小为DOG_size,标准差为std1与std2
H1=fspecial('gaussian', DOG_size, std1);
H2=fspecial('gaussian', DOG_size, std2);
DiffGauss=H1-H2;
end
