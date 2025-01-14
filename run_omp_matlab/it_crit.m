function itc = it_crit(flag_algo, Y, D1, s, err)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Input:
%   flag_algo    = 1=AKSVD and 2=AKSVD-L1
%   Y            = training signals
%   D1           = learnt dictionary
%   err          = norm of the training errors
%   s            = sparsity level
%Output:
% itc(1)         = BIC 
% itc(2)         = EBIC 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[m,N] = size(Y);
[~,n] = size(D1);
T = m * N;                    %total no. of measurements
nop = s * N + (m-1) * n;      %no. of param.  
pen = (nop/2) * log(T);

if flag_algo==1               %Gaussian case
    gof      = (T/2) * log(err/T);
    BIC      = gof + pen;   
elseif flag_algo==2           %Laplacian case
    gof      = (T/2) * log(2 * ((err/T).^ 2));
    BIC      = gof + pen + (nop/2)*log(2);
else
end

%BIC
itc(1)   = BIC;
%EBIC
itc(2)   = BIC + N * (gammaln(n+1)-gammaln(s+1)-gammaln(n- s + 1));
    
end %function

