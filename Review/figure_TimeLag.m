function H = figure_TimeLag(app, data)
% H = figure_TimeLag(app, data)
% inputs  - app, the review module object.
%         - data, the data structure from the BAR App.
% outputs - H, figure that will be used by the BAR App to copy into the figure panel.
% Remarks
% - This function will create a specific figure for a time lag analysis. The app object is used to determine which data levels have been selected. The
%   full data structure is needed but users will only be able to select the file and object levels. The signal and dimension levels are selected
%   automatically.
% Future Work
% - None.
% Dec 2022 - Created by Ben Senderling, bsender@bu.edu

% An invisible figure will be created and then copied into the app. This allows it to be printed or used elsewhere.
H = figure('visible', 'off');

% Initialize empty arrays.
plotData = [];
plotMinimumsAll = [];
plotMinimumsFirst = [];
plotMinimums1Fifth = [];
% Initialize a column index for the data.
ind = 1;

% Get the file names.
files = fieldnames(data.ana.TimeLag);
% Start iterating through the files.
for i = 1:length(files)
    % Proceed if the current file is selected, nothing is selected, or all is selected.
    if any(strcmp(app.FilesListBox.Value, files{i})) || isempty(app.FilesListBox.Value) || any(strcmp(app.FilesListBox.Value, 'all'))

        % Proceed if there is no meta data, or if no meta fields are selected, or if the selected meta field is not an option for the
        % current file or none is selected, and if the meta value is equal to the meta field's value for the current file or none is
        % selected for the meta value.
        if ~isfield(data.raw.(files{i}), 'meta') || isempty(app.MetaFieldListBox.Value) || (isfield(data.raw.(files{i}).meta, app.MetaFieldListBox.Value{1}) || strcmp(app.MetaFieldListBox.Value{1}, 'none')) && (strcmp(data.raw.TimeLag.(files{i}).meta.(app.MetaFieldListBox.Value{1}), app.MetaValueListBox.Value) || strcmp(app.MetaValueListBox.Value, 'none'))

            % Get the object names and remove the informational fields.
            obj = fieldnames(data.ana.TimeLag.(files{i}));
            obj(strcmp(obj, 'meta')) = [];
            obj(strcmp(obj, 'groups')) = [];
            % Start iterating through the objects.
            for j = 1:length(obj)
                % Proceed if the current object is selected, or if nothing is selected, or if all is selected.
                if any(strcmp(app.ObjectsListBox.Value, obj{j})) || isempty(app.ObjectsListBox.Value) || any(strcmp(app.ObjectsListBox.Value, 'all'))
                    % Get the signal names.
                    sigs = fieldnames(data.ana.TimeLag.(files{i}).(obj{j}).data);
                    % Iterate through the signal names.
                    for k = 1:length(sigs)
                        % If the current signal is selected by the user, or
                        % the selection is empty, or 'all' is selected.
                        if any(strcmp(app.SignalsListBox.Value, sigs{k})) || isempty(app.SignalsListBox.Value) || any(strcmp(app.SignalsListBox.Value, 'all'))
                            % If there is a 'ami' result in the analysis
                            % results, and there are no NaN's in the result
                            if isfield(data.ana.TimeLag.(files{i}).(obj{j}).data.(sigs{k}), 'ami') && ~any(isnan(data.ana.TimeLag.(files{i}).(obj{j}).data.(sigs{k}).ami), 'all')
                                % Save the time lag values.
                                plotData{1}(:, ind) = data.ana.TimeLag.(files{i}).(obj{j}).data.(sigs{k}).ami(:, 1);
                                % Save the average mutual information
                                % values for each time lag.
                                plotData{2}(:, ind) = data.ana.TimeLag.(files{i}).(obj{j}).data.(sigs{k}).ami(:, 2);
                                % Increase the column index.
                                ind = ind + 1;
                                % Save the individual results to a list to
                                % use.
                                plotMinimumsAll = [plotMinimumsAll; data.ana.TimeLag.(files{i}).(obj{j}).data.(sigs{k}).tau1st];
                                plotMinimumsFirst = [plotMinimumsFirst; data.ana.TimeLag.(files{i}).(obj{j}).data.(sigs{k}).tau1st(1, :)];
                                plotMinimums1Fifth = [plotMinimums1Fifth; data.ana.TimeLag.(files{i}).(obj{j}).data.(sigs{k}).tau15th(end, :)];
                            end
                        end
                    end
                end
            end
        end
    end
end

% If the ensemble option is checked.
if app.PlotensembleCheckBox.Value == 1
    % Create a fill using the mean and one standard deviation.
    fill([mean(plotData{1}, 2, 'omitnan'); flipud(mean(plotData{1}, 2, 'omitnan'))], [mean(plotData{2}, 2, 'omitnan') - std(plotData{2}, [], 2, 'omitnan'); flipud(mean(plotData{2}, 2, 'omitnan') + std(plotData{2}, [], 2, 'omitnan'))], [0.7, 0.7, 0.7], 'LineStyle', 'none');
    % Keep track of the highest y value.
    a = max(mean(plotData{2}, 2, 'omitnan') + std(plotData{2}, [], 2, 'omitnan'), [], 'all');
    hold on
    % Plot the mean as a black line.
    plot(mean(plotData{2}, 2), 'k');
    % Plot the mean values making sure to omit any NaN values.
    plot(mean(plotMinimumsFirst(:,1), 'omitnan'), mean(plotMinimumsFirst(:,2), 'omitnan'), 'ro');
    plot(mean(plotMinimums1Fifth(:,1), 'omitnan'), mean(plotMinimums1Fifth(:,2), 'omitnan') ,'bo');
    hold off
    legend('+/- 1 STD', 'AMI', 'First Min', '1/5th Value')

else

    % Plot the data creating an axis handle for each line.
    ax(1:size(plotData{2}, 2)) = plot(plotData{1}, plotData{2}, 'k');
    % Keep track of the highest y value.
    a = max(plotData{2}, [], 'all');
    hold on
    % Plot all the time lag options creating an axis handle for each.
    bx(1) = plot(plotMinimumsAll(:,1), plotMinimumsAll(:,2), 'k.');
    bx(2) = plot(plotMinimumsFirst(:,1), plotMinimumsFirst(:,2), 'ro');
    bx(3) = plot(plotMinimums1Fifth(:,1), plotMinimums1Fifth(:,2) ,'bo');
    hold off
    % Create a legend using only certain axis handles.
    legend([ax(1), bx(1), bx(2), bx(3)], {'AMI', 'Minimums', 'First Min', '1/5th Value'})

end
% Use the stored max to adjust the y axis.
axis([0 size(plotData{2}, 1) 0 a])
xlabel('Time Lag (frames)')
ylabel('Average Mutual Information')


end