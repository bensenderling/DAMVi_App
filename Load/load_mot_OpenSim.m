function mot_OpenSim = load_mot_OpenSim(file)
% mot_OpenSim = load_mot_OpenSim(file)
% inputs  - file, file path and name of an OpenSim mot file. This is a text file with a mot-extension.
% outputs - mot_OpenSim, structure containing data from the mot-file.
% Remarks
% - This function takes a text file with a mot file extension and creates a structure. The headers are used to name the fields in the structure. The 
%   time column is imported the same as the other data and is also used to calculate a sampling frequency. It is assumed the sampling was constant.
% Future Work
% - None.
% Apr 2023 - Created by Ben Senderling, bsender@bu.edu

% Open the file.
fid = fopen(file);

% The first line is the type of data from OpenSim.
data{1, :} = fgetl(fid);
obj = data{1};

% Save the version number in meta data.
data{2, :} = fgetl(fid);
version = split(data{2}, '=');
if strcmp(version{1}, 'version')
    mot_OpenSim.meta.(version{1}) = version{2};
end

% Save the number of rows.
data{3, :} = fgetl(fid);
nRows = split(data{3}, '=');
if strcmp(nRows{1}, 'nRows')
    N = str2double(nRows{2});
end

% Save the number of columns.
data{4, :} = fgetl(fid);
nCols = split(data{4}, '=');
if strcmp(nCols{1}, 'nColumns')
    M = str2double(nCols{2});
end

% Read the remaining lines above the headers.
indFile = 5;
data{indFile, :} = fgetl(fid);
while ~contains(data{indFile, :}, 'endheader')
    indFile = indFile + 1;
    data{indFile, :} = fgetl(fid);
end

% Read the headers.
headers = fgetl(fid);
headers = textscan(headers, '%s', 'delimiter', '\t');

% Nothing more is needed to be read line-by-line so close the file.
fclose(fid);

% Read in the numeric data.
num = readmatrix(file, 'Delimiter', '\t', 'NumHeaderLines', indFile + 1, 'FileType', 'text');

% Iterate through the columns and save the data to the structure.
for i = 1:M
    mot_OpenSim.(obj).data.(headers{1}{i}) = num(:, i);
    if strcmp(headers{1}{i}, 'time')
        mot_OpenSim.(obj).freq = 1/mean(diff(num(:, i)));
    end
end

end
