function [ deta] = deta_STDP( a,time,tao)
%aΪѧϰ����
%taoΪѧϰʵ����
%timeΪʱ����delta_t
deta=zeros(1,time);
for i=1:time
    deta(i)=a*exp(-i/tao);
end

end

