function H = figure_Image(plotData)
% figure_Image(plotData)
% inputs  - plotData, a specific structure from the BAR App with data to plot. Data is consists as a cell array of double arrays.
% outputs - H, figure that will be used by the BAR App to copy into the figure panel.
% Remarks
% - This function will create an image from the plotData. Multiple images are shown as subplots. This is best used to view 1-4 images at a time as
%   they are not currenly sized well.
% Future Work
% - The images do not make great use of the blank space in the figure. This results in the images becoming much smaller as additional subplots are
% added.
% Dec 2022 - Created by Ben Senderling, bsender@be.edu
%% Begin Code

% An invisible figure will be created and then copied into the app. This allows it to be printed or used elsewhere.
H = figure('visible', 'off');

% If there is only one image.
if length(plotData) == 1
    % Create an axes object in the figure that will be used to copy it to the app.
    ax = axes('Parent', H);
    % Display the image.
    imshow(plotData{1}, 'Border','tight', 'Interpolation', 'bilinear');
    % Copy the axes object to the app.
else
    % If multiple images were selected they will be shown in two columns with N rows.
    N = ceil(length(plotData)/2);
    for i = 1:length(plotData)
        % Create an axes object in the figure that will be used to copy it to the app.
        ax(i) = subplot(N,2,i);
        % Display the image.
        imshow(plotData{i}, 'Border','tight', 'Interpolation', 'bilinear')
        % Copy the axes object to the app.
    end
end

end