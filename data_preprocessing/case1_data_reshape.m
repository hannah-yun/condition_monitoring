%%%% data preparation to apply the file to the algorithm

% Step 1: Get list of all files in the folder
folder_path = 'folder_path'; % Replace with your folder path
files = dir(fullfile(folder_path, '*.mat')); % Assuming .mat files; modify for other formats

sig_segments = []; % Initialise empty matrix for column binding 

% Step 2: Loop through each file
for i = 1:length(files)
    % Load the file
    file_path = fullfile(folder_path, files(i).name);
    data = load(file_path); % Assuming the file contains a variable with accH column

    % Step 3: Extract accH column (acceleration in horizontal direction)
    accH = data.accH; 

    % Step 4: Reshape the data
    reshaped_data = reshape(accH, 8192, 75); % Reshape to 8192 × 75

    % Step 5: Column bind
    sig_segments = [sig_segments, reshaped_data]; % Append reshaped data horizontally
end

% Step 6: Save the result 
save('sig_segments.mat', 'sig_segments');