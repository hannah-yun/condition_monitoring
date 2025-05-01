%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vEBIC,vdist,vbests,vt,bestD] = DL_AKSVD1_simulation(vibdata,nu,N,facn,vs)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Dimensions:
    m = size(vibdata,1);         % signal length
    n = facn*m;                  % dict. size
    no_init = 10;
    
    rng(1234);
   
    %Build data matrix Yinit
    Yinit = vibdata(:,1:N+1); 
    [~,bestD,~,~] = one_segment_AKSVD1(Yinit,vs,n,no_init);
    refD = bestD;

    vEBIC = Inf(nu,1);
    vdist = Inf(nu,1);
    vbests = Inf(nu,1);
    vt = Inf(nu,1);
    for exp = 1:nu
        tic
        % Remove the first col and add a new segment into the last col
        Yinit = [Yinit(:,2:end) vibdata(:,exp+1+N)]; 

        [vEBIC(exp),vdist(exp),bestD,vbests(exp),~] = two_segment_AKSVD1(Yinit,vs,bestD,refD);
        vt(exp) = toc;
        if mod(exp, 5) == 0
            fprintf('Iter: %d\n', exp);
        end 
    end

end %main function

% Local functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [EBIC,bestD,bests,bestXn] = one_segment_AKSVD1(Yinit,vs,n,no_init)
    %For L1-KSVD
    iters_L1 = 5;  
    
    % find the log ratio (Y); cols have zero mean
    Y = log_ratio(Yinit);
    m = size(Y,1);

    pos = 0;
    All = cell(no_init*length(vs),4);

    for init = 1:no_init %loop init. 
            D0 = normc(randn(m,n));
            for s=vs %loop sparsity
                pos = pos+1;  
                % Dictionary learning 
                % L1-KSVD
                Dn = DL_L1_alt(Y, D0, s, iters_L1);
                All{pos,1} = Dn;
                All{pos,2} = s;
                % Sparse coding
                Xn = omp_l1(Y, Dn, s);
                All{pos,3} = Xn;
                err = sum(sum(abs(Y - Dn*Xn)));

                % Information Theoretic Criterion (extended BIC)
                itc = it_crit(2, Y, Dn, s, err);
                All{pos,4} = itc(2);
            end %s
    end %init
     
     [EBIC,ind] = min(cell2mat(All(:,4)));
     bestD = cell2mat(All(ind,1));
     bests = cell2mat(All(ind,2));
     bestXn = cell2mat(All(ind,3));

end %function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [EBIC,dist,bestD,bests,bestXn]=two_segment_AKSVD1(Yinit,vs,D0,refD)
    %For L1-KSVD
    iters_L1 = 5;
    
    % find the log ratio (Y); cols have zero mean
    Y = log_ratio(Yinit);

    pos = 0;
    All = cell(length(vs),4);

    for s=vs %loop sparsity
        pos = pos+1;  
        % Dictionary learning 
        % L1-KSVD
        Dn = DL_L1_alt(Y, D0, s, iters_L1);
        All{pos,1} = Dn;
        All{pos,2} = s;
        % Sparse coding
        Xn = omp_l1(Y, Dn, s);
        All{pos,3} = Xn;
        err = sum(sum(abs(Y - Dn*Xn)));

        % Information Theoretic Criterion (extended BIC)
        itc = it_crit(2, Y, Dn, s, err);
        All{pos,4} = itc(2);
    end %s

     [EBIC,ind] = min(cell2mat(All(:,4)));
     bestD = cell2mat(All(ind,1));
     dist = dictdist(bestD,refD);
     bests = cell2mat(All(ind,2));
     bestXn = cell2mat(All(ind,3));

end %function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function val = log_ratio(numerator, denominator)
%    numerator(numerator==0) = min(numerator(numerator>0))/10^6;
%    denominator(denominator==0) = min(denominator(denominator>0))/10^6;
%    val = log(numerator) - log(denominator); %natural log
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Y = log_ratio(Yinit)

Y = Yinit;
Y(Y==0) = min(min(Y(Y>0)))/10^6;
Y = log(Y(:,1:end-1)) - log(Y(:,end));
Y = Y - mean(Y);

end %function



