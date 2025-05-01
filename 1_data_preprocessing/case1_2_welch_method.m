
    % Parameters
    Fs =40000;  % Sampling frequency (Hz)
    L = 40000;  % Length of signal

    % Load the data file (update the filename/path if needed)
    folder_path = cd;
    raw_data = 'sig_segments.mat';
    data = load(raw_data);
    
    % set the data matrix 
    Y = data.sig_segments;

    % Assign Y to x_input
    x_input = Y; 
    % Convert table to numeric array
    x_input = table2array(x_input);

    % Define the frequency vector using Welch's method 
    [~, f] = pwelch(x_input(:,1), 1024,512,1024, Fs); % length 1024
    itr = size(x_input, 2);

    % Initialize the matrix
    psd_welch = zeros(length(f), itr + 1);

    % Assign the frequency vector to the first column
    psd_welch(:, 1) = f;

    for i = 1:itr
        signal = x_input(:, i);

        % Skip or error if input signal does not have expected length
        if length(signal) ~= L
            error('Length of signal does not match L');
        end

        % Compute the PSD using pwelch
        [Pxx, ~] = pwelch(signal, 1024,512,1024,Fs);

        % Store the PSD values in the corresponding column of the matrix
        psd_welch(:, i + 1) = Pxx;

        % Print iteration progress every 50 steps
        if mod(i, 50) == 0
            fprintf('Iteration number: %d\n', i);
        end    
    
    end % loop

    % Slice data: keep only frequencies ≤ 1000 Hz (adjust this value if needed) 
    inds = psd_welch(:,1) <= 1000; 

    % Keep only the rows corresponding to selected frequency range
    slice_data = psd_welch(inds,:);
    
    % Save sliced data to .mat file
    save("case1_sliced_welch.mat", 'slice_data');

