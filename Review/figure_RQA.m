function H = figure_RQA(app, data)
% H = figure_RQA(app, data)
% inputs  - app, the review module object.
%         - data, the data structure from the BAR App.
% outputs - H, figure that will be used by the BAR App to copy into the figure panel.
% Remarks
% - This function will create a specific figure for a reccurence quantification analysis. The app object is used to determine which data levels have been
%   selected. The full data structure is needed but users will only be able to select the file and object levels. The signal and dimension levels are
%   selected automatically.
% Future Work
% - None.
% Dec 2022 - Created by Ben Senderling, bsender@bu.edu

% Initialize empty arrays.
plotData = [];

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
                        % If the current signal is selected by the user, or
                        % the selection is empty, or 'all' is selected.
                        if any(strcmp(app.SignalsListBox.Value, sigs{k})) || isempty(app.SignalsListBox.Value) || any(strcmp(app.SignalsListBox.Value, 'all'))
                            % If there is a 'recurrendePlot' result in the
                            % analysis results, and the RQA analysis was
                            % successful.
                            if isfield(data.ana.RQA.(files{i}).(obj{j}).data.(sigs{k}), 'recurrencePlot') && data.res.RQA.(files{i}).(obj{j}).data.(sigs{k}).RQAresults == 1
                                % A recurrence plot will only be displayed
                                % for the first selected
                                % file-object-signal.
                                if ind == 1
                                    recurrencePlot = data.ana.RQA.(files{i}).(obj{j}).data.(sigs{k}).recurrencePlot;
                                    % The type and data are required to
                                    % make portions of the plot.
                                    type = data.res.RQA.(files{i}).(obj{j}).data.(sigs{k}).TYPE;
                                    dataRQA = data.ana.RQA.(files{i}).(obj{j}).data.(sigs{k}).DATA;
                                end
                                % Get the measures from the RQA analysis.
                                meas = fieldnames(data.res.RQA.(files{i}).(obj{j}).data.(sigs{k}));
                                % Initialize an index so each result goes
                                % to a different cell.
                                indMeas = 1;
                                % Iterate through the measures.
                                for ii = 1:length(meas)
                                    % If the current measure is selected,
                                    % or nothing was selected, or 'all' was
                                    % selected.
                                    if (any(strcmp(app.MeasureListBox.Value, meas{ii})) || isempty(app.MeasureListBox.Value) || any(strcmp(app.MeasureListBox.Value, 'all')))
                                        % Only the single-value results
                                        % will be plotted. Some are arrays
                                        % or characters.
                                        if numel(data.res.RQA.(files{i}).(obj{j}).data.(sigs{k}).(meas{ii})) == 1 && ~strcmp(meas{ii}, 'RQAresults')
                                            % Save the titles for the
                                            % plots.
                                            titleMeas{indMeas} = meas{ii};
                                            plotData{indMeas}(ind, 1) = data.res.RQA.(files{i}).(obj{j}).data.(sigs{k}).(meas{ii});
                                            indMeas = indMeas + 1;
                                        end
                                    end
                                end
                                ind = ind + 1;
                            end
                        end
                    end
                end
            end
        end
    end
end

% The total number of rows for the subplots.
n = ceil(length(titleMeas)/2) + 3;
% The number of columns for the subplots.
m = 6;

% An invisible figure will be created and then copied into the app. This allows it to be printed or used elsewhere.
H = figure('visible', 'off');
% Create an temporary axis location for the main binary plot.
a0 = subplot(n, m, [2, 3, 8, 9]);
ax(1) = axes('Parent',H,'Position', a0.Position, 'FontSize', 8);
% Display the binary plot in the temporary axis.
imagesc(ax(1), recurrencePlot.rp);
colormap(ax(1), gray);
xlabel('X(i)','Interpreter','none', 'FontSize', 10);
ylabel('Y(j)','Interpreter','none', 'FontSize', 10);
title('Binary')
set(gca,'XTick',[ ]);
set(gca,'YTick',[ ]);
% Create more temporary axes for the x and y axis plots.
a1 = subplot(n, m, [1, 7]);
a2 = subplot(n, m, [14, 15]);
% Create the x and y axis plots based on what type of RQA was performed.
switch upper(type)
    case {'RQA','MDRQA','MD','MULTI'}
        ax(2) = axes('Parent',H,'Position', a2.Position, 'FontSize', 8);
        plot(1:length(dataRQA(:,1)), dataRQA(:,1), 'k-');
        xlim([1 length(dataRQA(:,1))]);
        ax(3) = axes('Parent',H,'Position', a1.Position, 'FontSize', 8);
        plot(flip(dataRQA(:,1)), 1:length(dataRQA(:,1)), 'k-');
        ylim([1 length(dataRQA(:,1))]);
        set (ax(3),'Ydir','reverse');
    case {'CRQA','CROSS'}
        ax(2) = axes('Parent',H,'Position', a2.Position, 'FontSize', 8);
        plot(1:length(dataRQA(:,1)), dataRQA(:,1), 'k-');
        xlim([1 length(dataRQA(:,1))]);
        ax(3) = axes('Parent',H,'Position', a1.Position, 'FontSize', 8);
        plot(flip(dataRQA(:,2)), 1:length(dataRQA(:,2)), 'k-');
        ylim([1 length(dataRQA(:,1))]);
        set (ax(3),'Ydir','reverse');
    case {'JRQA','JOINT'}
        for i = 1:c
            ax(2) = axes('Parent',H,'Position', a2.Position, 'FontSize', 8);
            plot(1:length(dataRQA(:,1)), dataRQA(:,i),'k-');
            xlim([1 length(dataRQA(:,1))]);
            ax(3) = axes('Parent',H,'Position', a1.Position, 'FontSize', 8);
            plot(flip(dataRQA(:,1)), 1:length(dataRQA(:,i)),'k-');
            ylim([1 length(dataRQA(:,1))]);
            set (ax(3),'Ydir','reverse');
        end
