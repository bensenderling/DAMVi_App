function txt_V3D = load_txt_V3D(file)
% [dataout] = load_txt_V3D(file)
% inputs  - file, file path and name of a V3D text file
% outputs - dataout, structure containing file from V3D text file
% Remarks
% - This function takes a text file from V3D and creates a structure. The
%   headers (data source, types, folders, components, signal names) are
%   used to name the fields in the structure. The frames are not imported.
% - If more than one subject's data is contained in the text file the data
%   for each subject will be stored within that subject's field.
% - This code is written to work with V3D files that have NaN exported for
%   frames with no data.
% - Visual3D does not make it easy to export the sampling frequency
%   cleanly. This code was written expecting the sampling frequency would
%   be exported along with the rest of the data. For the analog data it
%   should have the name ANALOG_RATE. For marker data it should have the
%   name MARKER_RATE. This does require that exports do not have both of
%   these variables. The analog and marker data should be exported
%   separately.
% Future Work
% - None.
% Mar 2022 - Created by Ben Senderling, bsender@bu.edu
% Nov 2022 - Modified by Ben Senderling, bsender@bu.edu
%          - Tweaked the format of the data to work better with other BAR
%            App data structures.
%          - Added modifications for long files names and group
%            information.

% Open the file.
fid = fopen(file);

% Get the first five header lines. These will be used to name the different
% levels of the data structure.
data{1,:} = fgetl(fid);
data{2,:} = fgetl(fid);
data{3,:} = fgetl(fid);
data{4,:} = fgetl(fid);
data{5,:} = fgetl(fid);

% Nothing more is needed to be read line-by-line so close the file.
fclose(fid);

% Separate the lines of headers by finding the tab delimiters.
sources = textscan(data{1,:},'%s','delimiter','\t');
measure = textscan(data{2,:},'%s','delimiter','\t');
type = textscan(data{3,:},'%s','delimiter','\t');
folder = textscan(data{4,:},'%s','delimiter','\t');
dimension = textscan(data{5,:},'%s','delimiter','\t');

% Make the data in the first cell the actual data and remove the first
% dummy value.
sources = sources{1};
sources(1) = [];
measure = measure{1};
measure(1) = [];
type = type{1};
type(1) = [];
folder = folder{1};
folder(1) = [];
dimension = dimension{1};
dimension(1) = [];

