#This R script extracts the cycle number for Test 1 or Test 2 from the filenames in the folder.

# Define the path to the folder containing the files
folder_path = "folder" # set different folder for test1 and test2

# List all files in the folder with full paths
ascii_files <- list.files(path = folder_path, full.names = TRUE)

# Initialize a numeric vector to store cycle numbers
num_cycles <- numeric()

# Loop over each file to extract the cycle number from the filename
for (i in 1:length(ascii_files)) {
  file_path <- ascii_files[i]
  num_cycles[i] <- as.numeric(sub(".*_([0-9]+)_.*", "\\1", file_path))
}

