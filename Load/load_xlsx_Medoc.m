function xlsx_Medoc = load_xlsx_Medoc(file)
% [dataout] = load_xlsx_Medoc(file)
% inputs  - file, this is the file path to the file to load.
% outputs - dataout, formated data for the BAR app.
% Remarks
% - This function is to load data exported from Medoc software. This
%   software was used with an algometer for pressure-pain sensitivity
%   testing.
% Future Work
% - Other devices that could be used with Medoc have not been incorporated
%   into this code.
% Oct 2022 - Created by Ben Senderling, bsender@bu.edu
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


dbstop if error

% Read in the Description tab with information on the test.
meta = readcell(file, 'Sheet', 'Description');

% Iterate through all the fields and save the values in the structure.
for i = 1:size(meta, 1)
    name = meta{i,1};
    % All spaces in the field names need to be removed to be valid.
    name = regexprep(name, ' ', '_');
    xlsx_Medoc.meta.(name) = meta{i, 2};
end

% Pull the name of all the sheets in the xlsx file and remove the
% Description sheet.
sheets = sheetnames(file);
sheets(strcmp(sheets, 'Description')) = [];

% Iterate through the sheets and pull out the data.
for i = 1:length(sheets)

    % The data can be read as a table with the variable names.
    data = readtable(file, 'Sheet', sheets{i});
    % Make the sheet names valid structure field names.
    name = regexprep(sheets{i}, ' ', '_');
    % Get the field names of the table to use as structure field names.
    fields = fieldnames(data);
    % Remove the additional fields for the table properties.
    fields(strcmp(fields, 'Properties') | strcmp(fields, 'Row') | strcmp(fields, 'Variables')) = [];
    for j = 1:length(fields)
        % The event data will be read as a cell and text. It is converted
        % to booleans.
        if strcmp(fields{j}, 'Event')
            x = data.(fields{j});
            if ~iscell(x) && any(isnan(x))
                x = zeros(length(x), 1);
            else
                x = ~cellfun(@isempty,x);
            end
            xlsx_Medoc.(name).data.(fields{j}) = x;
        else
            xlsx_Medoc.(name).data.(fields{j}) = data.(fields{j});
        end
    end

end

























end
