
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script for Case III (Number of iterations are differnet depending on Number of training signals)
% Data file
folder_path = cd;

% Specify the relative file path and file name
file_name = '_welch_T1_every_data_slice.mat';

% Load the dataset
data = load(file_name);
ndata = data.slice_data; 

% Extract vibration data
vibdata = ndata(3:end, 2:end);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vN = [200 300];                  % Number of training signals
vs = [3 4 5];                    % Sparsity levels
facn = [2 3];                    % Factor dict. size

% Initialize cell arrays for results
vEBIC = cell(1, length(facn)); % EBIC
vdist = cell(1, length(facn)); % dictionary distance
vbests = cell(1, length(facn)); % sparsity levels
vt = cell(1, length(facn));

% Run a loop for each segment
for j = 1:length(facn)
    N = vN(j);                   % Number of training signals   
    nu = size(vibdata, 2) - N - 1; % Number of iterations

    % Run simulation for current parameters
    [vEBIC{j}, vdist{j}, vbests{j}, vt{j}, ~] = DL_AKSVD_simulation(vibdata, nu, N, facn(j), vs);
end

fprintf('\n ************** \n');
%fprintf('Proc. sel. 3m = %5.2f\n', 100*sum(vEBIC{1,2}<vEBIC{1,1})/nu);

% plotting 
% set up the number of segments for plotting due to difference in
% iterations
nu1 = size(vibdata, 2) - vN(1) - 1; 
nu2 = size(vibdata, 2) - vN(2) - 1;


subplot(3,2,1)
plot(vN(1)+2:vN(1)+nu1+1,vEBIC{1,1},'k');
ylabel('EBIC');
legend('2m')

subplot(3,2,2)
plot(vN(2)+2:vN(2)+nu2+1,vEBIC{1,2},'k');
ylabel('EBIC');
legend('3m')

subplot(3,2,3)
plot(vN(1)+2:vN(1)+nu1+1,vbests{1,1},'b');
ylabel('s');
legend('2m')

subplot(3,2,4)
plot(vN(2)+2:vN(2)+nu2+1,vbests{1,2},'b');
ylabel('s');
legend('3m')

subplot(3,2,5)
plot(vN(1)+2:vN(1)+nu1+1,vdist{1,1},'r');
ylabel('dist');
legend('2m')

subplot(3,2,6)
plot(vN(2)+2:vN(2)+nu2+1,vdist{1,2},'r');
ylabel('dist');
legend('3m')



