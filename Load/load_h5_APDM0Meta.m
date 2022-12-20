function h5_APDM0 = load_h5_APDM0Meta(file)
% h5_APDM1 = load_h5_APDM0Meta(file)
% inputs  - file, directory and file name to import
% outputs - dataout, structure containing data from a h5 file from APDM.
% Remarks
% - This code is written to load only the meta data from h5 files. This particular code was written so the file path from the meta file could be used 
%   without loading the entire data set.
% - The file paths in the meta file are particular to the file location the h5 file was created in. If the file has been moved the path stored within
%   the h5 file will be incorrect.
% Future Work
% - These files can be quote large and importing them into MATLAB all at once can consume a lot of RAM. There could be an elegant way to load only 
%   what data is needed.
% Nov 2022 - Created by Ben Senderling
%% Begin Code

% Only the meta data is pulled from the file.
h5_APDM0.meta = h5info(file);


