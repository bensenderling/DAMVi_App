function H = figure_1D(plotData)
% H = figure_1D(plotData)
% inputs  - plotData, a specific structure from the BAR App with data to plot. Data is consists as a cell array of double arrays.
% outputs - H, figure that will be used by the BAR App to copy into the figure panel.
% Remarks
% - This function will create a 1D plot of data from the BAR App. Data is plotted as a line graph verses the data's index. Each cell is ploted on the
%   same figure.
% Future Work
% - Potentially the different cells could be plotted as subplots or with
%   different colors.
% Dec 2022 - Created by Ben Senderling, bsender@be.edu

% An invisible figure will be created and then copied into the app. This allows it to be printed or used elsewhere.
H = figure('visible', 'off');

% Create an axes object in the figure that will be used to copy it to the app.
ax = axes('Parent', H);
% For 1D plots additional dimensions are all plotted on the same axis.
for i = 1:length(plotData)
    % This will plot the very large array, for one dimension, in one line.
    plot(ax, plotData{i}, 'k');
    % Set hold on if it is the first dimension.
    if i == 1
        hold('on')
    end
    % Turn of hold and tighten the axis after the lines are drawn.
    if i == length(plotData)
        hold('off')
        axis('tight')
    end
end

end