function app = analysis_MocapApdmAlignment(app, data, analysis)
% app = analysis_MocapApdmAlignment(app, data, analysis)
% inputs  - app, the BAR App object.
%         - data, the data structure loaded into the BAR App.
%         - analysis, a string stating the type of analysis being
%                     performed.
% outputs - app, the BAR App is returned as an output.
% Remarks
% -
% Future Work
% -
% Nov 2022 - Created by Ben Senderling
%
%% Begin Code

% Get all the file names from the data. This uses the raw data.
files = fieldnames(data.raw);

H = figure('visible', 'off','Units', 'Normalized', 'Position', [0, 0, 1, 1]);

subplot(2, 3, 1)
plot([0; 20], [0; 20], 'k-')
xlabel('Mocap Heel Strike (s)')
ylabel('APDM Heel Strike (s)')
axis([0 20 0 20])
hold on

subplot(2, 3, 4)
plot([0; 20], [0; 20], 'k-')
xlabel('Mocap Heel Strike (s)')
ylabel('APDM Heel Strike (s)')
axis([0 20 0 20])
hold on

rmse = [];

% This example will only iterate through the files. One could also iterate
% through the objects and signals.
for i = 1:length(files)

    obj = fieldnames(data.raw.(files{i}));

    ind_EVENT = find(contains(obj, 'EVENT'));
    if isempty(ind_EVENT)
        continue
    end
    ind_Crop = find(contains(obj, 'PROCESSED'));
    if isfield(data.raw.(files{i}).(obj{ind_EVENT}).data, 'LHS_X')
        hsMocapL = data.raw.(files{i}).(obj{ind_EVENT}).data.LHS_X + data.raw.(files{i}).(obj{ind_Crop}).data.Crop_Start_Frame_X/255;
    end
    if isfield(data.raw.(files{i}).(obj{ind_EVENT}).data, 'RHS_X')
        hsMocapR = data.raw.(files{i}).(obj{ind_EVENT}).data.RHS_X + data.raw.(files{i}).(obj{ind_Crop}).data.Crop_Start_Frame_X/255;
    end

    if isfield(data.raw.(files{i}), 'CR_CGAcc')
        hsMocapLCorrected = hsMocapL + data.raw.(files{i}).CR_CGAcc.data.XCorrLag/128 - data.raw.(files{i}).(obj{ind_Crop}).data.Crop_Start_Frame_X/255;
        hsMocapRCorrected = hsMocapR + data.raw.(files{i}).CR_CGAcc.data.XCorrLag/128 - data.raw.(files{i}).(obj{ind_Crop}).data.Crop_Start_Frame_X/255;
    end

    if isfield(data.raw.(files{i}), 'EventsGaitLowerLimb') && isfield(data.raw.(files{i}).EventsGaitLowerLimb.data, 'InitialContact')
        hsApdmL = data.raw.(files{i}).EventsGaitLowerLimb.data.InitialContact(1,:)';
        hsApdmR = data.raw.(files{i}).EventsGaitLowerLimb.data.InitialContact(2,:)';
    else
        continue
    end

    % Find which events are the closest for the uncorrected events.
    [~, lag] = min(abs(hsApdmL - hsMocapL(1)));
    aL = lag;
    if lag + length(hsMocapL) - 1 < length(hsApdmL)
        bL = lag + length(hsMocapL) - 1;
    else
        bL = length(hsApdmL);
    end
    
    [~, lag] = min(abs(hsApdmR - hsMocapR(1)));
    aR = lag;
    if lag + length(hsMocapR) - 1 < length(hsApdmR)
        bR = lag + length(hsMocapR) - 1;
    else
        bR = length(hsApdmR);
    end

    % Find which events are the closest for the corrected events.
    [~, lag] = min(abs(hsApdmL - hsMocapLCorrected(1)));
    aLCorrected = lag;
    if lag + length(hsMocapLCorrected) - 1 < length(hsApdmL)
        bLCorrected = lag + length(hsMocapLCorrected) - 1;
    else
        bLCorrected = length(hsApdmL);
    end
    
    [~, lag] = min(abs(hsApdmR - hsMocapRCorrected(1)));
    aRCorrected = lag;
    if lag + length(hsMocapRCorrected) - 1 < length(hsApdmR)
        bRCorrected = lag + length(hsMocapRCorrected) - 1;
    else
        bRCorrected = length(hsApdmR);
    end
    
    subplot(2, 3, 1)
    plot(hsMocapL(1:bL - aL + 1), hsApdmL(aL: bL), '.b')
    plot(hsMocapR(1:bR - aR + 1), hsApdmR(aR: bR), '.r')

    if isfield(data.raw.(files{i}), 'CR_CGAcc')
        subplot(2, 3, 4)
        plot(hsMocapLCorrected(1:bLCorrected - aLCorrected + 1), hsApdmL(aLCorrected: bLCorrected), '.b')
        plot(hsMocapRCorrected(1:bRCorrected - aRCorrected + 1), hsApdmR(aRCorrected: bRCorrected), '.r')
    end

    if rem(i, 10) == 0
        app.printLog('024', [num2str(i) ' of ' num2str(length(files)) ' analyzed']);
    end

    if isfield(data.raw.(files{i}).(obj{ind_EVENT}).data, 'LHS_X')
        rmse = [rmse; mean(hsMocapL(1:bL - aL + 1) - hsApdmL(aL: bL)), mean(hsMocapLCorrected(1:bLCorrected - aLCorrected + 1) - hsApdmL(aLCorrected: bLCorrected))];
    end

end

subplot(2, 3, 1)
title({'Individual heel strike alignment from each trial'; ['RMSE = ' num2str(sqrt(mean(rmse(:, 1).^2, 'omitnan')))]});

subplot(2, 3, 4)
title(['RMSE = ' num2str(sqrt(mean(rmse(:, 2).^2, 'omitnan')))]);

subplot(2, 3, [2, 3, 5, 6])
histogram(rmse(:, 1), floor(min(rmse(:, 1))):0.2:ceil(max(rmse(:, 1))))
hold on
histogram(rmse(:, 2), floor(min(rmse(:, 2))):0.2:ceil(max(rmse(:, 2))))
hold off
xlim([-5, 5])
legend('Uncorrected', 'Corrected')
xlabel('Error (s)')
ylabel('Number of trials')
title('Error for each trial')

saveas(H, [app.Database.Value '\Figures\Figure04.jpg'])

analysisComplete(app, data, analysis)

end