function [STDP_index,STDP_counter] = get_STDP_idx3(valid,STDP_index,STDP_counter,offset,STDP_per_layer,t)
[Si,Sj,D]=size(valid);
%STDP_index为之前定义的用于存储将发生STDP权值更新的神经元的位置。
%找到可以进行STDP的神经元的位置
maxind1=zeros(1,D);
maxind2=zeros(1,D);
maxval=zeros(1,D);
time=zeros(1,D);

[mxv,mxi]=max(valid,[],3);%三维到二维，mxv存储最大值，mxi存储最大值对应在第几层
while sum(sum(mxv))>0 && STDP_counter<STDP_per_layer   
    STDP_counter=STDP_counter+1;
    [mximum,index]=max(mxv,[],2);
    [~,index1]=max(mximum,[],1);
    index2=index(index1);
    %mxi(index1,index2)表示神经元所在的层数
    maxval(mxi(index1,index2))=mxv(index1,index2);
    maxind1(mxi(index1,index2))=index1;
    maxind2(mxi(index1,index2))=index2;
    time(mxi(index1,index2))=t;
    %在已经得到某一通道发生STDP的位置以后，将mxv中的该位置数据清零
    mxv(mxi==mxi(index1,index2))=0;
    mxv(max(index1-offset,1):min(index1+offset,Si),max(index2-offset,1):min(index2+offset,Sj))=0;
   % STDP_index{STDP_counter}=[maxval,]
end
for i=1:D
    if maxval(i)~=0
        STDP_index{i}=[maxval(i),maxind1(i),maxind2(i),time(i)];
    end
end
end