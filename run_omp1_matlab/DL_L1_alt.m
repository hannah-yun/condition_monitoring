function D = DL_L1_alt(Y, D0, s, iters)

% Dictionary learning with L1 norm using alternate optimization.
%
% Input:
%   Y       - training data matrix
%   D0      - initial dictionary
%   s       - sparsity level (number of nonzero coefficients per representation
%   iters   - number of iterations
% Output:
%   D       - trained dictionary

% BD 27.04.2020

N = size(Y, 2);
D = D0;
[m,n] = size(D);

for it = 1 : iters
    % sparse coding
    X = omp_l1(Y, D, s);
    
    % dictionary update
    E = Y - D*X;
    for k = 1:n
        shrk_idx = find(X(k,:));
        % compl_idx = setdiff(1:N, shrk_idx);
        if ~isempty(shrk_idx)
          x = X(k,shrk_idx);
          smallEk = E(:,shrk_idx) + D(:,k)*x;
            
          % norm 1 approximation with rank 1
          % optimize atom
          [~, nr] = size(smallEk);
          d = zeros(m,1);
          for i = 1 : m
          c = smallEk(i,:) ./ x;  % candidates to optimal value
%           [~,ii] = min(sum(abs(repmat(smallEk(i,:),n,1)-c'*x), 2)); % old version: compute objective for all candidates
%           d(i) = c(ii);
          [~,ic] = sort(c);  % order candidates
          xx = abs(x(ic));
          sum_left = 0;
          sum_right = sum(xx);
          for j = 1 : nr     % find candidate that tips balance left-right (derivative switches sign)
            sum_left = sum_left + xx(j);
            sum_right = sum_right - xx(j);
            if sum_left > sum_right
              break;
            end
          end
          d(i) = c(ic(j));
          end
          d = d / norm(d);
          x = zeros(1,nr);
          % optimize representation - same algorithm
          for i = 1 : nr
            c = smallEk(:,i) ./ d;
%             [~,ii] = min(sum(abs(repmat(smallEk(:,i),1,m)-d*c')));
%             x(i) = c(ii);
            [~,ic] = sort(c);
            dd = abs(d(ic));
            sum_left = 0;
            sum_right = sum(dd);
            for j = 1 : m
              sum_left = sum_left + dd(j);
              sum_right = sum_right - dd(j);
              if sum_left > sum_right
                break;
              end
            end
            x(i) = c(ic(j));
          end
          D(:,k) = d;
          X(k,shrk_idx) = x;
          % restore error matrix
%              E = Ek - D(:,k)*X(k,:);
          E(:,shrk_idx) = smallEk - d*x;
          %sum(sum(abs(E))), pause
        else    % unused atom, replace with random vector
          d = randn(m,1);
          D(:,k) = d / norm(d);
        end
    end
    sum(sum(abs(E)))/m/N;
end
