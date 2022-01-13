function h5_APDM = load_h5_APDM(file)

dbstop if error

h5_APDM.meta = h5info(file);

%%

for i = 1:length({h5_APDM.meta.Groups(2).Groups.Name})
    name = h5readatt(file,[h5_APDM.meta.Groups(2).Groups(i).Name '/Configuration'], 'Label 0');
    name = regexprep(name, {' ', char(0)}, {'_', ''});
    h5_APDM.(name) = double(h5read(file,[h5_APDM.meta.Groups(2).Groups(i).Name '/Time']));
    h5_APDM.(name) = (h5_APDM.(name) - h5_APDM.(name)(1))/1e6;
    h5_APDM.(name)(:,2:4) = h5read(file, [h5_APDM.meta.Groups(2).Groups(i).Name '/Accelerometer'])';
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





