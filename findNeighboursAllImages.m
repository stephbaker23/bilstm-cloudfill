function findNeighboursAllImages()

% CHECK ALL OF THIS BEFORE RUNNING
outDir % = Directory for storing outputs
outFile % = Filename prefix for outputs
dataFilename %=  Path to TrainingDataFrom2019.nc (for training) or to TestingDataFrom2020.nc (for testing)
targetFilename % = Path to TestingTargetFrom2019.nc (for training) or to TestingTargetsFrom2020.nc (for testing)
allFilename % = Path to H08SST_Jul2019_Jun2020.nc (for training) or to H08SST_Jul2020_Jun2021.nc (for testing)

numClouds = 13;

% CSV files for saving neighbours
inputFilename = outDir + outFile + "Pixels0.csv"
inputFileID = fopen(inputFilename, 'w');
outputFilename = outDir + outFile + "Targets0.csv"
outputFileID = fopen(outputFilename, 'w');

% Load required files - training data + all SST for finding temporal
% neighbours
trainingSst = ncread(dataFilename, 'sst');
trainingTime = ncread(dataFilename, 'time');
allSst = ncread(allFilename, 'sst');
allTime = ncread(allFilename, 'time');
targetSst = ncread(targetFilename, 'sst');
targetTime = ncread(targetFilename, 'time');

% Lat and long are same for all images
longitude = ncread(dataFilename, 'longitude');
latitude = ncread(dataFilename, 'latitude');

% File counter
recordCounter = 1;

