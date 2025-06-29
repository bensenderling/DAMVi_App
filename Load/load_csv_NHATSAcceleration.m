function csv_NHATSAcceleration = load_csv_NHATSAcceleration(file)
% csv_NHATSAcceleration = load_csv_NHATSAcceleration(file)
% inputs  - file, the csv file to load.
% outputs - csv_NHATSAcceleration, the BAR App data structure with the 
%                                  accelerations values in long format and 
%                                  concatenated.
% Remarks
% - This load function is specific to the acceleration files from the NHATS
%   database of Medicare recipients. It contains epoch values in minutes 
%   for the acceleration in separate columns for each minute, and separate
%   rows for each day. Within each day they are converted to a long format.
%   And they are concatenated in order for each series of days.
% - This is data is different from others because all the participants are 
%   stored in the same file. They are stored at the object level.
% Future Work
% - None.
% Jun 2025 - Created by Ben Senderling, bms322@drexel.edu

% The data can be read as a table with the variable names.
data = readtable(file, 'VariableNamingRule', 'preserve');

% Initialize the structure.
csv_NHATSAcceleration = struct;

% The Test files contain the participant ID, birthdate, and gender. These 
% do not need to be propogated through the data processing.
if contains(file, '-Info')
    return
end

% Get the field names of the table to use as structure field names.
fields = fieldnames(data);
% Remove the additional fields for the table properties.
fields(strcmp(fields, 'Properties') | strcmp(fields, 'Row') | strcmp(fields, 'Variables')) = [];

% Get the signal names that are not for individual minutes of activity.
sigNames = fields(~contains(fields, 'mean'));

% Get the signal names for the individual minutes of activity.
accelNames = fields(contains(fields, 'mean'));

% The same object name is used for all the sample persons.
%object = ['Round_' sigNames{2}(3:strfind(sigNames{2}, 'dday') - 1)];

N = size(data, 1);
M = numel(unique(data.spid));

activName = [sigNames{2}(1:strfind(sigNames{2}, 'dday') - 1)];

% Initialize the cell arrays to speed up the code.
for i = 1:N
    if strcmp(data.([activName 'dvalid']){i}, '1 Yes')
        object = ['s' num2str(data.spid(i))];
        csv_NHATSAcceleration.(object).data.spid = [];
        csv_NHATSAcceleration.(object).data.(data.([activName 'dwday']){i}(3:end)) = [];
        % Initialize a cell array for the concatenated epochs.
        csv_NHATSAcceleration.(object).data.All = [];
    end
end

% Iterate through all the sample persons.
for i = 1:N

    if strcmp(data.([activName 'dvalid']){i}, '1 Yes')

        object = ['s' num2str(data.spid(i))];
    
        csv_NHATSAcceleration.(object).data.spid = data.spid(i);
        % Initialize a cell array for the concatenated epochs.
        csv_NHATSAcceleration.(object).data.(data.([activName 'dwday']){i}(3:end)) = data{i, accelNames}';
        
    end
end

spids = unique(data.spid);

for i = 1:M

    object = ['s' num2str(spids(i))];

    ind = find(data.spid == spids(i) & contains(data.([activName 'dvalid']), '1 Yes'));
    dday = data.([activName 'dday'])(ind);
    [~,ind_dday] = sort(dday);
    accelAll = data{ind(ind_dday), accelNames}';
    accelAll = accelAll(1:end)';
    csv_NHATSAcceleration.(object).data.All = accelAll;

    order = data{ind(ind_dday), [activName 'dwday']};
    for j = 1:length(order)
        order{j} = order{j}(3:4);
    end
    order = join(order, '-');
    csv_NHATSAcceleration.(object).data.Order = order;
end

end
