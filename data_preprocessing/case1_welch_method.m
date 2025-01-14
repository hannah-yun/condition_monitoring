
    % Parameters
    Fs =40000;  %Sampling frequency (Hz)
    L = 40000;  %Length of signal

    % Load the data (need to change depending on the folder)
    folder_path = cd;
    raw_data = 'sig_segments.mat';
    data = load(raw_data);

    Y = data.sig_segments;

   % Y = filter_mtx;
    x_input = Y; % Assuming you are interested in the first three columns
    
    x_input = table2array(x_input);

    % Define the frequency vector for PSD
    [~, f] = pwelch(x_input(:,1), 1024,512,1024, Fs);
    itr = size(x_input, 2);

    % Initialize the matrix
    psd_welch = zeros(length(f), itr + 1);

    % Assign the frequency vector to the first column
    psd_welch(:, 1) = f;

    for i = 1:itr
        signal = x_input(:, i);

        % Check if the length of signal matches L
        if length(signal) ~= L
            error('Length of signal does not match L');
        end

        % Compute the PSD using pwelch
        [Pxx, ~] = pwelch(signal, 1024,512,1024,Fs);

        % Store the PSD values in the corresponding column of the matrix
        psd_welch(:, i + 1) = Pxx;

        % Print the iteration number every 50th loop
        if mod(i, 50) == 0
            fprintf('Iteration number: %d\n', i);
        end    
    
    end % loop

    % Data slicing
    % find the indices where the fequency is less than or equal to 1000Hz
    % need to be changed depending on the cutoff frequency 
    inds = psd_welch(:,1) <= 1000; 

    % slice the dataset to keep rows for the frequencies
    slice_data = psd_welch(inds,:);
    
    % Save sliced data to .mat file
    save("case1_sliced_welch.mat", 'slice_data');

