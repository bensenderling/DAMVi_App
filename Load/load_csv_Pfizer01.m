function csv_pfizer01 = load_csv_Pfizer01(file)
% [dataout] = load_csv_Pfizer1(file)
% inputs  - file, the path of the file to load.
% outputs - dataout, a structure with the data from the file.
% Remarks
% - This function loads data from a particular csv file generated by code
%   used in the WESENS project performed by Boston University and funded by
%   Pfizer and Eli Lilly.
% - The loaded data is formated in a structure to be used within the BAR 
%   App.
% - The particular file this function loads is produced by Python code that
%   is run on IMU data from APDM Opal sensors.
% Future Work
% - These files contain information related to data quality. Mostly it
%   calls out where individual data points are beyond two standard
%   deviations from the mean. This may not be useful if there are more than
%   several data points, as the odds of valid data points exceeding this
%   threshold will be high.
% Aug 2022 - Created by Ben Senderling, bsender@bu.edu
%
% Copyright 2020 Movement and Applied Imaging Lab, Department of Physical
% Therapy and Athletic Training, Sargent College, Boston University
%
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
%
% 1. Redistributions of source code must retain the above copyright notice,
%    this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright 
%    notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its 
%    contributors may be used to endorse or promote products derived from 
%    this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS 
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%% Begin Code

fid = fopen(file);

% Read in first line that contains the original file the data was produced
% from.
line = fgetl(fid);
line = textscan(line,'%s','Delimiter',',');
csv_pfizer01.meta.(regexprep(line{1}{1},' ','_')) = line{1}{2};

% Read in the text from the analysis log.
line = fgetl(fid);
line = textscan(line,'%s','Delimiter',',');
if numel(line) == 1
    line{1}{2} = [];
end
csv_pfizer01.meta.(regexprep(line{1}{1},' ','_')) = line{1}{2};

% Read in the test from the quality control line.
line = fgetl(fid);
line = textscan(line,'%s','Delimiter',',');
if numel(line) == 1
    line{1}{2} = [];
end
csv_pfizer01.meta.(regexprep(line{1}{1},' ','_')) = line{1}{2};

% The next line is blank.
line = fgetl(fid);

% Load the column headers.
line = fgetl(fid);
line = textscan(line,'%s','Delimiter',',');
% The first header is empty.
line{1}(1) = [];
headers = regexprep(line{1}, {' - ';' '}, '_');
headers = regexprep(headers, '+', '_and_');

% The rows with the column means and standard deviations is not used. These
% can be calculated later. There is not an elegant way within the framework
% of the app to include these.
line = fgetl(fid);
line = fgetl(fid);

% Read the first line of the data to give the while loop an initial
% condition.
line = fgetl(fid);
% When the end of the file is reached line will equal -1.
while line ~= -1
    data = textscan(line,'%s','Delimiter',',');
    % The length of headers are used to iterate through since that part of
    % the file structure will be more consistent.
    for i = 1:length(headers)
        % If the last column is empty there may not be a comma delimited
        % element.
        if i + 1 > length(data{1})
            dat = NaN;
        else
            dat = str2double(data{1}{i + 1});
        end
        % Assign the data dynamically using the headers.
        csv_pfizer01.(headers{i}).data.x(str2double(data{1}{1}), 1) = dat;
    end
    % Read the next line for the while loop.
    line = fgetl(fid);
end

% This data contains a lot of NaNs so they are removed here instead of 
% relying on later code to handle them.
for i = 1:length(headers)
    csv_pfizer01.(headers{i}).data.x(isnan(csv_pfizer01.(headers{i}).data.x)) = [];
end


end