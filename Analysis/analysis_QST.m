function app = analysis_QST(app, data, analysis)


files = fieldnames(data.raw);
for i = 1:length(files)
    obj = fieldnames(data.raw.(files{i}));
    obj(strcmp(obj, 'meta')) = [];
    obj(strcmp(obj, 'groups')) = [];

    H = figure('visible', 'off');
    H.Units = 'Normalized';
    H.Position = [0 0 1 1];

    for j = 1:length(obj)
        sequenceN(j, 1) = str2double(obj{j}(9));
        trialN(j, 1) = str2double(obj{j}(end));
    end

    for j = 1:length(obj)

        data.res.(files{i}).(obj{j}).data.sequenceN = sequenceN(j);
        data.res.(files{i}).(obj{j}).data.trialN = trialN(j);
        
        [m, I] = max(data.raw.(files{i}).(obj{j}).data.Pressure_kPa_);
        data.res.(files{i}).(obj{j}).data.valuePeak = m;
        
        I2 = find(data.raw.(files{i}).(obj{j}).data.Event);
        data.res.(files{i}).(obj{j}).data.valueEvent = data.raw.(files{i}).(obj{j}).data.Pressure_kPa_(I2);
        
        lm = fitlm(data.raw.(files{i}).(obj{j}).data.Timestamp_msec_/1000,data.raw.(files{i}).(obj{j}).data.Pressure_kPa_);
        data.res.(files{i}).(obj{j}).data.rSquaredAdjusted = lm.Rsquared.Adjusted;
        data.res.(files{i}).(obj{j}).data.slope = lm.Coefficients.Estimate(2);

        y = 10;
        x(j) = max(data.raw.(files{i}).(obj{j}).data.Timestamp_msec_(I2)/1000);

        subplot(max(sequenceN), max(trialN), j)
        hold on
        plot(data.raw.(files{i}).(obj{j}).data.Timestamp_msec_/1000, data.raw.(files{i}).(obj{j}).data.Pressure_kPa_, 'k')
        plot([0; data.raw.(files{i}).(obj{j}).data.Timestamp_msec_(I)/1000], [m; m], 'k--')
        plot([data.raw.(files{i}).(obj{j}).data.Timestamp_msec_(I2)/1000; data.raw.(files{i}).(obj{j}).data.Timestamp_msec_(I2)/1000], [0; data.raw.(files{i}).(obj{j}).data.Pressure_kPa_(I2)], 'k-.')
        hold off
        xlabel('Time (s)')
        ylabel('Pressure (kPa)')
        title(obj{j})
        
    end

    for j = 1:length(obj)
        subplot(max(sequenceN), max(trialN), j)
        xlim([0, max(x)])
        ylim([0, y])
    end

    saveas(H, [app.Database.Value '\Figures\Figure01_' files{i} '.jpg'])
    close(H)

    if rem(i, 10) == 0
        app.printLog('024', [num2str(i) ' of ' num2str(length(files)) ' analyzed']);
    end

end

analysisComplete(app, data, analysis)

end