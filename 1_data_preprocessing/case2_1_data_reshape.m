%%%% data preparation to apply the file to the algorithm
%%%% Please run this file first for case 2 and run case2_2 for applying
%%%% welch method

% Step 1: Get a list of all .mat files in the current folder
% Set the paths the vibration signals
folder_path = cd; % Replace with your folder path
files = dir(fullfile(folder_path, '*.mat')); 

% Initialize an empty array to store the signal segments 
sig_segments = []; 

% Step 2: Loop through each file
for i = 1:length(files)
    % Load the current .mat file
    file_path = fullfile(folder_path, files(i).name);
    data = load(file_path); 

    % Step 3: Extract accH column (horizontal acceleration signal)
    accH = data.accH; 

    % Step 4: Reshape the data to 8192 × 75 segments
    reshaped_data = reshape(accH, 8192, 75); 

    % Step 5: Concatenate the reshaped data horizontally
    sig_segments = [sig_segments, reshaped_data]; 
end

% Step 6: Save the resulting signal segments to a .mat file
save('sig_segments.mat', 'sig_segments');