function csv_Actigraph = load_csv_Actigraph(file)
% [dataout] = load_csv_Actigraph(file)
% inputs  - file, path of the file to load.
% outputs - csv_Actigraph, structure with the data from the file.
% Remarks
% - This function aims to load data from a number of Actigraph csv exports. These include the spreadsheets called: DailyDetailed, DailyTotals, 
%   HourlyDetailed, HourlyTotals, SedentaryAnalysis, SleepScores and WearTimeValidation. It will not load the Variables spreadsheet.
% - The code has been adapted to pull meta data from sleep files and raw data files. The table read still reads in the data below the meta data correctly. Now it will
%   look for a particular header to read in the meta data.
% - ActiLife will display data files in slightly different formats depending on how the software it configured. Some CSV raw data exports will contain
%   headers and others will not. This code should account for those. The sleep data exports will also contain times that are recognized by MATLAB as
%   datetimes or not and will be read as cells. It is not know why this is but some code has been added to detect and fix this.
% Future Work
% - There is nothing put in for the object name. This could be replaced with the file name stored in the first column of the Actigraph file. The other
%   column headers would then be the 'x' field under data.
% - If the code for pulling in meta data from sleep files works it could be expanded to other files types, to also pull in their meta data.
% Aug 2022 - Created by Ben Senderling, bsender@bu.edu
% Oct 2023 - Modified by Ben Senderling, bms322@drexel.edu
%          - Modified the data format so it aligns with more developed code
%            in DAMVi and export correctly.
%          - Added code to pull meta data from sleep files.
% Nov 2023 - Modified by Ben Senderling, bms322@drexel.edu
%          - Added code to load csv exports of raw data from ActiLife.
%          - Added code to correct for some sleep data files where the times are picked up by MATLAB as datetimes or cells.
%% Begin Code

% These will be removed from each field name.
illegalCharacters = {'!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '-', '=', '+', '[', ']', '{', '}', ';', ':', ',', '\.', '<', '>', '/', '?', ' '};

% The csv files can be read with readtable.
data = readtable(file);

% Pull the header names.
headers = data.Properties.VariableNames;

% Check if these is a sleep file that contains meta data.
if strcmp(headers{1}, 'SleepAlgorithm')
    % Open the file to read the meta data.
    fid = fopen(file, 'r');
    % Get the first line.
    line = fgetl(fid);
    % Read each line untill one is empty. That is the line before the real data.
    while ~isempty(line)
        % Find the index of the ':' to separate the field name from the value.
        ind = strfind(line, ':');
        % Remove any illegal characters from the field name.
        name = regexprep(line(1:ind(1) - 1), illegalCharacters, '_');
        % Save the field value to the data structure.
        csv_Actigraph.meta.(name) = line(ind(1) + 2:end);
        % Get the next line.
        line = fgetl(fid);
    end
elseif strcmp(headers{1}, 'Var1') || strcmp(headers{1}, 'Axis1')
    % Open the file to read the meta data.
    fid = fopen(file, 'r');
    % Get the first line.
    line = fgetl(fid);

    delimeter = [15, 11, 11, 24, 14, 14, 24];
    for ind_delimeter = 1:length(delimeter)
        % Get the second line.
        line = fgetl(fid);
        % Remove any illegal characters from the field name.
        name = regexprep(line(1:delimeter(ind_delimeter) - 1), illegalCharacters, '_');
        % Save the field value to the data structure.
        csv_Actigraph.meta.(name) = line(delimeter(ind_delimeter) + 1:end);
    end
    
end

% Use the header names to create the fields in the structure.
for i = 1:length(headers)
    % Check if time data was recognized as cells instead of datetime.
    if contains(headers{i}, 'Time') && iscell(data.(headers{i}))
        % Convert them to datetime.
        csv_Actigraph.Actigraph.data.(headers{i}) = datetime(data.(headers{i}), 'InputFormat', 'HH:mm a', 'Format', 'PreserveInput');
    else
        csv_Actigraph.Actigraph.data.(headers{i}) = data.(headers{i});
    end

end
