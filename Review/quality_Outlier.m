function qualityTable = quality_Outlier(qualityTable)
% qualityTable = quality_Outlier(qualityTable)
% inputs  - qualityTable, table from review_QC.mlapp.
% outputs - qualityTable, the same input table but with additional outlier information.
% Remarks
% - This method allows the user to select an outlier method. That selected method is then run on the data. In the case multiple measures/signals were chossen
%   in the QC module the outlier detection will be run on each measure/signal separately.
% - For each outlier the method adds notes with details on the outliermethod that was used.
% Future Work
% - None.
% May 2022 - Created by Ben Senderling, bsender@bu.edu

% Create the options for the outlier methods.
options = {'median', 'mean', 'quartiles', 'grubbs', 'gesd'};
% Open a list dialog for the user to select a single method.
method = listdlg('ListString', options,...
    'PromptString', 'Please select a method to detect outliers.',...
    'SelectionMode', 'single',...
    'Name', 'Outlier Detection');

% If cancel was selected return nothing.
if isempty(method)
    return
end

% Get the string name of the outlier method.
methodString = options{method};

% If the table fields include 'Measure' than it is an analysis or results data type.
if any(contains(fieldnames(qualityTable), 'Measure'))
    % Get the unique measure names.
    types = unique(qualityTable.Measure);
% If the table fields include 'Signal' but not 'Measure' than it is a raw or pro data type.
elseif any(contains(fieldnames(qualityTable), 'Signal')) && ~any(contains(fieldnames(qualityTable), 'Measure'))
    % Get the unique signal names.
    types = unique(qualityTable.Signal);
end

% Iterate through the different signal or measure names.
for ind_types = 1:length(types)
    % For analysis and results data types.
    if any(contains(fieldnames(qualityTable), 'Measure'))
        % Get booleans for which measures in the table match the current iteration.
        b = strcmp(qualityTable.Measure, types{ind_types});
    % For raw and processed data types.
    elseif any(contains(fieldnames(qualityTable), 'Measure')) && any(contains(fieldnames(qualityTable), 'Signal'))
        % Get booleans for which signals in the table match the current iteration.
        b = strcmp(qualityTable.Signal, types{ind_types});
    end
    % Find the indexes of the signals/measures. This fixes an issue where cell2mat removes empty values.
    ind = find(~cellfun(@isempty, {qualityTable.Value{b}}'));
    % Run the outlier detection.
    faults = isoutlier(cell2mat(qualityTable.Value(b)), methodString);
    % Put the booleans into the table at the correct indexes.
    qualityTable.Fault(ind) = faults;
end

% Add a string with the outlier method to the quality table.
qualityTable.Notes(find(qualityTable.Fault)) = repmat({[methodString ' outlier']}, sum(qualityTable.Fault), 1);