% Check if long file names are used and shorten them. The long names are
% retained to be split into group information later.
% sourcesTrim and sources are created separately because sources will be
% used to find group information for the BAR App.
if ~isempty(strfind(sources{1},'\')) 
    for i = 1:length(sources)
        % Long filename headers will have a '\'.
        ind = strfind(sources{i},'\');
        % Trim the headers using the last '\'.
        sourcesTrim{i, 1} = sources{i}(ind(end)+1:end);
    end
else
    % If there are no long file names the string used to find group
    % information will just be the file name.
    sourcesTrim = sources;
end

% Read in the numeric data.
data = readmatrix(file,'Delimiter','\t','NumHeaderLines',5);

% Initialize a variable to help track the longest data length.
nlast = inf;
% This variable will help make sure data of the same type is the same
% length.
lasttype = 'boom';
% Iterate through the columns of data, which is the same length as the
% sources.
for j = 1:length(sourcesTrim)

    % Standard statistics should not be calculated in Visual3D. This has
    % had a tendency to elongate field names past what MATLAB allows. They
    % are also simple to calculate in MATLAB instead of in the Global V3D
    % Workspace. Working with only the original values also enables higher
    % quality data review in the BAR App.
%     if contains(measure{j}, 'Count') || contains(measure{j}, 'Mean') || contains(measure{j}, 'StdDev') || contains(measure{j}, 'ANALOG_RATE')
%         continue
%     end
    
    % Create a separate temporary variable so the length can be adjusted.
    temp = data(:,j+1);
    
    % Find the last number to not be a NaN. This does mean that NaNs
    % located within the time series are retained.
    ind = find(~isnan(temp),1,'last');
    if isempty(ind)
        continue
    end
    % Remove all values after the last non-NaN.
    temp(ind+1:end) = [];
    
    % Data of certain types should have the same length. This helps make
    % sure columns of X-Y-Z components of data like kinetic or kinematic
    % time series have the same length.
    if ismember(type(j),{'LINK_MODEL_BASED' 'FORCE' 'COFP'})
        % If the current length is within 10 of the last columns length and
        % the types are the same.
        if abs(length(temp)-nlast)<10 && strcmp(lasttype,type(j))
            % Use the previous data length to pull the data.
            temp = data(1:nlast,j+1);
        end
        % Set the new length to the current temporary data.
        nlast = length(temp);
        % Change the last type to the currrent type.
        lasttype = type{j};
    end
    
    % This might not be used anymore.
    %     fieldname = [sourcesTrim{j}(1:end-4) '_' type{j} '_' measure{j} '_' dimension{j}];

    % Replace spaces in the sources string with underscores.
    sourcesTrim = strrep(sourcesTrim,' ','_');

    % This statement was added in to catch backup files created by QTM that
    % were then imported into Visual3D. The "Backup..." appended to the
    % filename is not a valid field name. It also is very long and if the
    % name is used later as a dynamic variable MATLAB will truncate it.
    if contains(sourcesTrim{j}, 'Backup')
        sourcesTrim{j}(strfind(sourcesTrim{j}, 'Backup') - 1:end - 4) = [];
    end

    % Replace spaces in the other strings with underscores.
    type = strrep(type,' ','_');
    measure = strrep(measure,' ','_');
    dimension = strrep(dimension,' ','_');
    % num = sum(strcmp(fieldname,fields))+1;

    % The sampling frequency is expected to be exported with the name
    % ANALOG_RATE or MARKER_RATE. This does require V3D export to not have
    % both. Only one freq variable should be present in the BAR App data
    % structure objects.
    if ~isempty(find(contains(sourcesTrim, sourcesTrim{j}) & contains(measure, 'ANALOG_RATE')))
        ind = find(contains(sourcesTrim, sourcesTrim{j}) & contains(measure, 'ANALOG_RATE'));
        freq = data(1, ind + 1);
    elseif ~isempty(find(contains(sourcesTrim, sourcesTrim{j}) & contains(measure, 'MARKER_RATE')))
        ind = find(contains(sourcesTrim, sourcesTrim{j}) & contains(measure, 'MARKER_RATE'));
        freq = data(1, ind + 1);
    else
        freq = [];
    end
    
    % This was previously used so components of the same signal could be
    % placed into the same array. This worked for forces and joint angles
    % but does not for METRICS. Now they are created as separate signals.
%     c = '1';
%     switch dimension{j}
%         case 'X'
%             c = '1';
%         case 'Y'
%             c = '2';
%         case 'Z'
%             c = '3';
%     end

    % These indexes and intersections were a solution for multiple sections
    % of the same signal being present in the same file. This could be if the same
    % signal was exported for multiple sequences of events that occur
    % across it's time span.
    ind = find(strcmp(sourcesTrim, sourcesTrim{j}));
    ind2 = find(strcmp(folder, folder{j}));
    ind3 = find(strcmp(measure, measure{j}));
    ind4 = find(strcmp(type, type{j}));
    ind5 = find(strcmp(dimension, dimension{j}));
    ind6 = intersect(ind, intersect(ind2, intersect(ind3, intersect(ind4, ind5))));
    % The final number of the same signal present in the file.
    n = numel(ind6);
    % If only one of a signal is present or if this is the first iteration
    % of it name it as is.
    if n == 1 || (n > 1 && j == ind6(1))
        % Save the data as it normally would be.
        txt_V3D.([sourcesTrim{j}(1:end-4) '_' type{j} '_' folder{j}]).data.([measure{j} '_' dimension{j}]) = temp;
        txt_V3D.([sourcesTrim{j}(1:end-4) '_' type{j} '_' folder{j}]).freq = freq;
        txt_V3D.([sourcesTrim{j}(1:end-4) '_' type{j} '_' folder{j}]).groups = findGroups(sources{j});
    else
        % Else append a number to the name to make it unique.
        txt_V3D.([sourcesTrim{j}(1:end-4) '_' type{j} '_' folder{j} '_' num2str(n)]).data.([measure{j} '_' dimension{j}]) = temp;
        txt_V3D.([sourcesTrim{j}(1:end-4) '_' type{j} '_' folder{j} '_' num2str(n)]).freq = freq;
        txt_V3D.([sourcesTrim{j}(1:end-4) '_' type{j} '_' folder{j} '_' num2str(n)]).groups = findGroups(sources{j});
    end
    
end

end

function dat = findGroups(dat)
% dat = findGroups(dat)
% inputs  - dat, the string from which to find groups.
% outputs - dat, the groups found from the string.
% Remarks
% - This method identifies group information from a string for the BAR App.
%   It looks for '\' as would be present in the file path and '_' as may be
%   put into a file name.
% Future Work
% - None.
% Mar 2022 - Created by Ben Senderling, bsender@bu.edu
% Nov 2022 - Modified by Ben Senderling, bsender@bu.edu
%          - Tweaked the format of the data to work better with other BAR
%            App data structures.
%          - Added modifications for long files names and group
%            information.

% If neither delimiter is present exit the code.
if ~contains(dat,'\') && ~contains(dat,'_')
    return
end

% The various folders in the files directory path will
% be turned into group information. This includes the
% drive letter.
dat = split(dat, '\');
i = 1;
% For each folder check if underscores were used as a
% delimter and use that to create groups.
while i <= length(dat)
    temp = split(dat{i}, '_');
    if length(temp) > 1
        % Extend the group array so the order is
        % preserved.
        dat = [dat(1:i-1); temp; dat(i+1:end)];
    end
    i = i + 1;
end
% Remove the file extension so it is not used as a
% group.
ind = strfind(dat{end}, '.');
dat{end}(ind(end):end) = [];

end