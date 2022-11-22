function csv_BAR = load_csv_BAR(file)
% xlsx_BAR = load_csv_BAR(file)
% inputs  - file, the csv file to load.
% outputs - csv_BAR, the BAR App data structure recreated from the csv 
%                    file.
% Remarks
% - This load function was a solution to an issue where large amounts of
%   data needed to be loaded into the BAR App and slowed it down, but
%   results created separately from those data could also be loaded in.
%   This function loads in those results so the large amount of raw data
%   does not need to be loaded in.
% Future Work
% - This function does not distinguish between file level group information
%   and object level group information. The load function in the BAR App
%   may need to be modified first before the change could be made here.
% Nov 2022 - Created by Ben Senderling, bsender@bu.edu
%% Begin Code

dbstop if error

% The data can be read as a table with the variable names.
data = readtable(file, 'VariableNamingRule', 'preserve');

% Get the field names of the table to use as structure field names.
fields = fieldnames(data);
% Remove the additional fields for the table properties.
fields(strcmp(fields, 'Properties') | strcmp(fields, 'Row') | strcmp(fields, 'Variables')) = [];

% Find the indexes of the group headers.
indGroup = find(contains(fields, 'group'));
% Find the indexes of the signals by removing the options.
indSignal = find(~contains(fields, 'group') & ~contains(fields, 'file') & ~contains(fields, 'measures'));

% Initialize the structure.
csv_BAR = struct;
for i = 1:height(data)
    % All the group information is loaded in at one time. CSV files from
    % Excel may convert number strings to numbers. Those need to be
    % converted back to strings so the groups can be concatenated in the
    % Merge and Groupings Modules.
    csv_BAR.raw.(data.file{i}).groups = cellfun(@num2str, table2cell(data(i, indGroup))', 'UniformOutput', false);
    % Iterate through the signal indexes and pull them all in.
    for j = 1:length(indSignal)
        csv_BAR.raw.(data.file{i}).(data.measures{i}).(fields{indSignal(j)}) = data.(fields{indSignal(j)})(i);
    end
end

























end
