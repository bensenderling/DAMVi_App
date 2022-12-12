function app = analysis_APDMResultsFigures(app, data, analysis)
% app = analysis_APDMResultsFigures(app, data, analysis)
% inputs  - app, the BAR App object.
%         - data, the data structure loaded into the BAR App.
%         - analysis, a string stating the type of analysis being
%                     performed.
% outputs - app, the BAR App is returned as an output.
% Remarks
% - This script will create figures of raw and processed APDM data. The raw
%   data is used to calculate euler angles. The results are the heel strike
%   and turning information found in processed APDM files.
% - The figures created here are preliminary before working out how to
%   segment stair climbing data recorded with APDM Opal sensors.
% Future Work
% - As an example there is nothing of note.
% Nov 2022 - Created by Ben Senderling
%
%% Begin Code

% Get all the file names from the data. This uses the raw data.
files = fieldnames(data.raw);

% This example will only iterate through the files. One could also iterate
% through the objects and signals.
for i = 1:length(files)

    ang = quat2eul(data.raw.(files{i}).Lumbar.data.qua)*180/pi;
    time = (0:length(data.raw.(files{i}).Lumbar.data.qua) - 1)/data.raw.(files{i}).Lumbar.freq;

    d = diff(ang);
    for k = 1:size(d, 2)
        ind = find(abs(d(:, k)) > 180);
        for j = 1:length(ind)
            ang(ind(j) + 1:end, 1) = ang(ind(j) + 1:end, 1) - d(ind(j), k);
        end
    end

    H = figure('visible', 'on', 'Units', 'Normalized', 'Position', [0 0 1 1]);

    flag = 0;

    subplot(3,1,1)
    plot(time, ang(:,1), 'k');
    axis tight
    xlabel('Time (s)')
    ylabel('Yaw (deg)')
    title('APDM Opal Lumbar Orientation with Processing Results')

    subplot(3,1,2)
    plot(time, ang(:,2), 'k');
    axis tight
    xlabel('Time (s)')
    ylabel('Roll (deg)')

    subplot(3,1,3)
    plot(time, ang(:,3), 'k');
    axis tight
    xlabel('Time (s)')
    ylabel('Pitch (deg)')

    if isfield(data.raw.(files{i}), 'EventsGaitLowerLimb')
        hsl = data.raw.(files{i}).EventsGaitLowerLimb.data.InitialContact(1,:)';
        hsr = data.raw.(files{i}).EventsGaitLowerLimb.data.InitialContact(2,:)';

        for j = 1:3
            subplot(3,1,j)
            hold on
            plot(hsl, ang(round(hsl*data.raw.(files{i}).Lumbar.freq), j), '*b')
            plot(hsr, ang(round(hsr*data.raw.(files{i}).Lumbar.freq), j), '*r')
            hold off
        end

        flag = 1;
    end

    if isfield(data.raw.(files{i}), 'EventsTurns')
        turnsStart = data.raw.(files{i}).EventsTurns.data.Start;
        turnsEnd = data.raw.(files{i}).EventsTurns.data.Start + data.raw.(files{i}).MeasuresTurns.data.Duration;
        for j = 1:data.raw.(files{i}).MeasuresTurns.data.N
            for k = 1:3
                subplot(3, 1, k)
                hold on
                plot([turnsStart(j);turnsStart(j)], [min(ang(:, k)); max(ang(:, k))], 'g')
                plot([turnsEnd(j);turnsEnd(j)], [min(ang(:, k)); max(ang(:, k))], 'r')
                hold off
            end
        end

        flag = 2;
    end

    subplot(3, 1, 1)
    switch flag
        case 1
            legend('IMU', 'LHS', 'RHS')
        case 2
            legend('IMU', 'LHS', 'RHS', 'Turn Start', 'Turn End', 'Location', 'NorthWest')
    end

    try
        saveas(H, [app.Database.Value '\Figures\Figure01_' strjoin(data.raw.(files{i}).groups, '_') '.jpg'])
    catch
        app.printLog('028', [app.Database.Value '\Figures\Figure01_' strjoin(data.raw.(files{i}).groups, '_') '.jpg']);
    end

    if rem(i, 10) == 0
        app.printLog('024', [num2str(i) ' of ' num2str(length(files)) ' analyzed']);
    end

end

analysisComplete(app, data, analysis)

end