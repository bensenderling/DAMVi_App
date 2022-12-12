function h5_APDM1 = load_h5_APDM1Raw(file)
% h5_APDM1 = load_h5_APDM1(file)
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
dbstop if error

h5_APDM1.meta = h5info(file);

%%

for i = 1:length({h5_APDM1.meta.Groups(2).Groups.Name})
    name = h5readatt(file,[h5_APDM1.meta.Groups(2).Groups(i).Name '/Configuration'], 'Label 0');
    name = regexprep(name, {' ', char(0)}, {'_', ''});
    time = double(h5read(file,[h5_APDM1.meta.Groups(2).Groups(i).Name '/Time']));
    h5_APDM1.(name).freq = 1/mean(diff(time - time(1))/1e6);
    h5_APDM1.(name).data.acc = h5read(file, [h5_APDM1.meta.Groups(2).Groups(i).Name '/Accelerometer'])';
    h5_APDM1.(name).data.mag = h5read(file, [h5_APDM1.meta.Groups(2).Groups(i).Name '/Magnetometer'])';
    h5_APDM1.(name).data.gyr = h5read(file, [h5_APDM1.meta.Groups(2).Groups(i).Name '/Gyroscope'])';
end
% 
% figure
% subplot(2,3,4),plot(h5_APDM.Left_Foot(:,1),h5_APDM.Left_Foot(:,2),h5_APDM.Right_Foot(:,1),h5_APDM.Right_Foot(:,2))
% xlabel('Time (s)')
% ylabel('x(Time)')
% axis tight
% subplot(2,3,5),plot(h5_APDM.Left_Foot(:,1),h5_APDM.Left_Foot(:,3),h5_APDM.Right_Foot(:,1),h5_APDM.Right_Foot(:,3))
% xlabel('Time (s)')
% ylabel('y(Time)')
% axis tight
% subplot(2,3,6),plot(h5_APDM.Left_Foot(:,1),h5_APDM.Left_Foot(:,4),h5_APDM.Right_Foot(:,1),h5_APDM.Right_Foot(:,4))
% xlabel('Time (s)')
% ylabel('z(Time)')
% axis tight
% legend('Left Foot', 'Right Foot')
% 
% subplot(2,3,1),plot(h5_APDM.Lumbar(:,1),h5_APDM.Lumbar(:,2))
% xlabel('Time (s)')
% ylabel('x(Time)')
% axis tight
% subplot(2,3,2),plot(h5_APDM.Lumbar(:,1),h5_APDM.Lumbar(:,3))
% xlabel('Time (s)')
% ylabel('y(Time)')
% axis tight
% subplot(2,3,3),plot(h5_APDM.Lumbar(:,1),h5_APDM.Lumbar(:,4))
% xlabel('Time (s)')
% ylabel('y(Time)')
% axis tight
% 





