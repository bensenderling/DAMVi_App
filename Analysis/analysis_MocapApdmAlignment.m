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

H = figure('visible', 'on');

plot([0; 10], [0; 10], 'k-')
xlabel('Mocap Heel Strike (s)')
ylabel('APDM Heel Strike (s)')
axis([0 10 0 10])
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
    hsMocapL = data.raw.(files{i}).(obj{ind_EVENT}).data.LHS_X + data.raw.(files{i}).(obj{ind_Crop}).data.Crop_Start_Frame_X/255;
    hsMocapR = data.raw.(files{i}).(obj{ind_EVENT}).data.RHS_X + data.raw.(files{i}).(obj{ind_Crop}).data.Crop_Start_Frame_X/255;

    if isfield(data.raw.(files{i}), 'CR_CGAcc')
        hsMocapL = hsMocapL + data.raw.(files{i}).CR_CGAcc.XCorrLag/128 - data.raw.(files{i}).(obj{ind_Crop}).data.Crop_Start_Frame_X/255;
        hsMocapR = hsMocapR + data.raw.(files{i}).CR_CGAcc.XCorrLag/128 - data.raw.(files{i}).(obj{ind_Crop}).data.Crop_Start_Frame_X/255;
    end

    hsApdmL = data.raw.(files{i}).EventsGaitLowerLimb.data.InitialContact(1,:)';
    hsApdmR = data.raw.(files{i}).EventsGaitLowerLimb.data.InitialContact(2,:)';

    [~, lag] = min(abs(hsApdmL - hsMocapL(1)));
    a = lag;
    if lag + length(hsMocapL) - 1 < length(hsApdmL)
        b = lag + length(hsMocapL) - 1;
    else
        b = length(hsApdmL);
    end
    plot(hsMocapL(1:b - a + 1), hsApdmL(a: b), '.b')

    [~, lag] = min(abs(hsApdmR - hsMocapR(1)));
    plot(hsMocapR, hsApdmR(lag: lag + length(hsMocapR) - 1), '.r')

    if rem(i, 10) == 0
        app.printLog('024', [num2str(i) ' of ' num2str(length(files)) ' analyzed']);
    end

    rmse = [rmse; hsMocapL(1:b - a + 1) - hsApdmL(a: b)];

end

title(['RMSE = ' num2str(sqrt(mean(rmse.^2)))]);

if isfield(data.raw.(files{i}), 'CR_CGAcc')
    saveas(H, [app.Database.Value '\Figures\Figure03_HSCorrected.jpg'])
else
    saveas(H, [app.Database.Value '\Figures\Figure03_HSUncorrected.jpg'])
end


analysisComplete(app, data, analysis)

end