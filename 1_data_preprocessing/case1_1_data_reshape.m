%%%% data preparation to apply the file to the algorithm
%%%% Please run this file first and then run case1_2 for applying welch
%%%% method

% Step 1: Get list of all files in the folder
% Set the paths for healthy and unhealthy vibration signals
healthy_path = 'Healthy'; % path
damaged_path = 'Damaged'; % path

% Import two paths
healthy_data = processFolder(healthy_path);
damaged_data = processFolder(damaged_path);

% Combine healthy and damaged data side by side (horizontally)
sig_segments = [healthy_data, damaged_data];

% Show the size of the final data
disp(['signal segment size: ', num2str(size(sig_segments))]);

% Get a list of all .mat files in the given folder and counts them.
function folder_data = processFolder(folder_path)
    % List all .mat files in the folder
    mat_files = dir(fullfile(folder_path, '*.mat'));
    num_files = length(mat_files);
    
    % Initialize an empty array for concatenated data
    folder_data = [];
    
    for i = 1:num_files
        % Load the .mat file
        file_path = fullfile(folder_path, mat_files(i).name);
        mat_data = load(file_path);
        
        % Assuming the column is stored in a variable called 'data'
        % Replace 'data' with the actual variable name in your .mat files
        column_data = mat_data.AN5; % Select the column name (AN5/AN6/AN7)
        
        %  Each signal is reshaped to have 60 columns, each with 40000 rows
        reshaped_data = reshape(column_data, 40000, 60);
        
        % Concatenate horizontally to one big matrix
        folder_data = [folder_data, reshaped_data];
    end
end

% Step 6: Save the result 
save('sig_segments.mat', 'sig_segments');