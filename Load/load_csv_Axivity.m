function csv_Axivity = load_csv_Axivity(file)
% csv_Axivity = load_csv_Axivity(file)
% inputs  - file, the csv file to load.
% outputs - csv_Axivity, the activity data in a DAMVi data structure.
% Remarks
% - This load function reads in data from most of the different Axivity 
%   CSV files. 
% Future Work
% - This function is just starting to be used. It is likely errors and 
%   issues will arise as it is used more.
% Feb 2025 - Created by Ben Senderling, bms322@drexel.edu

% The data can be read as a table with the variable names.
data = readtable(file, 'VariableNamingRule', 'preserve');

% Initialize the structure.
csv_Axivity = struct;

% The Test files contain the participant ID, birthdate, and gender. These 
% do not need to be propogated through the data processing.
if contains(file, '-Info')
    return
end

% Get the field names of the table to use as structure field names.
fields = fieldnames(data);
% Remove the additional fields for the table properties.
fields(strcmp(fields, 'Properties') | strcmp(fields, 'Row') | strcmp(fields, 'Variables')) = [];

% Create a fixed object name.
object = 'IMU';

if isdatetime(data.Time)
    csv_Axivity.(object).freq = 1/mean(diff(seconds(data.Time - data.Time(1))));
end

for i = 1:length(fields)

    % Store the signal name separately so it can be modified according to
    % the left/right foot and X-Y-Z dimensions.
    signal = fields{i};

    if any(fields{i} == 'X')
        dim = 1;
        signal = regexprep(signal, '-X', '');
    elseif any(fields{i} == 'Y')
        dim = 2;
        signal = regexprep(signal, '-Y', '');
    elseif any(fields{i} == 'Z')
        dim = 3;
        signal = regexprep(signal, '-Z', '');
    else
        dim = 1;
    end

    signal = regexprep(signal, {' ', '[.]', '(', ')', '/'}, {'_'});

    if dim > 1 && ~(isfield(csv_Axivity, object) && isfield(csv_Axivity.(object), data) && isfield(csv_Axivity.(object).data, signal))
        csv_Axivity.(object).data.(signal) = zeros(size(data, 1), dim);
    end
    
    csv_Axivity.(object).data.(signal)(:, dim) = data.(fields{i});

end

end
