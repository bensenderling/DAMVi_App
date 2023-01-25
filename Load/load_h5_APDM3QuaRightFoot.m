function h5_APDM3 = load_h5_APDM3QuaRightFoot(file)
% h5_APDM1 = load_h5_APDM3QuaRightFoot(file)
% inputs  - file, directory and file name to import
% outputs - dataout, structure containing data from a h5 file from APDM.
% Remarks
% - This code is written to load processed IMU data recorded by APDM Opal sensors. It is a modification of load_h5_APDM1 that loads only the right 
%   foot sensor data. This was done to save time when loading large data sets.
% - The data this loads are the quaternions of the sensor.
% Future Work
% - These files can be quote large and importing them into MATLAB all at once can consume a lot of RAM. There could be an elegant way to load only 
%   what data is needed.
% - Potentially APDM1-3 could be combined. APDM2 was intended to load everything from a h5 file regardless of contents.
% Nov 2022 - Created by Ben Senderling

dbstop if error

% The info fields for the h5 file will be read as meta data.
h5_APDM3.meta = h5info(file);

% The raw data seems to be located in specific groups.
for i = 1:length({h5_APDM3.meta.Groups(1).Groups.Name})
    % Get the name of the group to use in the BAR App data structure.
    name = h5readatt(file,[h5_APDM3.meta.Groups(2).Groups(i).Name '/Configuration'], 'Label 0');
    % Certain characters need to be removed before it can be used as a
    % field neme.
    name = regexprep(name, {' ', char(0)}, {'_', ''});
    % Only the lumbar sensor is used.
    if strcmp(name, 'Right_Foot')
        % Get the time variable to be used to calculate the sampling
        % frequency.
        time = double(h5read(file,[h5_APDM3.meta.Groups(2).Groups(i).Name '/Time']));
        h5_APDM3.(name).freq = 1/mean(diff(time - time(1))/1e6);
        % Only the acceleration data is pulled to conserve file size.
        h5_APDM3.(name).data.qua = h5read(file, [h5_APDM3.meta.Groups(1).Groups(i).Name '/Orientation'])';
    end
end




