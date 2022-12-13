function app = analysis_QSTTraining(app, data, analysis)
% app = analysis_QSTTraining(app, data, analysis)
% inputs  - app, required mlapp object.
%         - data, BAR App data structure.
%         - analysis, string of the analysis type.
% Remarks
% - This analysis script will create a summary figure using all the data. It uses QST data recorded through Medoc software. Figures are created for
%   each specific body site specified in the software. This code was originally meant to be run on training data and used to asses the quality of an
%   experimenters rate of pressure application.
% - The code will calculate an Adjusted R Squared and slope to display on the figures.
% Future Work
% - None.
% Nov 2022 - Created by Ben Senderling, bsender@bu.edu
%% Begin Code

% Initialize an empty plot variable.
plotData = [];

% Start iterating through the files.
files = fieldnames(data.raw);
for i = 1:length(files)

    % Get the object names and remove the informational ones.
    obj = fieldnames(data.raw.(files{i}));
    obj(strcmp(obj, 'meta')) = [];
    obj(strcmp(obj, 'groups')) = [];

    % Check if a specific body site was specified in the software. Data at similar sites will be collected into the same object.
    if isfield(data.raw.(files{i}).meta, 'Body_Site_Specific')
        site = data.raw.(files{i}).meta.Body_Site_Specific;
    else
        % If the site wasn't specified use a general tag.
        site = 'Unspecified';
    end

    % Check if the site has been used before and get it's index.
    if any(strcmp(plotData(:), site))
        ind = find(contains(plotData(:, 1), site));
    else
        % If the site hasn't been used before add it.
        ind = size(plotData, 1) + 1;
        plotData{ind, 1} = site;
    end

    % Start iterating through the objects.
    for j = 1:length(obj)

        % Get the time.
        time = data.raw.(files{i}).(obj{j}).data.Timestamp_msec_/1000;
        % Get the pressure.
        values = data.raw.(files{i}).(obj{j}).data.Pressure_kPa_;
        % Find the maximum pressure and remove everything after it. In some cases a trigger may be late or the experimenter may lift off the pressure.
        % These cases cause variable drops in pressure that distort the quality assesment.
        [~, I] = max(values);
        time(I + 1:end) = [];
        values(I + 1:end) = [];

        % Pad the end of the data so it can be resampled to a uniform sampling rate. If this is not down resampling will cause large edge artifacts.
        values_pad = [values; repmat(values(end), 10, 1)];
        time_pad = [time', time(end) + 1/10 : 1/10 : time(end) + 1/10*10];

        % Perform the resampling to 10 Hs.
        values_resampled = resample(values_pad, time_pad, 10);
        time_resampled = (0 : length(values_resampled) - 1)'/10;

        % Remove the  padded data.
        values_resampled(time_resampled > time(I)) = [];
        time_resampled(time_resampled > time(I)) = [];

        % If no data has been added to this site yet add the data unmodified.
        if size(plotData, 2) < 2
            plotData{ind, 2} = values_resampled;
        else
            % If data has been added already it needs to be padded with NaNs so the vectors are the same length.
            if (size(plotData{ind, 2}, 1) > length(values_resampled)) || isempty(plotData{ind, 2})
                % Existing data is longer than the new data.
                plotData{ind, 2}(:, end + 1) = [values_resampled; nan*ones(size(plotData{ind, 2}, 1) - length(values_resampled), 1)];
            elseif size(plotData{ind, 2}, 1) < length(values_resampled)
                % Existing data is shorter than the new data.
                plotData{ind, 2} = [plotData{ind, 2}; nan*ones(length(values_resampled) - size(plotData{ind, 2}, 1), size(plotData{ind, 2}, 2))];
            end
        end

    end

    % A message will be printed to the main BAR App every 10 files.
    if rem(i, 10) == 0
        app.printLog('024', [num2str(i) ' of ' num2str(length(files)) ' analyzed']);
    end

end

%% Create the figure

% Get the number of sites used in all the trials.
N = size(plotData, 1);
% Initialize the number of columns to a number for easy viewing.
c = 3;
% If only one site was used change the number of rows and columns to only produce one plot.
if N == 1
    r = 1;
    c = 1;
% If two sites were used do two plots.
elseif N ==2
    r = 1;
    c = 2;
elseif N > c
    % If more than 3 sites were used find a number of rows to support it.
    r = ceil(N/c);
else
    % If there was only 3 sites use 1 row.
    r = 1;
end

% Create the figure with a large size.
H = figure('visible', 'off');
H.Units = 'Normalized';
H.Position = [0 0 1 1];

% Iterate through all the body sites.
for i = 1:N

    % Create the subplot.
    subplot(r, c, i)
    hold on
    % Create a fill for the target pressure rate.
    fill([0.01;1;20;20;19;0.01;0.01], [0.01;0.01;19;20;20;1;0.01], [0.9, 0.9, 0.9], 'EdgeColor', 'none')
    plot([0;20], [0;20], 'k:')

    % Calculate the mean and standard deviation of the pressure application. Since NaNs were used to pad the array they need to be omited.
    time = (0:length(mean(plotData{i, 2}, 2, 'omitnan')) - 1)'/10;
    dataMean = mean(plotData{i, 2}, 2, 'omitnan');
    dataSTD = std(plotData{i, 2}, [], 2, 'omitnan');
    
    removeIndex = isnan(time) | isnan(dataMean) | isnan(dataSTD) | dataSTD == 0;
    time(removeIndex) = [];
    dataMean(removeIndex) = [];
    dataSTD(removeIndex) = [];

    % Create a fill of the mean pressure application.
    fill([time; flipud(time)], [dataMean - dataSTD; flipud(dataMean + dataSTD)], [0 0.4470 0.7410], 'EdgeColor', 'none', 'FaceAlpha', 0.5)
    % Draw the mean.
    plot(time, dataMean, 'k')

    % Calculate a linear model and display the results on the figure.
    lm = fitlm(time, dataMean);
    text(time(end)/2, time(end)/8, {['R^2 = ' num2str(lm.Rsquared.Adjusted, 2)]; ['m = ' num2str(lm.Coefficients.Estimate(2), 2)]})

    hold off
    xlabel('Time (s)')
    ylabel('Pressure (kPa)')
    title(plotData{i, 1})

    % Save the extent of the x and y axis so all the figures can be made the same and square.
    x(i) = max([time; dataMean + dataSTD]);

end

% Iterate through all the subplots again to make the axes the same.
for i = 1:N
    subplot(r, c, i)
    xlim([0 max(x)])
    ylim([0 max(x)])
end

%%

% Save the figure and close it.
saveas(H, [app.Database.Value '\Figures\Figure01_Summary.jpg'])
close(H)

% Run the public BAR App analysisComplete method to get the data back into the app.
analysisComplete(app, data, analysis)

end