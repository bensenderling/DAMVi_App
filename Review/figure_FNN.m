function H = figure_FNN(app, data)
% H = figure_FNN(app, data)
% inputs  - app, the review module object.
%         - data, the data structure from the BAR App.
% outputs - H, figure that will be used by the BAR App to copy into the figure panel.
% Remarks
% - This function will create a specific figure for a false nearest neighbor analysis. The app object is used to determine which data levels have been
%   selected. The full data structure is needed but users will only be able to select the file and object levels. The signal and dimension levels are
%   selected automatically.
% Future Work
% - There could be a way to incorporate group information.
% Dec 2022 - Created by Ben Senderling, bsender@bu.edu

% An invisible figure will be created and then copied into the app. This allows it to be printed or used elsewhere.
H = figure('visible', 'off');

% Initialize empty arrays.
plotData = [];
plotDims = [];
% Initialize a column index for the data.
ind = 1;

% Get the file names.
files = fieldnames(data.ana.FNN);
% Start iterating through the files.
for i = 1:length(files)
    % Proceed if the current file is selected, nothing is selected, or all is selected.
    if any(strcmp(app.FilesListBox.Value, files{i})) || isempty(app.FilesListBox.Value) || any(strcmp(app.FilesListBox.Value, 'all'))

        % Proceed if there is no meta data, or if no meta fields are selected, or if the selected meta field is not an option for the
        % current file or none is selected, and if the meta value is equal to the meta field's value for the current file or none is
        % selected for the meta value.
        if ~isfield(data.raw.(files{i}), 'meta') || isempty(app.MetaFieldListBox.Value) || (isfield(data.raw.(files{i}).meta, app.MetaFieldListBox.Value{1}) || strcmp(app.MetaFieldListBox.Value{1}, 'none')) && (strcmp(data.raw.TimeLag.(files{i}).meta.(app.MetaFieldListBox.Value{1}), app.MetaValueListBox.Value) || strcmp(app.MetaValueListBox.Value, 'none'))

            % Get the object names and remove the informational fields.
            obj = fieldnames(data.ana.FNN.(files{i}));
            obj(strcmp(obj, 'meta')) = [];
            obj(strcmp(obj, 'groups')) = [];
            % Start iterating through the objects.
            for j = 1:length(obj)
                % Proceed if the current object is selected, or if nothing is selected, or if all is selected.
                if any(strcmp(app.ObjectsListBox.Value, obj{j})) || isempty(app.ObjectsListBox.Value) || any(strcmp(app.ObjectsListBox.Value, 'all'))
                    % Get the signal names.
                    sigs = fieldnames(data.ana.FNN.(files{i}).(obj{j}).data);
                    % Iterate through the signal names.
                    for k = 1:length(sigs)
                        % If the current signal is selected by the user, or the selection is empty, or 'all' is selected.
                        if any(strcmp(app.SignalsListBox.Value, sigs{k})) || isempty(app.SignalsListBox.Value) || any(strcmp(app.SignalsListBox.Value, 'all'))
                            % If there is 'dE' in the analysis results, and there is a 'dim' field in the results, and the 'dim' result is not a NaN.
                            if isfield(data.ana.FNN.(files{i}).(obj{j}).data.(sigs{k}), 'dE') && isfield(data.res.FNN.(files{i}).(obj{j}).data.(sigs{k}), 'dim')
                                % Iterate through the dimensions.
                                for ind_dim = 1:size(data.res.FNN.(files{i}).(obj{j}).data.(sigs{k}).dim, 2)
                                    % If the current dimension is selected by the user, or the selection is empty, or 'all' is selected.
                                    if (any(str2double(app.DimensionListBox.Value) == ind_dim) || isempty(app.DimensionListBox.Value) || any(strcmp(app.DimensionListBox.Value, 'all'))) && ~isnan(data.res.FNN.(files{i}).(obj{j}).data.(sigs{k}).dim(ind_dim))
                                        % The length of the 'dE' result is the number of dimensions and the x axis.
                                        plotData{1}(:, ind) = 1:length(data.ana.FNN.(files{i}).(obj{j}).data.(sigs{k}).dE{ind_dim});
                                        % The 'dE' values are the y axis.
                                        plotData{2}(:, ind) = data.ana.FNN.(files{i}).(obj{j}).data.(sigs{k}).dE{ind_dim};
                                        % Increase the column index.
                                        ind = ind + 1;
                                        % Add the dimension to the list to use in the histogram.
                                        plotDims = [plotDims; data.res.FNN.(files{i}).(obj{j}).data.(sigs{k}).dim(ind_dim), data.ana.FNN.(files{i}).(obj{j}).data.(sigs{k}).dE{ind_dim}(data.res.FNN.(files{i}).(obj{j}).data.(sigs{k}).dim(ind_dim))];
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

% The first subplot has the % FNN plot.
subplot(2, 1, 1)
% If the ensemble option is checked.
if app.PlotensembleCheckBox.Value == 1
    % Create a fill using the mean and one standard deviation.
    fill([mean(plotData{1}, 2, 'omitnan'); flipud(mean(plotData{1}, 2, 'omitnan'))], [mean(plotData{2}, 2, 'omitnan') - std(plotData{2}, [], 2, 'omitnan'); flipud(mean(plotData{2}, 2, 'omitnan') + std(plotData{2}, [], 2, 'omitnan'))], [0.7, 0.7, 0.7], 'LineStyle', 'none');
    % Keep track of the highest y value.
    a = max(mean(plotData{2}, 2, 'omitnan') + std(plotData{2}, [], 2, 'omitnan'), [], 'all');
    hold on
    % Plot the mean as a black line.
    plot(mean(plotData{2}, 2), 'k');
    % Plot the mean embedding dimension.
    plot(mean(plotDims(:,1), 'omitnan'), mean(plotDims(:,2), 'omitnan'), 'ro');
    hold off
    % Create a legend.
    legend('+/- 1 STD', '% FNN', 'Embedding')

else
    % Plot the data creating an axis handle for each line.
    ax(1:size(plotData{2}, 2)) = plot(plotData{1}, plotData{2}, 'k');
    % Keep track of the highest y value.
    a = max(plotData{2}, [], 'all');
    hold on
    % Plot all the selected embeding dimensions.
    bx(1) = plot(plotDims(:,1), plotDims(:,2), 'k.', 'MarkerSize', 12);
    hold off
    % Use certain axis handles to create the legend.
    legend([ax(1), bx(1)], {'% FNN', 'Embedding'})

end

% Use the stored max to adjust the y axis.
axis([0 size(plotData{2}, 1) 0 a])
xlabel('Embedding Dimension')
ylabel('% False Nearest Neighbors')

% The second plot is a histogram of the results.
subplot(2, 1, 2)
% Create the bin edges. This is easy to create with the small number of integer results.
bins = (0:max(plotData{1}, [], 'all'));
% create the histogram.
histogram(plotDims(:, 1), bins, 'FaceColor', 'k');
axis('tight')

xlabel('Bins')
ylabel('Count')


end