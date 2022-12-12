function h5_APDM1 = load_h5_APDM0Meta(file)
% h5_APDM1 = load_h5_APDM1(file)
% inputs  - file, directory and file name to import
% outputs - dataout, structure containing data from a h5 file from APDM.
% Remarks
% - This code is written to load only the meta data from h5 files. This
%   particular code was written so the file path from the meta file could
%   be used without loading the entire data set.
% Future Work
% - These files can be quote large and importing them into MATLAB all at
%   once can consume a lot of RAM. There could be an elegant way to load
%   only what data is needed.
% Nov 2022 - Created by Ben Senderling
%
%% Begin Code
dbstop if error

h5_APDM1.meta = h5info(file);


