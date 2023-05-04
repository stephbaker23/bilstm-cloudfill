# Folder overview

### 100 Neighbours
Contains the CSV files for training and testing using nearest neigbhours Euclidean distance. Filename formats are as follows:
- training100NPixels*X*.csv - neighbour lists for training. Each file contains contains 200 columns and up to 100000 rows. Each row represents the neighbour list for a particular pixel. Distances appear next to their corresponding neighbour value (which is in deg C), so there is information for up to 100 nearest neighbours for each pixel.
- testing100NPixels*X*.csv - neighbour lists for testing. File format is as above.
- training100NTargets*X*.csv - targets for training. Each file contains 5 columns. Column 1 is the training target, columns 2-5 contain the x, y, time, cloud position that can be used for reconstructing the images later on.
- testing100NTargets*X*.csv - targets for testing. File format is as above.

### 100 Neighbours XYT
Contains the CSV files for training and testing using nearest neighbours and XYT coordinates. File formats are the same as for the **100 Neighbours** folder, only difference is there's an 'XYT' added to each filename. 