end

% Create an temporary axis location for the main binary plot.
a3 = subplot(n, m, [5, 6, 11, 12]);
ax(4) = axes('Parent',H,'Position', a3.Position, 'FontSize', 8);
% Display the binary plot in the temporary axis.
imagesc(ax(4), -recurrencePlot.wrp);
xlabel('X(i)','Interpreter','none', 'FontSize', 10);
ylabel('Y(j)','Interpreter','none', 'FontSize', 10);
title('Weighted')
set(gca,'XTick',[ ]);
set(gca,'YTick',[ ]);
% Create more temporary axes for the x and y axis plots.
a4 = subplot(n, m, [4, 10]);
a5 = subplot(n, m, [17, 18]);
% Create the x and y axis plots based on what type of RQA was performed.
switch upper(type)
    case {'RQA','MDRQA','MD','MULTI'}
        ax(5) = axes('Parent',H,'Position',a5.Position, 'FontSize', 8);
        plot(1:length(dataRQA(:,1)), dataRQA(:,1), 'k-');
        xlim([1 length(dataRQA(:,1))]);
        ax(6) = axes('Parent',H,'Position',a4.Position, 'FontSize', 8);
        plot(flip(dataRQA(:,1)), 1:length(dataRQA(:,1)), 'k-');
        ylim([1 length(dataRQA(:,1))]);
        set (ax(6),'Ydir','reverse');
    case {'CRQA','CROSS'}
        ax(5) = axes('Parent',H,'Position',a5.Position, 'FontSize', 8);
        plot(1:length(dataRQA(:,1)), dataRQA(:,1), 'k-');
        xlim([1 length(dataRQA(:,1))]);
        ax(6) = axes('Parent',H,'Position',a4.Position, 'FontSize', 8);
        plot(flip(dataRQA(:,2)), 1:length(dataRQA(:,2)), 'k-');
        ylim([1 length(dataRQA(:,1))]);
        set (ax(6),'Ydir','reverse');
    case {'JRQA','JOINT'}
        for i = 1:c
            ax(5) = axes('Parent',H,'Position',a5.Position, 'FontSize', 8);
            plot(1:length(dataRQA(:,1)), dataRQA(:,i),'k-');
            xlim([1 length(dataRQA(:,1))]);
            ax(6) = axes('Parent',H,'Position',a4.Position, 'FontSize', 8);
            plot(flip(dataRQA(:,1)), 1:length(dataRQA(:,i)),'k-');
            ylim([1 length(dataRQA(:,1))]);
            set (ax(6),'Ydir','reverse');
        end
end

% Link the axis so zooming in on one does the same on all of them.
linkaxes(ax([1,4]),'xy');
linkaxes(ax([1,2,4,5]),'x');
linkaxes(ax([1,3,4,6]),'y');

% Delete the temporary axes.
delete([a0, a1, a2, a3, a4, a5])

% Create the subplots for the results.
for i = 1:length(titleMeas)
    % If only one result was selected create one large subplot.
    if n == 4
        subplot(n, m, [i + 18:i + 23])
    else
        % If there were multiple selections create two columns of subplots.
        subplot(n, m, [(i - 1)*3 + 1 + 18:(i - 1)*3 + 3 + 18])
    end
    % Create the histogram.
    histogram(plotData{i}, 'FaceColor', 'k');
    xlabel('Bins')
    ylabel('Count')
    title(regexprep(titleMeas{i}, '_', ' '))

end