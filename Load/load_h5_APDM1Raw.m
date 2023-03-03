function h5_APDM1 = load_h5_APDM1Raw(file)
% h5_APDM1 = load_h5_APDM1Raw(file)
% inputs  - file, directory and file name to import
% outputs - dataout, structure containing data from a h5 file from APDM.
% Remarks
% - This code is written to load raw IMU data recorded by APDM Opal
%   sensors.
% Future Work
% - These files can be quote large and importing them into MATLAB all at
%   once can consume a lot of RAM. There could be an elegant way to load
%   only what data is needed.
% Nov 2022 - Created by Ben Senderling
%% Begin Code

% Get the h5 file information and store it as meta data.
h5_APDM1.meta = h5info(file);

%%

% A particular group will be iterated through that contains the raw data.
for i = 1:length({h5_APDM1.meta.Groups(2).Groups.Name})
    % Get the name of the sensor label to use as a field name.
    name = h5readatt(file,[h5_APDM1.meta.Groups(2).Groups(i).Name '/Configuration'], 'Label 0');
    % Remove illegal characters from the label.
    name = regexprep(name, {' ', char(0)}, {'_', ''});
    % Get the time and calculate the sampling frequncy.
    time = double(h5read(file,[h5_APDM1.meta.Groups(2).Groups(i).Name '/Time']));
    h5_APDM1.(name).freq = 1/mean(diff(time - time(1))/1e6);
    % Pull the accelerometer, magnetometer and gyroscope data.
    h5_APDM1.(name).data.acc = h5read(file, [h5_APDM1.meta.Groups(2).Groups(i).Name '/Accelerometer'])';
    h5_APDM1.(name).data.mag = h5read(file, [h5_APDM1.meta.Groups(2).Groups(i).Name '/Magnetometer'])';
    h5_APDM1.(name).data.gyr = h5read(file, [h5_APDM1.meta.Groups(2).Groups(i).Name '/Gyroscope'])';
end

h5_APDM1 = rmfield(h5_APDM1, 'meta');


