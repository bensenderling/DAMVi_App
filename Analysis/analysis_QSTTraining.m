function app = analysis_QSTTraining(app, data, analysis)

plotData = [];

files = fieldnames(data.raw);
for i = 1:length(files)
    obj = fieldnames(data.raw.(files{i}));
    obj(strcmp(obj, 'meta')) = [];
    obj(strcmp(obj, 'groups')) = [];

    if isfield(data.raw.(files{i}).meta, 'Body_Site_Specific')
        site = data.raw.(files{i}).meta.Body_Site_Specific;
    else
        site = 'Unspecified';
    end
    if any(strcmp(plotData(:), site))
        ind = find(contains(plotData(:, 1), site));
    else
        ind = size(plotData, 1) + 1;
        plotData{ind, 1} = site;
    end

    for j = 1:length(obj)

        time = data.raw.(files{i}).(obj{j}).data.Timestamp_msec_/1000;
        values = data.raw.(files{i}).(obj{j}).data.Pressure_kPa_;
        [~, I] = max(values);
        time(I + 1:end) = [];
        values(I + 1:end) = [];

        values_pad = [values; repmat(values(end), 10, 1)];
        time_pad = [time', time(end) + 1/10 : 1/10 : time(end) + 1/10*10];

        values_resampled = resample(values_pad, time_pad, 10);
        time_resampled = (0 : length(values_resampled) - 1)'/10;

        values_resampled(time_resampled > time(I)) = [];
        time_resampled(time_resampled > time(I)) = [];

        %         figure
        %         plot(time, values, 'k', time_pad, values_pad, 'k.', time_resampled, values_resampled, 'b')

        if size(plotData, 1) < 2
            plotData{ind, 2} = values_resampled;
        else
            if (size(plotData{ind, 2}, 1) > length(values_resampled)) || isempty(plotData{ind, 2})
                plotData{ind, 2}(:, end + 1) = [values_resampled; nan*ones(size(plotData{ind, 2}, 1) - length(values_resampled), 1)];
            elseif size(plotData{ind, 2}, 1) < length(values_resampled)
                plotData{ind, 2} = [plotData{ind, 2}; nan*ones(length(values_resampled) - size(plotData{ind, 2}, 1), size(plotData{ind, 2}, 2))];
            end
        end



    end


    if rem(i, 10) == 0
        app.printLog('024', [num2str(i) ' of ' num2str(length(files)) ' analyzed']);
    end

end

%%

N = size(plotData, 1);
c = 3;
if N > c
    r = ceil(N/c);
else
    r = 1;
end

H = figure('visible', 'off');
H.Units = 'Normalized';
H.Position = [0 0 1 1];

for i = 1:N

    subplot(r, c, i)
    hold on
    fill([0.01;1;20;20;19;0.01;0.01], [0.01;0.01;19;20;20;1;0.01], [0.9, 0.9, 0.9], 'EdgeColor', 'none')
    plot([0;20], [0;20], 'k:')

    time = (0:length(mean(plotData{i, 2}, 2, 'omitnan')) - 1)'/10;
    dataMean = mean(plotData{i, 2}, 2, 'omitnan');
    dataSTD = std(plotData{i, 2}, [], 2, 'omitnan');
    removeIndex = isnan(time) | isnan(dataMean) | isnan(dataSTD) | dataSTD == 0;
    
    time(removeIndex) = [];
    dataMean(removeIndex) = [];
    dataSTD(removeIndex) = [];

    fill([time; flipud(time)], [dataMean - dataSTD; flipud(dataMean + dataSTD)], [0 0.4470 0.7410], 'EdgeColor', 'none', 'FaceAlpha', 0.5)

    plot(time, dataMean, 'k')

    lm = fitlm(time, dataMean);
    text(time(end)/2, time(end)/8, {['R^2 = ' num2str(lm.Rsquared.Adjusted, 2)]; ['m = ' num2str(lm.Coefficients.Estimate(2), 2)]})

    hold off
    xlabel('Time (s)')
    ylabel('Pressure (kPa)')
    title(plotData{i, 1})

    x(i) = max([time; dataMean + dataSTD]);

end

for i = 1:N
    subplot(r, c, i)
    xlim([0 max(x)])
    ylim([0 max(x)])
end

%%

saveas(H, [app.Database.Value '\Figures\Figure01_Summary.jpg'])
close(H)

analysisComplete(app, data, analysis)

end