% Loop through all days
for dayIndex = 1:366
    % Check whether the day has any images; if it does, loop through all
    % clouds
    allImagesForDay = find(trainingTime == dayIndex);
    if ~isempty(allImagesForDay)
        for cloudIndex = 1:numClouds
            fprintf("Day: %d, Cloud: %d\n", dayIndex, cloudIndex); % Prints where code is up to
            currentImage = allImagesForDay(cloudIndex);
            
            imageSize = length(longitude) * length(latitude);
            
            % Find the clouds
            clouds = double(isnan(trainingSst(:, :, currentImage)'));
            
            % Start cloud mask
            cloudMap = clouds;
            cloudMap(cloudMap == 0) = NaN;
            
            % Get the target image
            targetImage = targetSst(:, :, find(targetTime == (dayIndex)))';
            figure(1)
            pcolor(targetImage);
            figure(2);
                       
            % For each edge pixel, find the nearest neighbours
            numNearestNeighbours = 100;
            temporalNeighbours = 3; % in each direction (+/-)
            arraySize = imageSize * (1+(temporalNeighbours*2));
            daysToCheck = -temporalNeighbours:temporalNeighbours;
            
            % Arrays for storing neighbour info temporarily
            % Default value is 9999 (arbitrarily large) for compatibility
            % with distance metric in the machine learning step
            allNeighbours.x = 9999*ones(1, arraySize);
            allNeighbours.y = 9999*ones(1, arraySize);
            allNeighbours.temp = 9999*ones(1, arraySize);
            allNeighbours.time = 9999*ones(1, arraySize);
            
            % Days to check
            counter = 1;
            for day = daysToCheck
                % if the day is a neighbour, shift by the index and grab
                % the SST 
                if day ~= 0
                    shiftedDay = dayIndex + day;
                    if shiftedDay > 0 && shiftedDay < length(allTime)
                        sstImage = allSst(:, :, find(allTime == dayIndex + day - 1))';
                        % Loop through all pixels and store the position
                        % and value of any neighbour pixel where there is
                        % data (i.e. non-NaN neighbours)
                        for x = 1:length(longitude)
                            for y = 1:length(latitude)
                                if ~(isnan(sstImage(x, y)))
                                    allNeighbours.x(counter) = x;
                                    allNeighbours.y(counter) = y;
                                    allNeighbours.temp(counter) = sstImage(x, y);
                                    allNeighbours.time(counter) = day;
                                end
                                counter = counter + 1;
                            end
                        end
                    end
                else
                    sstImage = trainingSst(:, :, currentImage)';
                    % Loop through all pixels and store the position
                    % and value of any neighbour pixel where there is
                    % data (i.e. non-NaN neighbours)
                    for x = 1:length(longitude)
                        for y = 1:length(latitude)
                            if ~(isnan(sstImage(x, y)))
                                allNeighbours.x(counter) = x;
                                allNeighbours.y(counter) = y;
                                allNeighbours.temp(counter) = sstImage(x, y);
                                allNeighbours.time(counter) = day;
                            end
                            counter = counter + 1;
                        end
                    end
                end
            end
            
            % Get coordinates of cloud pixels
            [relevantPixelsX, relevantPixelsY] = find(cloudMap == 1);
            numPixels = length(relevantPixelsX);
            
            % Create struct for saving nearest neighbours
            nearestNeighbours.x = 9999*ones(numPixels, numNearestNeighbours*7);
            nearestNeighbours.xDist = 9999*ones(numPixels, numNearestNeighbours*7);
            nearestNeighbours.y = 9999*ones(numPixels, numNearestNeighbours*7);
            nearestNeighbours.yDist = 9999*ones(numPixels, numNearestNeighbours*7);
            nearestNeighbours.dist = 9999*ones(numPixels, numNearestNeighbours*7);
            nearestNeighbours.temp = 9999*ones(numPixels, numNearestNeighbours*7);
            nearestNeighbours.time = 9999*ones(numPixels, numNearestNeighbours*7);
            
            % Store the nearest euclidean neighbours from each day of
            % interest - only need 100 closest from each day as the ML step
            % uses 100 altogether; therefore it's not necessary to store
            % more than 100 from each day as the ML program will never need
            % more than that
            for i = 1:length(relevantPixelsX)
                allNeighbourDistances = sqrt((relevantPixelsX(i) - allNeighbours.x).^2 + ...
                    (relevantPixelsY(i) - allNeighbours.y).^2);
                
                
                % Set up arrays with default values for missing nums
                allDistances = ones(1, 700) * 9999;
                allIndices = ones(1, 700) * (-1);
                
                % Loop through each day
                for j = -3:3
                    % Find smallest distances and the indices they occur at
                    currentNeighbourDistances = allNeighbourDistances;
                    
                    % If any days are missing, skip
                    if ~any(allNeighbours.time == j)
                        continue;
                    end
                                      
                    % Find start and stop points for this day within the
                    % array
                    startIndex = ((j+3)*100)+1;
                    stopIndex = startIndex + numNearestNeighbours - 1;

                    % Grab 100 closest neighbours for this day
                    [allDistances(startIndex:stopIndex), allIndices(startIndex: stopIndex)] ...
                        = mink(currentNeighbourDistances, numNearestNeighbours);
                    
                end
                
                % Build final arrays for output
                allIndices = unique(allIndices(allIndices~=-1));
                nearestNeighbours.x(i, 1:length(allIndices)) = allNeighbours.x(allIndices);
                nearestNeighbours.xDist(i, 1:length(allIndices)) = relevantPixelsX(i) - allNeighbours.x(allIndices);
                nearestNeighbours.y(i, 1:length(allIndices)) = allNeighbours.y(allIndices);
                nearestNeighbours.yDist(i, 1:length(allIndices)) = relevantPixelsY(i) - allNeighbours.y(allIndices);
                nearestNeighbours.time(i, 1:length(allIndices)) = allNeighbours.time(allIndices);
                nearestNeighbours.temp(i, 1:length(allIndices)) = allNeighbours.temp(allIndices);
                nearestNeighbours.dist(i, 1:length(allIndices)) = allNeighbourDistances(allIndices);
            end
        
           % Save the data as CSV files
            for i = 1:numPixels
                recordMaxLength = 10000;
                % Found 10000 to be max record length without issues, so
                % close and start new file.
                if mod(recordCounter, recordMaxLength) == 0
                    fclose(inputFileID);
                    fclose(outputFileID);
                    inputFilename = outDir + outFile + "Pixels" + num2str(recordCounter/recordMaxLength) + ".csv";
                    inputFileID = fopen(inputFilename, 'w');
                    outputFilename = outDir + outFile + "Targets" + num2str(recordCounter/recordMaxLength) + ".csv";
                    outputFileID = fopen(outputFilename, 'w');
                end
                targetTemp = targetImage(relevantPixelsX(i), relevantPixelsY(i));
                
                % Interleave data for the inputs and generate format
                inputs = ones(1, 4*numNearestNeighbours*7);
                inputs(1:4:end) = nearestNeighbours.xDist(i, :);
                inputs(2:4:end) = nearestNeighbours.yDist(i, :);
                inputs(3:4:end) = nearestNeighbours.time(i, :);
                inputs(4:4:end) = nearestNeighbours.temp(i, :);
                inputStringFormat = [repmat('%f,', 1, 7*numNearestNeighbours*4-1) '%f\n'];

                % Save the files
                inputString = fprintf(inputFileID, inputStringFormat, inputs);
                outputString = fprintf(outputFileID, '%f,%f,%f,%d,%d\n', targetTemp, relevantPixelsX(i), relevantPixelsY(i), dayIndex, cloudIndex);
                recordCounter = recordCounter + 1;
            end            
        end
    end
end

fclose(inputFileID);
fclose(outputFileID);
end
