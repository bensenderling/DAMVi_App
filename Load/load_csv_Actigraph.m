function csv_Actigraph = load_csv_Actigraph(file)
% [dataout] = load_csv_Actigraph(file)
% inputs  - file, path of the file to load.
% outputs - csv_Actigraph, structure with the data from the file.
% Remarks
% - This function aims to load data from a number of Actigraph csv exports.
%   These include the spreadsheets called: DailyDetailed, DailyTotals,
%   HourlyDetailed, HourlyTotals, SedentaryAnalysis, SleepScores and
%   WearTimeValidation. It will not load the Variables spreadsheet.
% Future Work
% - There is nothing put in for the object name. This could be replaced
%   with the file name stored in the first column of the Actigraph file.
%   The other column headers would then be the 'x' field under data.
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

data = readtable(file);

headers = data.Properties.VariableNames;

for i = 1:length(headers)
    csv_Actigraph.(headers{i}).data.x = data.(headers{i});

end