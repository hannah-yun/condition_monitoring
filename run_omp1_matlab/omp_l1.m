function X = omp_l1(Y, D, s, iter_cd)

% Optimal Matching Pursuit in L1 norm.
% 
% Input:
%   Y         - signals (on columns)
%   D         - dictionary (normalized atoms)
%   s         - sparsity level
%   iter_cd   - number of iterations in the coordinate descent search of
%               optimal L1 solution for fixed support
% Output:
%   X         - sparse representations matrix

% BD 25.04.2020

if nargin < 4
  iter_cd = 2;
end

[m,n] = size(D);
N = size(Y,2);
m2 = floor(m/2);

X = zeros(n,N);
for ell = 1 : N
  y = Y(:,ell);

  r = y;      % residual
  support = [];
  xk = [];
  for k = 1 : s
    % find best current atom
    p = D'*r;         % projections, like in OMP, only for selection
    p(support) = 0;
    icand = find(abs(p) > 0.5*max(abs(p)));   % check only the most promising atoms
    xi = zeros(length(icand),1);
    fval = zeros(length(icand),1);
    for i = 1 : length(icand)     % 
      d = D(:,icand(i));
      c = r ./ d;
%      [fval(i),ii] = min(sum(abs(repmat(r,1,m)-d*c')));
%      xi(i) = c(ii);
      % alternative solution, clearly faster (could be even more)
      [~,ic] = sort(c);
      dd = abs(d(ic));
%       sum_left = 0;
%       sum_right = sum(dd);
%       for j = 1 : m
%         sum_left = sum_left + dd(j);
%         sum_right = sum_right - dd(j);
%         if sum_left > sum_right
%           break;
%         end
%       end
      jj = m2;    % this should be even faster than the commented code above
      sum_left = sum(dd(1:jj));
      sum_right = sum(dd(jj+1:m));
      if sum_left < sum_right
        for j = jj+1 : m
          sum_left = sum_left + dd(j);
          sum_right = sum_right - dd(j);
          if sum_left > sum_right
            break;
          end
        end
      else        % sum_left > sum_right
        for j = jj : -1 : 1
          sum_left = sum_left - dd(j);
          sum_right = sum_right + dd(j);
          if sum_left < sum_right
            break;
          end
        end
      end
      xi(i) = c(ic(j));
      fval(i) = sum(abs(r - xi(i)*d));
    end
    [~,i] = min(fval);     % index of best atom
    support = [support icand(i)]; % update support with new atom

    % compute (nearly) optimal representation
    Dk = D(:,support);    % current dictionary
    %xk = Dk \ y;      % initialization with LS solution
    %[xk,~] = fminunc(@(z) sum(abs(y-Dk*z)), xk, options);
    xk = [xk; xi(i)];
    %norm(y-Dk*xk,1)
    if k > 1
      if 0
        [xk,~] = fminunc(@(z) sum(abs(y-Dk*z)), xk, options);
      else
        for icd = 1 : iter_cd       % go towards optimal least 1-norm solution via coordinate descent
          r = y - Dk*xk;
          for i = 1 : length(xk)    % a round of coordinate descent
            d = Dk(:,i);
            r = r + d*xk(i);
            c = r ./ d;
%            [~,ii] = min(sum(abs(repmat(r,1,m)-Dk(:,i)*c')));
%            xk(i) = c(ii);
            [~,ic] = sort(c);
            dd = abs(d(ic));
%             sum_left = 0;
%             sum_right = sum(dd);
%             for j = 1 : m
%               sum_left = sum_left + dd(j);
%               sum_right = sum_right - dd(j);
%               if sum_left > sum_right
%                 break;
%               end
%             end
            jj = m2;    % this should be even faster than the commented code above
            sum_left = sum(dd(1:jj));
            sum_right = sum(dd(jj+1:m));
            if sum_left < sum_right
              for j = jj+1 : m
                sum_left = sum_left + dd(j);
                sum_right = sum_right - dd(j);
                if sum_left > sum_right
                  break;
                end
              end
            else        % sum_left > sum_right
              for j = jj : -1 : 1
                sum_left = sum_left - dd(j);
                sum_right = sum_right + dd(j);
                if sum_left < sum_right
                  break;
                end
              end
            end
            xk(i) = c(ic(j));
            r = r - d*xk(i);
          end
        end
      end
    end
    %xi(i)
    %xk'
    r = y - Dk*xk;
    %norm(r,1)
  end
  X(support, ell) = xk;
end
