function H = figure_Histogram(plotData)
% H = figure_Histogram(plotData)
% inputs  - plotData, a specific structure from the BAR App with data to plot. Data is consists as a cell array of double arrays.
% outputs - H, figure that will be used by the BAR App to copy into the figure panel.
% Remarks
% - This function will create a histogram of data from the BAR App. Data in multiple cells are plotted as separate distributions.
% Future Work
% - Code could be added to plot the data with the same bin sizes.
% Dec 2022 - Created by Ben Senderling, bsender@be.edu

% An invisible figure will be created and then copied into the app. This allows it to be printed or used elsewhere.
H = figure('visible', 'off');

% Create an axes object in the figure that will be used to copy it to the app.
ax = axes('Parent', H);
% If multiple dimensions were selected they will be plotted separately.
for i = 1:length(plotData)
    % Display the histogram.
    histogram(ax, plotData{i}, 'FaceColor', 'k');
    % For the first plot hold on.
    if i == 1
        hold('on')
    end
    % For the last iteration hold off and tighten the axes.
    if i == length(plotData)
        hold('off')
        axis('tight')
    end
end

xlabel('Bins')
ylabel('Count')

end