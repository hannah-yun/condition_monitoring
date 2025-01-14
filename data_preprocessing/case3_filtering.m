%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Steps: 
%   0. Divide into entire segment / blocked segment / Welch method
%   1. Envelope Analysis 
%       1.1 Highpass (1000 Hz)
%       1.2 full-wave rectification
%       1.3 Lowpass (200 Hz)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Information about the signal
Fs = 12800;            % Sampling frequency

% Data Import (csv file)
file_name = 'DATASET05.csv';
raw_data = readtable(file_name);
data_array = table2array(raw_data);

% Assign the dataset name
time_vec = data_array(:, 1);
YN = data_array(:,3:end)'; %transpose the data

[a, b] = size(YN); %save the size

filter_mtx = zeros(a,b);

highv = 1000;
lowv = 200;

for i = 1:b
    test = YN(:,i);
    hiv = bandpass(test, [highv 6350], Fs); % prevent error when approaching nyquist frequency
    recv = abs(hiv);
    filter_mtx(:,i) = lowpass(recv, lowv, Fs);
    if mod(i, 100) == 0
            fprintf('Iter: %d\n', i);
    end 
end


save('filtered_T5.mat', "filter_mtx","time_vec");

