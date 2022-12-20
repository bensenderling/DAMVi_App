function csv_Delsys = load_csv_Delsys(file)
% csv_Delsys = load_csv_Delsys(file)
% inputs  - file, directory and file name to import
% outputs - dataout, structure containing data from a Delsys system
% Remarks
% - This code is written to load data exported from Delsys as a csv format. It is writen in a general manner so that it does not matter how many 
%   columns of data there are. It will automatically parse the column headers for the channel names. Those name are then used to create structure 
%   fields that store the data.
% - The output format is specific for the BAR App.
% - While the code is (hopefully) written in a way that allow a time column to be located only in the first column. It is suggested that the data be 
%   exported with a time column for each column of data. Since the Trigno channels sample at two different frequencies this makes figuring out the 
%   time for each channel much easier. There is also a mismatch where IMU channels have longer time columns than they should.
% - This code reads in one line at a time. This will be slower than csvread for shorter files but will be faster and more efficient for longer files.
% Future Work
% - It could be made more complicated and flexible to load older Delsys files.
% - This code will need to be updated as Delsys updates their software, as it is likely they will change the output format.
% Sep 2022 - Created by Ben Senderling, bsender@bu.edu
% Dec 2022 - Modified by Ben Senderling, bsender@bu.edu
%          - Added some fixes for variable data lengths.
%% Begin Code

% The file will be opened and read line by line. The files can be quite
% large and this has proven a better option than MATLAB's native functions.
fid = fopen(file);

% Initialize the output structure.
csv_Delsys = struct;

% Get the first line.
line = fgetl(fid);

% Count the lines to help read the data latter. This is used to initialize
% an empty array for the data.
count = 1;

% If headers are present they will be used to extract sampling information
while strcmp(line(1:5),'Label')
    
    % Find an index for the EMG and ACC labels
    ind1 = strfind(line,':');
    % Find an index for the EMG and ACC labels and sampling frequency
    ind2 = strfind(line,'Sampling');
    % Find an index for the number of data points
    ind3 = strfind(line,'Number');
    % Get the channel name.
    channel = line(ind1(2) + 2:ind2 - 2);
    % There may be characters pressent that can not be in structure fields.
    channel = regexprep(channel, {' ', '[.]'}, {'_', '_'});

    % This is used to help condense the components of each measurment into single objects. It is assumed the order is X-Y-Z.
    if contains(channel, 'dEMG')
        measure = 'dEMG';
    elseif contains(channel, 'ACC')
        measure = ['IMU_' channel(7:8)];
    elseif contains(channel, 'GYRO')
        measure = ['IMU_' channel(8:9)];
    else
        % This will mostly be other EMG channels.
        measure = channel;
    end

    % Get the sampling frequency.
    sampfreq = str2double(line(ind2 + 20:ind3 - 2));
    csv_Delsys.(measure).freq = sampfreq;
    
    % Get the next line.
    line = fgetl(fid);
    % Add another 1 to the line count.
    count = count + 1; 
    
end

% Keep reading lines until one of two possible time column headers are 
% found.
while ~strcmp(line(1),'X') && ~strcmp(line(1),'T')
    line = fgetl(fid);
    count = count + 1;
end

% Read the headers from the current line.
headers = textscan(line, '%s', 'delimiter', ','); % parses headers and seperates them for each column
headers = headers{1};

% Count lines the remaining number of lines.
count2 = 1;
while ~feof(fid)
    line = fgetl(fid);
    count2 = count2 + 1;
end

% Rewind the line indicator to the top of the file.
frewind(fid)
% Read as many lines as needed to get to the data below the headers.
for i = 1:count
    line = fgetl(fid);
end

% Create an empty array using the counts.
data = zeros(count2 - 1, length(headers));
% Load the data line-by-line and assign it to a data array.
count2 = 1;
while ~feof(fid)
    line = fgetl(fid);
    line = textscan(line,'%f','delimiter',',');
    data(count2, :) = line{1}';
    count2 = count2 + 1;
end

% Close the file.
fclose(fid);

% Replace any NaNs with zeros.
data(isnan(data)) = 0;

% Assign the data to structure fields.
for i = 1:length(headers)
    
    % Time may be stored differently depending on the file.
    if strcmp(headers{i},'X[s]') || strcmp(headers{i},'Time')
        time = data(:,i);
        % The data may be padded with 0s. These can only be used to
        % reliably find the actual length of the data using the time
        % column. The first 0 is time = 0. The next zero is after the last
        % data sample. This result is retained if multiple data columns
        % follow a single time column.
        if time(end) == 0
            ind4 = find(time == 0);
            ind4(1) = [];
            time(ind4) = [];
        end
    else 
        % The channel name is assumed to be between specific characters.
        ind1 = strfind(headers{i}, ':');
        ind2 = strfind(headers{i}, '"');
        channel = headers{i}(ind1 + 2:ind2(2) - 1);

        % Remove invalid characters from the channel name. This line does need to be the same as that above.
        channel = regexprep(channel, {' ', '[.]'}, {'_', '_'});

        % This is used to help condense the components of each measurment into single objects. It is assumed the order is X-Y-Z.
        if contains(channel, 'dEMG')
            measure = 'dEMG';
            signal = 'emg';
        elseif contains(channel, 'ACC')
            measure = ['IMU_' channel(7:8)];
            signal = 'acc';
        elseif contains(channel, 'GYRO')
            measure = ['IMU_' channel(8:9)];
            signal = 'gyr';
        else
            measure = channel;
            signal = 'emg';
        end

        temp = data(:, i);

        % Remove the zeros found using the previous time column.
        temp(ind4) = [];

        % The EMG signals appear to go the full extent of their time columns but the IMU data stops short. Because there is different sampling between
        % the different signals
        if strcmp(measure, 'IMU')

            % First find the indexes where the difference in the signal is 0. Then find the last index of where the difference of these indexes is 1.
            % Find the last index before the difference of the values is 0.
            ind5 = find(diff(temp) == 0);
            % Make sure at least the very last value was found to be a repeated 0. This should help catch signals where there are actual repeated 0s.
            if ind5(end) + 1 == length(temp)
                ind6 = ind5(find(diff(ind5) ~= 1, 1, 'last') + 1);
            else
                ind6 = [];
            end
            % Remove the zeros that were padded for some unknown reason and given time values.
            temp(ind6:end) = [];

        end

        % Put the data into the structure. If it the measure or signal hasn't been created yet, created newly.
        if ~isfield(csv_Delsys, measure) || ~isfield(csv_Delsys.(measure), 'data') || ~isfield(csv_Delsys.(measure).data, signal)
            csv_Delsys.(measure).data.(signal) = temp;
        else
            % If it has been created append it. It is assumed the are the same size but this may not always be the case.
            csv_Delsys.(measure).data.(signal)(:, end + 1) = temp;
        end

        % Reset the end of data index.
        ind4 = [];
    end

end
        













