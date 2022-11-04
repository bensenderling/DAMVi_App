function mat_QTM = load_mat_QTM(file)
% mat_QTM = load_mat_QTM(file)
% inputs  - file, directory and file name to import
% outputs - dataout, structure containing analog data exported from 
%                    Qualisys QTM.
% Remarks
% - This code is written to load data exported analog data from Qualisys 
%   QTM. The output format is specific for the BAR App.
% - QTM exports more than analog data when using the analog data-mat
%   export. This code was developed with a system that recorded force plate
%   signals through an analog-to-digital converter and electromygrophy data
%   recorded digitally through a Delsys SDK. For other system there may be
%   signals similar to the Delsys that are also recorded.
% Future Work
% - Analog signals tend to be sampled very highly and have multiple
%   components. It is possible these data structures could become quite
%   large and slow processing. There could be an elegant way to load
%   only what data is needed.
% Nov 2022 - Created by Ben Senderling
%
% Copyright 2022 Movement and Applied Imaging Lab, Department of Physical
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
% Only a simpler load function is needed because the data is already saved
% as a mat-file.
data = load(file);

% The first level of the mat file is named after the file, which is not
% strictly known.
obj = fieldnames(data);

% Pull various data from the mat file and save as meta data.
dat = fieldnames(data.(obj{1}));
for i = 1:length(dat)
    % Avoid pulling the analog data saved at the same level.
    if ~strcmp(dat{i}, 'Analog')
        mat_QTM.meta.(dat{i}) = data.(obj{1}).(dat{i});
    end
end

% Pull all the analog data.
for i = 1:length(data.(obj{1}).Analog)
    name = data.(obj{1}).Analog(i).BoardName;
    name = regexprep(name, {'-', ' '}, {''});
    % The file generally has multiple fields related to sampling. (number
    % of camera samples, sample multiplier per camera frame, total samples,
    % and the sampling frequency) Only the sampling frequency is needed.
    mat_QTM.(name).freq = data.(obj{1}).Analog(i).Frequency;
    % The labels used in QTM are used to name the signals.
    for j = 1:length(data.(obj{1}).Analog(i).Labels)
        mat_QTM.(name).data.(data.(obj{1}).Analog(i).Labels{j}) = data.(obj{1}).Analog(i).Data(j,:)';
    end
end
