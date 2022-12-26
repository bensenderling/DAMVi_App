function H = figure_3D(plotData)
% H = figure_3D(plotData)
% inputs  - plotData, a specific structure from the BAR App with data to plot. Data is consists as a cell array of double arrays.
% outputs - H, figure that will be used by the BAR App to copy into the figure panel.
% Remarks
% - This function will create a 32D plot of data from the BAR App. Data from the first three cells are used as the x, y and z axes.
% Future Work
% - None.
% Dec 2022 - Created by Ben Senderling, bsender@be.edu

% An invisible figure will be created and then copied into the app. This allows it to be printed or used elsewhere.
H = figure('visible', 'off');

% This will only be done if three items were selected.
if numel(plotData) >= 3
    % Create an axes object in the figure that will be used to copy it to the app.
    ax = axes('Parent', H);
    % Use the first three axes to create the plot.
    plot3(ax, plotData{1}, plotData{2}, plotData{3}, 'k');
    % Copy the axes object to the app.
end

end