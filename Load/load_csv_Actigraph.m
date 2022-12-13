function csv_Actigraph = load_csv_Actigraph(file)
% [dataout] = load_csv_Actigraph(file)
% inputs  - file, path of the file to load.
% outputs - csv_Actigraph, structure with the data from the file.
% Remarks
% - This function aims to load data from a number of Actigraph csv exports.
%   These include the spreadsheets called: DailyDetailed, DailyTotals,
%   HourlyDetailed, HourlyTotals, SedentaryAnalysis, SleepScores and
%   WearTimeValidation. It will not load the Variables spreadsheet.
% Future Work
% - There is nothing put in for the object name. This could be replaced
%   with the file name stored in the first column of the Actigraph file.
%   The other column headers would then be the 'x' field under data.
% Aug 2022 - Created by Ben Senderling, bsender@bu.edu
%% Begin Code

% The csv files can be read with readtable.
data = readtable(file);

% Pull the header names.
headers = data.Properties.VariableNames;

% Use the header names to create the fields in the structure.
for i = 1:length(headers)
    csv_Actigraph.(headers{i}).data.x = data.(headers{i});

end
