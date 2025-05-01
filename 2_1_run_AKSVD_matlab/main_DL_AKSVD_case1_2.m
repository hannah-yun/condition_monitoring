%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script for Case I and II (Number of iterations are the same) for AKSVD
% Before running this code, please download DL packages first.

% Data file
file_name = '_welch_nrel_AN5_3500.mat'; % change the file name accordingly
% Load the dataset
data = load(file_name);
ndata = data.slice_data;
% Extract vibration data
vibdata = ndata(1:21,2:end); % exclude frequency column

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = 200;                     % number of training signals
nu = size(vibdata,2)-N-1;    % number of iterations
vs = [3 4 5];                % sparsity levels
facn = [2 3];                % factor dict. size

% Initialize matrices with Inf 
vEBIC = Inf(nu,length(facn)); % EBIC
vdist = Inf(nu,length(facn)); % The dictionary distance
vbests = Inf(nu,length(facn)); % Sparsity
vt = Inf(nu,length(facn)); % time count
one_bests = Inf(1,length(facn)); 

% Run a loop for each segment
tic;
for j=1:length(facn)
    [vEBIC(:,j),vdist(:,j),vbests(:,j),vt(:,j),~,one_bests(:,j)] = DL_AKSVD_simulation(vibdata,nu,N,facn(j),vs);
end
vbests = [one_bests; vbests];
toc;

% Time difference
time_gap = tic-toc;

% Report the percentage that 3m shows smaller EBIC than 2m 
fprintf('\n ************** \n');
fprintf('Proc. sel. 3m = %5.2f\n', 100*sum(vEBIC(:,2)<vEBIC(:,1))/nu);

% Plotting
subplot(3,2,1)
plot(N+2:N+nu+1,vEBIC(:,1),'k');
ylabel('EBIC');
legend('2m')

subplot(3,2,2)
plot(N+2:N+nu+1,vEBIC(:,2),'k');
ylabel('EBIC');
legend('3m')

subplot(3,2,3)
plot(N+1:N+nu+1,vbests(:,1),'b');
ylabel('s');
legend('2m')

subplot(3,2,4)
plot(N+1:N+nu+1,vbests(:,2),'b');
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



