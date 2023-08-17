# File overview
This folder contains the NetCDF files that are used for all training and testing. They were built by taking cloud-free images and augmenting them with real cloud masks.

These were the files that were processed by the nearest neighbour code to generate the bulk CSV files.

### TrainingData8020.nc
Contains the cloudy images for training. Dimensions are latitude, longitude, time, and SST. Time is in 'number of days from 1 July 2019'.

### TrainingTargets8020.nc
Contains the clear images for use as training targets. Dimensions are as above.

### TestingData8020.nc
Contains the cloudy images for testing. Dimensions are as above.

### TestingTargets8020.nc
Contains the clear images for use as testing targets. Dimensions are as above.

**Note:** You can use functions such as ncdisp(filename) and ncread(filename, attribute) in Matlab to get an understanding of the contents of these files.
