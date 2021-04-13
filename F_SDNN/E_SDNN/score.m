kind=5;
T_min=min(T);
if sum( T(1:kind) == T_min) > sum(T(kind:10)==T_min)
    features_from_T(ii)=1;
else 
    features_from_T(ii)=2;
end