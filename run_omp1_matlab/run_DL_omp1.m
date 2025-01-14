
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data file
file_name = 'case2_sliced_welch.mat'; 
% Load the dataset
data = load(file_name);
ndata = data.slice_data;
% Extract vibration data
vibdata = ndata(:, 2:end);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = 200;                     % number of training signals
nu = size(vibdata,2)-N-1;    % number of iterations
vs = [3 4 5];                % sparsity levels
facn = [2 3];                % factor dict. size

vEBIC = Inf(nu,length(facn));
vdist = Inf(nu,length(facn));
vbests = Inf(nu,length(facn));
vt = Inf(nu,length(facn));

for j=1:length(facn)
    [vEBIC(:,j),vdist(:,j),vbests(:,j),vt(:,j),bestD] = DL_omp1_simulation_2(vibdata,nu,N,facn(j),vs);
end

fprintf('\n ************** \n');
fprintf('Proc. sel. 3m = %5.2f\n', 100*sum(vEBIC(:,2)<vEBIC(:,1))/nu);

subplot(3,2,1)
plot(N+2:N+nu+1,vEBIC(:,1),'k');
ylabel('EBIC');
legend('2m')

subplot(3,2,2)
plot(N+2:N+nu+1,vEBIC(:,2),'k');
ylabel('EBIC');
legend('3m')

subplot(3,2,3)
plot(N+2:N+nu+1,vbests(:,1),'b');
ylabel('s');
legend('2m')

subplot(3,2,4)
plot(N+2:N+nu+1,vbests(:,2),'b');
ylabel('s');
legend('3m')

subplot(3,2,5)
plot(N+2:N+nu+1,vdist(:,1),'r');
ylabel('dist');
legend('2m')

subplot(3,2,6)
plot(N+2:N+nu+1,vdist(:,2),'r');
ylabel('dist');
legend('3m')


