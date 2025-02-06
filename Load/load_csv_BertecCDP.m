function csv_BertecCDP = load_csv_BertecCDP(file)
% xlsx_BAR = load_csv_BertecCDP(file)
% inputs  - file, the csv file to load.
% outputs - csv_BertecCDP, the BAR App data structure recreated from the 
%                          csv file.
% Remarks
% - This load function reads in data from most of the different Bertec CDP 
%   CSV files. The Info files are not loaded as the contian participant 
%   information without any additional useful information.
% - All of the Bertec CDP CSV files follow a standard CSV format and are 
%   not very long. This allows the same readtable function to be used for
%   all of them.
% Future Work
% - This function is just starting to be used. It is likely errors and 
%   issues will arise as it is used more.
% Feb 2025 - Created by Ben Senderling, bms322@drexel.edu

% The data can be read as a table with the variable names.
data = readtable(file, 'VariableNamingRule', 'preserve');

% Initialize the structure.
csv_BertecCDP = struct;

% The Test files contain the participant ID, birthdate, and gender. These 
% do not need to be propogated through the data processing.
if contains(file, '-Info')
    return
end

% Get the field names of the table to use as structure field names.
fields = fieldnames(data);
% Remove the additional fields for the table properties.
fields(strcmp(fields, 'Properties') | strcmp(fields, 'Row') | strcmp(fields, 'Variables')) = [];

for i = 1:length(fields)

    % Store the signal name separately so it can be modified according to
    % the left/right foot and X-Y-Z dimensions.
    signal = fields{i};

    if signal(end) == 'R'
        object = 'RightFoot';
        signal = signal(1:end - 1);
    elseif fields{i}(end) == 'L'
        object = 'LeftFoot';
        signal = signal(1:end - 1);
    else
        object = 'Body';
    end

    if any(fields{i} == 'X')
        dim = 1;
        signal = regexprep(signal, 'X', '');
    elseif any(fields{i} == 'Y')
        dim = 2;
        signal = regexprep(signal, 'Y', '');
    elseif any(fields{i} == 'Z')
        dim = 3;
        signal = regexprep(signal, 'Z', '');
    else
        dim = 1;
    end

    if ~isfield(csv_BertecCDP, object) && length(data.(fields{i})) > 1
        csv_BertecCDP.(object).freq = 2000; % The Bertec CDP samples all data at this rate.
    end

    if dim > 1 && ~(isfield(csv_BertecCDP, object) && isfield(csv_BertecCDP.(object), data) && isfield(csv_BertecCDP.(object).data, signal))
        csv_BertecCDP.(object).data.(signal) = zeros(size(data, 1), dim);
    end
    
    csv_BertecCDP.(object).data.(signal)(:, dim) = data.(fields{i});

end

end
