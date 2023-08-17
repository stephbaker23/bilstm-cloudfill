## Overview ##
The files in this folder are the data files associated with the paper S. Baker, Z. Huang and B. Philippa, "Lightweight Neural Network for Spatiotemporal Filling of Data Gaps in Sea Surface Temperature Images," in IEEE Transactions on Geoscience and Remote Sensing, vol. 61, pp. 1-10, 2023, Art no. 4204310, doi: 10.1109/TGRS.2023.3273575.

## File descriptions ##
### TrainingDataFrom2019.nc
This is the .nc file containing all training data from July 2019 - June 2020. It contains 1,690 images comprised of 130 unique images each augmented with 13 unique clouds.

### TrainingTargetsFrom2019.nc
This file contains the target images associated with the training data in "TrainingDataFrom2019.nc". It contains the 130 unique targets images. 

### TestingDataFrom2020.nc
This is the .nc file containing all testing data from July 2020 - June 2021. It contains 975 images comprised of 75 unique images each augmented with 13 unique clouds.

### TestingTargetsFrom2020.nc
This file contains the target images associated with the testing data in "TestingDataFrom2020.nc". It contains the 75 unique target images.

### H08SST_Jul2019_Jun2020.nc
This file contains the original SST images from July 2019 - June 2020, used to find temporally neighbouring pixels.

### H08SST_Jul2020_Jun2021.nc
This file contains the original SST images from July 2020 - June 2021, used to find temporally neighbouring pixels.
