function csv_pfizer02 = load_csv_Pfizer02(file)
% [dataout] = load_csv_Pfizer02(file)
% inputs  - file, the path of the file to load.
% outputs - dataout, a structure with the data from the file.
% Remarks
% - This function loads data from a particular csv file generated by code
%   used in the WESENS project performed by Boston University and funded by
%   Pfizer and Eli Lilly. These files do not have a 'QC' or quality control
%   section. The meta data is short, four lines, with the fourth line
%   comman delimited with colons to specify parameters. A number of the
%   column headers have 'PARAM' or 'BOUTPARAM' in the name.
% - The loaded data is formated in a structure to be used within the BAR 
%   App.
% - The particular file this function loads is produced by Pfizer by 
%   processing IMU data from APDM Opal  and Axivity Ax6 sensors.
% Future Work
% - This load file may be confused with Pfizer01. The distincion should be
%   made clearer.
% Oct 2022 - Created by Ben Senderling, bsender@bu.edu
%
%% Begin Code

fid = fopen(file);

% Read in first line that reads the analysis toolkit used to process the 
% data.
line = fgetl(fid);
csv_pfizer02.meta.toolkit = line;

% Read in the version of the toolkit.
line = fgetl(fid);
line = textscan(line,'%s','Delimiter',',');
csv_pfizer02.meta.version = line{1}{2};

% Read in the date the file was processed.
line = fgetl(fid);
line = textscan(line,'%s','Delimiter',',');
csv_pfizer02.meta.date_processed = line{1}{2};

% Read in the other meta data.
line = fgetl(fid);
line = textscan(line,'%s','Delimiter',',');
for i = 1:length(line{1})
    ind1 = strfind(line{1}{i}, ':');
    csv_pfizer02.meta.(line{1}{i}(1:ind1 - 1)) = line{1}{i}(ind1 + 2:end);
end

% The next line is blank.
line = fgetl(fid);

% Load the column headers and clear characters that cannot be used in
% structure fields.
line = fgetl(fid);
line = textscan(line,'%s','Delimiter',',');
headers = regexprep(line{1},{' - ';' ';':';'-'},'_');

% Read the first line of the data to give the while loop an initial
% condition.
line = fgetl(fid);
ind_line = 1;
% When the end of the file is reached line will equal -1.
while line ~= -1
    data = textscan(line,'%s','Delimiter',',');
    % The length of headers are used to iterate through since that part of
    % the file structure will be more consistent.
    for i = 1:length(headers)
        % Assign the data dynamically using the headers.
        if i > length(data{1})
            csv_pfizer02.(headers{i}).data.x(ind_line, 1) = NaN;
        else
            if isnumeric(data{1}{i})
                csv_pfizer02.(headers{i}).data.x(ind_line, 1) = data{1}{i};
            else
                csv_pfizer02.(headers{i}).data.x(ind_line, 1) = str2double(data{1}{i});
            end
        end
    end
    ind_line = ind_line + 1;
    % Read the next line for the while loop.
    line = fgetl(fid);
end

fclose(fid);

end