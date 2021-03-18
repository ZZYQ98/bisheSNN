s=zeros(18,18,4);
S=zeros(28,28,16);
w=ones(3,3,4)
[ V,S,K_STDP ] = conv_step_without_inh( S,V,s,w,stride,th,K_STDP )