function m4a_Microsoft = load_m4a_Microsoft(file)
% m4a_Microsoft = load_m4a_Microsoft(file)
% inputs  - file, directory and file name to import
% outputs - m4a_Microsoft, structure containing audio data from an m4a 
%                          file.
% Remarks
% - This code is written to load raw audio data from a m4a-file. It is
%   assumed the file contains only audio in a single time series and the
%   sampling frequency.
% Future Work
% - This code may become slow with large files. (length(y) >> 6,000,000
% Sep 2026 - Created by Ben Senderling, bensenderling@gmail.com
%% Begin Code

[m4a_Microsoft.audio.data.y, m4a_Microsoft.audio.freq] = audioread(file);



