function H = figure_2D(plotData)
% H = figure_2D(plotData)
% inputs  - plotData, a specific structure from the BAR App with data to plot. Data is consists as a cell array of double arrays.
% outputs - H, figure that will be used by the BAR App to copy into the figure panel.
% Remarks
% - This function will create a 2D plot of data from the BAR App. Data is as the first cell as the x axis and the second cell as the y axis.
%   Additional cells are ignored.
% Future Work
% - None.
% Dec 2022 - Created by Ben Senderling, bsender@be.edu

% An invisible figure will be created and then copied into the app. This allows it to be printed or used elsewhere.
H = figure('visible', 'off');

% This will only be done if two items were selected.
if numel(plotData) >= 2
    % Create an axes object in the figure that will be used to copy it to the app.
    ax = axes('Parent', H);
    % Use the two dimensions to plot the data.
    plot(ax, plotData{1}, plotData{2}, 'k');
end

end