function app = analysis_Custom(app, data, analysis)
% app = analysis_custom(app, data, analysis)
% inputs  - app, the BAR App object.
%         - data, the data structure loaded into the BAR App.
%         - analysis, a string stating the type of analysis being
%                     performed.
% outputs - app, the BAR App is returned as an output.
% Remarks
% - This code is written as an example script for analyzing data through 
%   the BAR App. This is the simplier example compared to a MATLAB App.
% - Having the BAR App as an input does allow callbacks from the app to be
%   used within this script. The printLog and analysisComplete methods from
%   the BAR App are used in this example.
% - This script is provided as an example. It will need to be edited before
%   being used.
% Future Work
% - As an example there is nothing of note.
% Nov 2022 - Created by Ben Senderling, bsender@bu.edu
%% Begin Code

% Get all the file names from the data. This uses the raw data.
files = fieldnames(data.raw);

% This example will only iterate through the files. One could also iterate
% through the objects and signals.
for i = 1:length(files)

    % Get the object names so they can be iterated through.
    objs = fieldnames(data.raw.(files{i}));
    % Remove the informational items.
    objs(strcmp(objs, 'groups')) = [];
    objs(strcmp(objs, 'meta')) = [];

    % Iterate through the objects.
    for j = 1:length(objs)

        % Often calculations will be performed on the signals. In that case
        % calculations would be performed here and the signals would not be
        % iterated through.

        % Perform some operation on the data.
        accelerationMagnitude = sqrt(sum(data.raw.(files{i}).(objs{j}).data.acc.^2, 2));
        % Calculate a metric and store it as a result. This calculation
        % would produce a single number as a result.
        data.res.Custom.(files{i}).(objs{j}).data.acc.peakAcceleration = max(accelerationMagnitude);

        % Perform another operation on the data.
        heelStrikes = findHeelStrikes(data.raw.(files{i}).(objs{j}).data.heelMarker);
        % Calculate a metric using the sampling frequency and store it as a
        % result. This example would likely produce an array of results.
        data.res.Custom.(files{i}).(objs{j}).data.heelMarker.heelStrikes = heelStrikes/data.res.(files{i}).(objs{j}).freq;

        % In some cases the signals will be iterated through. The following
        % code is an example of how that would be handelled.

        % Get the signal names.
        sigs = fieldnames(data.raw.(files{i}).(objs{j}).data);

        % Iterate through the signal names.
        for k = 1:length(sigs)

            % Perform some operation on the data.
            accelerationMagnitude = sqrt(sum(data.raw.(files{i}).(objs{j}).data.(sigs{k}).^2, 2));
            % Calculate a metric and store it as a result. This calculation
            % would produce a single number as a result.
            % This example appends a string to the signal name. The string
            % could also be appended to the object name. This does change
            % how the results are plotting in the general review module and
            % how they are exported. During the export signal names appear
            % in the column headers while the object names appear in each
            % row.
            data.res.Custom.(files{i}).(objs{j}).data.(sigs{k}).peakAcceleration = max(accelerationMagnitude);
            
        end
    end

    % This code will print a message to the BAR App with the code's
    % progress. It will print a message every 10 files. It is a public
    % method so it can be called from outside the app.
    if rem(i, 10) == 0
        printLog(app, '024', [num2str(i) ' of ' num2str(length(files)) ' analyzed']);
    end

end

% This is a public method in the BAR App. It will return the data to the
% app and prompt to save it.
analysisComplete(app, data, analysis)

end