function [ ] =conv_step_prop( ii,s,stride,th)
global layers 
global weights
[~,~,Ds]=size(s);
[H,W,D]=size(layers{ii}.V);%D ��WD�Ĵ�С��ͬ
[HH,WW,WD]=size(weights{ii}); 
for k=1:WD %һ��һ�����   sÿһ����Ȩֵ�����һ����о�����õ�Ds������
    conv_core=weights{ii}(:,:,k);%��k��ӳ���Ȩֵ������ʽ
        for j=1:W
            for i=1:H
            local_image=double(s((i-1)*stride+1:(i-1)*stride+HH,(j-1)*stride+1:(j-1)*stride+WW,:));%local_imgָ����һ��С��Χ��ͼ���СΪfilter_size 
            %local_image �Ĵ�СΪHH*WW*Ds
            result=0;
            for K=1:Ds  
                 result=result+sum(sum(conv_core.*local_image(:,:,K))); %����ǰHH*WW*Ds��Ԫͨ����k��Ȩֵ����ӳ��õ���Ȩֵ������
            end
            layers{ii}.V(i,j,k)=result+layers{ii}.V(i,j,k);%���¸�λ�õ�Ȩֵ����
            %�۲��Ƿ�ﵽ��ֵ��������������
            %Ŀǰ������Ч�����ڻ����ƣ�û�з���������
               if layers{ii}.V(i,j,k)>th%�ﵽ��ֵ�Ҳ�����������ʱ
                  layers{ii}.V(i,j,k)=0;%Ĥ��λ��Ϊ��
                  if layers{ii}.K_inh(i,j)==1%��λ��δ����������
                     layers{ii}.S(i,j,k)=1;%ͻ������Ԫ��������
                     layers{ii}.K_inh(i,j)=0;%���ø�λ���Ժ󽫷��������ƣ�������ͬȨֵ����ӳ������������ͬλ�÷�������
                  end
                end
             end
        end  
end

end

