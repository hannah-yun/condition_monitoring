%%%% data reshape and filtering before running the DL algorithm
%%%% Please run this file first for case 3 and run case3_2 for applying
%%%% welch method

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Processing Steps:
%   0. Segmenting options (not applied in this script):
%       - Entire segment
%       - Blocked segment
%       - Welch method
%   1. Envelope Analysis:
%       1.1 High-pass filter (cutoff at 1000 Hz)
%       1.2 Full-wave rectification
%       1.3 Low-pass filter (cutoff at 200 Hz)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Sampling frequency
Fs = 12800;            

% Step 1: Load the data from a CSV file
file_name = 'DATASET05.csv'; % change the file name accordlingly
raw_data = readtable(file_name);
data_array = table2array(raw_data);

% Step 2: Assign the dataset variables
time_vec = data_array(:, 1); % time vector
YN = data_array(:,3:end)'; % transpose the data (signal x time)

% Dimensions: a = length of each singal, b = number of time collected
[a, b] = size(YN); %save the size

% Initialize filtered output matrix
filter_mtx = zeros(a,b);

% Filter parameters
highv = 1000;                       % High-pass cutoff frequency (Hz)
lowv = 200;                         % Low-pass cutoff frequency (Hz)

% Step 3: Envelope analysis for each signal
for i = 1:b
    test = YN(:, i);                                     % Extract current signal
    hiv = bandpass(test, [highv 6350], Fs);              % Step 1.1: High-pass filter
    recv = abs(hiv);                                     % Step 1.2: Full-wave rectification
    filter_mtx(:, i) = lowpass(recv, lowv, Fs);          % Step 1.3: Low-pass filter

    if mod(i, 100) == 0
        fprintf('Iter: %d\n', i);                        % Progress print every 100 iterations
    end 
end

% Step 4: Save the filtered result (change the file name if needed)
save('filtered_T5.mat', "filter_mtx","time_vec");

