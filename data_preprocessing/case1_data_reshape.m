%%%% data preparation to apply the file to the algorithm

% Step 1: Get list of all files in the folder
healthy_path = 'Healthy'; 
damaged_path = 'Damaged';
% Process healthy and damaged folders
healthy_data = processFolder(healthy_path);
damaged_data = processFolder(damaged_path);

% Append healthy and damaged data vertically
sig_segments = [healthy_data, damaged_data];

% Display the size of the final data
disp(['signal segment size: ', num2str(size(sig_segments))]);

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
        column_data = mat_data.AN5; % Select the column name (CHECK)
        
        % Reshape the column into 40000 x 60
        reshaped_data = reshape(column_data, 40000, 60);
        
        % Concatenate horizontally (column bind)
        folder_data = [folder_data, reshaped_data];
    end
end

% Step 6: Save the result 
save('sig_segments.mat', 'sig_segments');
