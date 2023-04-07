function csv_BAR = load_csv_DAMVi(file)
% xlsx_BAR = load_csv_BAR(file)
% inputs  - file, the csv file to load.
% outputs - csv_BAR, the BAR App data structure recreated from the csv file.
% Remarks
% - This load function was a solution to an issue where large amounts of data needed to be loaded into the BAR App and slowed it down, but results 
%   created separately from those data could also be loaded in. This function loads in those results so the large amount of raw data does not need to 
%   be loaded in.
% Future Work
% - This function does not distinguish between file level group information and object level group information. The load function in the BAR App may 
%   need to be modified first before the change could be made here.
% Nov 2022 - Created by Ben Senderling, bsender@bu.edu
% Jan 2023 - Modified by Ben Senderling, bsender@bu.edu
%          - Changed the use of 'measure' to 'object'. Added code to separate file and object groups. Added to code to fix issue with multiple
%            dimensions and numbers not importing.

% The data can be read as a table with the variable names.
data = readtable(file, 'VariableNamingRule', 'preserve');

% Get the field names of the table to use as structure field names.
fields = fieldnames(data);
% Remove the additional fields for the table properties.
fields(strcmp(fields, 'Properties') | strcmp(fields, 'Row') | strcmp(fields, 'Variables')) = [];

% Find the indexes of the group headers.
indGroup = find(contains(fields, 'group'));
indGroupFile = indGroup(indGroup < find(contains(fields, 'object')));
% Find the indexes of the signals by removing the options.
indSignal = find(~contains(fields, 'group') & ~contains(fields, 'file') & ~contains(fields, 'object') & ~contains(fields, 'dimension') & ~contains(fields, 'number'));
% The group columns that occur after the object but before the signals are assigned to the object level.
indGroupObject = indGroup(indGroup > find(contains(fields, 'object')) & indGroup < min(indSignal));

% Initialize the structure.
csv_BAR = struct;
for i = 1:height(data)
    % All the group information is loaded in at one time. CSV files from
    % Excel may convert number strings to numbers. Those need to be
    % converted back to strings so the groups can be concatenated in the
    % Merge and Groupings Modules.
    if ~isempty(indGroupFile)
        csv_BAR.raw.(data.file{i}).groups = cellfun(@num2str, table2cell(data(i, indGroupFile))', 'UniformOutput', false);
    else
        csv_BAR.raw.(data.file{i}).groups = data.file(i);
    end
    if ~isempty(indGroupObject)
        csv_BAR.raw.(data.file{i}).(data.object{i}).groups = cellfun(@num2str, table2cell(data(i, indGroupObject))', 'UniformOutput', false);
    end
    % Iterate through the signal indexes and pull them all in.
    for j = 1:length(indSignal)

        if isnan(data.(fields{indSignal(j)})(i))
            continue
        end
        % This if statement allows multiple values from the same object to
        % be re-imported. This is the opposite of the export means option
        % in the export tab.
        if isfield(csv_BAR.raw.(data.file{i}), data.object{i}) && isfield(csv_BAR.raw.(data.file{i}).(data.object{i}), 'data') && isfield(csv_BAR.raw.(data.file{i}).(data.object{i}).data, fields{indSignal(j)})
            % Check if there is a dimension column. If there is use the value, otherwise set it to 1.
            if any(strcmp(fields, 'dimension'))
                d = data.dimension(i);
            else
                d = 1;
            end
            % Check if there is a number column. If there is use the value, otherwise set it to 1.
            if any(strcmp(fields, 'number'))
                n = data.number(i);
            else
                n = 1;
%                 n = length(csv_BAR.raw.(data.file{i}).(data.object{i}).data.(fields{indSignal(j)})) + 1;
            end
            % Save the data into the structure using all the fields from the csv file to reconstruct the DAMVi data structure.
            csv_BAR.raw.(data.file{i}).(data.object{i}).data.(fields{indSignal(j)})(n, d) = data.(fields{indSignal(j)})(i);
        else
            % Check if there is a dimension column. If there is use the value, otherwise set it to 1.
            if isfield(data, 'dimension')
                d = data.dimension(i);
            else
                d = 1;
            end
            % Check if there is a number column. If there is use the value, otherwise set it to 1.
            if isfield(data, 'number')
                n = data.number(i);
            else
                n = 1;
            end
            % Save the data into the structure using all the fields from the csv file to reconstruct the DAMVi data structure.
            csv_BAR.raw.(data.file{i}).(data.object{i}).data.(fields{indSignal(j)})(n, d) = data.(fields{indSignal(j)})(i);
        end
    end

    if sum(~contains(fieldnames(csv_BAR.raw.(data.file{i}).(data.object{i})), 'groups')) == 0
        csv_BAR.raw.(data.file{i}) = rmfield(csv_BAR.raw.(data.file{i}), data.object{i});
    end
end

end
