## BiLSTM Cloudfill Project ##
These are the supplementary and coding files associated with the following publication, which should be cited by any works using the data or code:

S. Baker, Z. Huang and B. Philippa, "Lightweight Neural Network for Spatiotemporal Filling of Data Gaps in Sea Surface Temperature Images," in IEEE Transactions on Geoscience and Remote Sensing, vol. 61, pp. 1-10, 2023, Art no. 4204310, doi: 10.1109/TGRS.2023.3273575.

## Code pipeline
This code includes the full pipeline from data preprocessing through to model training through to image filling. The order of use is as follows: 
- findNeighboursAllImages.m is a Matlab file used to extract the 100 nearest neighbouring pixels from all spatial neighbours of interest, using the SST NetCDF files hosted at the above link. Information describing the value and location of the neighbouring pixels are stored in CSV files. Target pixel values are also stored as CSV files.
- "Convert CSV to Npy for BiLSTM Cloud Fill - Clean Copy.ipynb" is a Jupyter Notebook used to convert CSV files from previous step to Npy files - it was found that this file format accelerated machine learning across multiple files.
- "BiLSTM Model Training - Clean Copy.ipynb" - is a Jupyter notebook used for training the BiLSTM cloud fill model described in our paper.
- "Image Filler for BiLSTM Cloud Fill - Clean Copy.ipynb" is a Jupyter notebook used for gapfilling cloudy images from the testing set using the trained BiLSTM model

## Data 
The folder "NCData" contains all raw .nc files used for this project. This data can be processed using our code pipeline, or alternative methods. Full details on the files can be found in NCData > readme
