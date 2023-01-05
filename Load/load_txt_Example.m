function txt_Example = load_txt_Example(file)
% txt_Example = load_txt_Example(file)
% inputs  - file, file path and name of a V3D text file
% outputs - txt_Example, structure containing file from V3D text file
% Remarks
% - This function loads an example file created for the BAR App. It is intended to be used to test the app and its various functionalities.
% Future Work
% - None.
% Jan 2023 - Created by Ben Senderling, bsender@bu.edu

% Open the file.
fid = fopen(file);

% Get the first five header lines. These will be used to name the different
% levels of the data structure.
data{1,:} = fgetl(fid);
data{2,:} = fgetl(fid);

% Nothing more is needed to be read line-by-line so close the file.
fclose(fid);

% Separate the lines of headers by finding the tab delimiters.
object = textscan(data{1,:},'%s','delimiter',',');
signal = textscan(data{2,:},'%s','delimiter',',');

% Make the data in the first cell the actual data.
object = object{1};
signal = signal{1};

% Read in the numeric data.
data = readmatrix(file, 'Delimiter', ',', 'NumHeaderLines', 2, 'TreatAsMissing', 'NaN');

% Iterate through the columns.
for i = 1:length(object)
    % Put the data into the BAR App data format.
    txt_Example.(object{i}).data.(signal{i}) = data(:, i);
    % Remove the NaNs so the data has different lengths.
    txt_Example.(object{i}).data.(signal{i})(isnan(txt_Example.(object{i}).data.(signal{i}))) = [];
    % Create a sampling frequency.
    txt_Example.(object{i}).freq = 1;
end









