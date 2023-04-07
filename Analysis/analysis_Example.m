function app = analysis_Example(app, data, analysis)
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

% For the example the processed data will be run. This makes sure people are stepping through the guide in the user manual.
type = 'pro';

% Get all the file names from the data. This uses the raw data.
files = fieldnames(data.(type));

% This example will only iterate through the files. One could also iterate
% through the objects and signals.
for i = 1:length(files)

    % Get the object names so they can be iterated through.
    objs = fieldnames(data.(type).(files{i}));
    % Remove the informational items.
    objs(strcmp(objs, 'groups')) = [];
    objs(strcmp(objs, 'meta')) = [];

    % Iterate through the objects.
    for j = 1:length(objs)

        % Often calculations will be performed on the signals. In that case
        % calculations would be performed here and the signals would not be
        % iterated through.

        % In some cases the signals will be iterated through. The following
        % code is an example of how that would be handelled.

        % Get the signal names.
        sigs = fieldnames(data.(type).(files{i}).(objs{j}).data);

        % Iterate through the signal names.
        for k = 1:length(sigs)

            % Perform some operation on the data.
            average = mean(data.(type).(files{i}).(objs{j}).data.(sigs{k}));
            % Calculate a metric and store it as a result. This calculation
            % would produce a single number as a result.
            % This example appends a measure to the signal.
            data.res.Custom.(files{i}).(objs{j}).data.(sigs{k}).mean = average;
            
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
analysisComplete(app, data, analysis, 0)

end