function app = analysis_QST(app, data, analysis)
% app = analysis_QST(app, data, analysis)
% inputs  - app, required mlapp object.
%         - data, BAR App data structure.
%         - analysis, string of the analysis type.
% Remarks
% - This analysis script will process QST data recorded through Medoc software. The analysis is fairly specific to research methods performed at the
%   MU MoveLab. It assumes that pressure was applied through an algometer using Medoc software.
% - The code will calculate a number of results such as:
%   - sequenceN, the sequence number from the Medoc test.
%   - trialN, the trial number from the trial test.
%   - valuePeak, this is the highest pressure delivered.
%   - valueEvent, this is the instantaneous pressure at a button press.
%   - rSquaredAdjusted, This the adjusted R squared value of a linear fit to the line of pressure versus time.
%   - slope, This is the slope of pressure application versus time.
% Future Work
% - Potentially if additional tests are performed in Medoc this same analysis method could be updated to analyze them.
% Nov 2022 - Created by Ben Senderling, bsender@bu.edu
% Aug 2023 - Modified by Ben Senderling, bsender@bu.edu
%          - Modified the figure titles so '_' is interpreted as a '_' instead of lower case.
%          - Changed the quality measures to estimate the linear model up to the peak or the button press so the data past it does not
%            give false estimate of low quality data.
%          - The figures will now be saved to a subfolder in the Figure folder. They will also be named using the group information if
%            a full file path (found by looking for a :) is not present. If a : is found it is assumed to be a full file path and the
%            generic file#### name is used to name the file.
%% Begin Code

% Get the file names.
files = fieldnames(data.raw);
% Start iterating through them.
for i = 1:length(files)
    % Get the object names.
    obj = fieldnames(data.raw.(files{i}));
    % Remove the informaitonal fields.
    obj(strcmp(obj, 'meta')) = [];
    obj(strcmp(obj, 'groups')) = [];

    % Create a figure and set the position to the size of the screen.
    H = figure('visible', 'off');
    H.Units = 'Normalized';
    H.Position = [0 0 1 1];

    % Get the sequence and the trial numbers so they can be used in the plots latter.
    sequenceN = zeros(length(obj), 1);
    trialN = zeros(length(obj), 1);
    for j = 1:length(obj)
        % They'll need to be converted from strings to doubles.
        sequenceN(j) = str2double(obj{j}(9));
        trialN(j) = str2double(obj{j}(end));
    end

    % Iterate through all the objects.
    for j = 1:length(obj)

        % The sequence and the trial number will be put into the results
        data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.sequenceN = sequenceN(j);
        data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.trialN = trialN(j);

        % Pull a number of fields from the raw file and add it to the results so they should up in the DAMVi export.
        if isfield(data.raw.(files{i}).meta, 'Program')
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.Program = data.raw.(files{i}).meta.Program;
        else
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.Program = 'Undefined';
        end
        if isfield(data.raw.(files{i}).meta, 'Body_Site_Main')
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.Body_Site_Main = data.raw.(files{i}).meta.Body_Site_Main;
        else
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.Body_Site_Main = 'Undefined';
        end
        if isfield(data.raw.(files{i}).meta, 'Body_Site_Side')
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.Body_Site_Side = data.raw.(files{i}).meta.Body_Site_Side;
        else
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.Body_Site_Side = 'Undefined';
        end
        if isfield(data.raw.(files{i}).meta, 'Body_Site_Specific')
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.Body_Site_Specific = data.raw.(files{i}).meta.Body_Site_Specific;
        else
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.Body_Site_Specific = 'Undefined';
        end
        if isfield(data.raw.(files{i}).meta, 'ID')
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.ID = data.raw.(files{i}).meta.ID;
        else
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.ID = 'Undefined';
        end
        if isfield(data.raw.(files{i}).meta, 'Department')
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.Department = data.raw.(files{i}).meta.Department;
        else
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.Department = 'Undefined';
        end
        if isfield(data.raw.(files{i}).meta, 'Last_Name')
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.Last_Name = data.raw.(files{i}).meta.Last_Name;
        else
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.Last_Name = 'Undefined';
        end
        if isfield(data.raw.(files{i}).meta, 'First_Name')
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.First_Name = data.raw.(files{i}).meta.First_Name;
        else
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.First_Name = 'Undefined';
        end
        if isfield(data.raw.(files{i}).meta, 'Project')
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.Project = data.raw.(files{i}).meta.Project;
        else
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.Project = 'Undefined';
        end
        if isfield(data.raw.(files{i}).meta, 'Participant_ID')
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.Particpant_ID = data.raw.(files{i}).meta.Participant_ID;
        else
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.Participant_ID = 'Undefined';
        end
        if isfield(data.raw.(files{i}).meta, 'Operator')
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.Operator = data.raw.(files{i}).meta.Operator;
        else
            data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.Operator = 'Undefined';
        end
        
        
        % Find the maximum pressure delivered and save it in the results.
        [m, I] = max(data.raw.(files{i}).(obj{j}).data.Pressure_kPa_);
        data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.valuePeak = m;

        % Find any event registered by the software.
        I2 = find(data.raw.(files{i}).(obj{j}).data.Event);
        % Use the event index to save the instantaneous pressure to the results.
        data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.valueEvent = data.raw.(files{i}).(obj{j}).data.Pressure_kPa_(I2);
        
        % Fit a linear model to the data. Data after the maximum or after the button press are ignored.
        if I <= I2
            lm = fitlm(data.raw.(files{i}).(obj{j}).data.Timestamp_msec_(1:I)/1000,data.raw.(files{i}).(obj{j}).data.Pressure_kPa_(1:I));
        elseif I > I2
            lm = fitlm(data.raw.(files{i}).(obj{j}).data.Timestamp_msec_(1:I2)/1000,data.raw.(files{i}).(obj{j}).data.Pressure_kPa_(1:I2));
        end
        % The Adjusted R Squared is saved.
        data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.rSquaredAdjusted = lm.Rsquared.Adjusted;
        % The slope of the linear model is saved.
        data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.slope = lm.Coefficients.Estimate(2);

        % Add the comments to the results so they are exported.
        data.res.QST.(files{i}).(obj{j}).data.Pressure_kPa_.comments = data.raw.(files{i}).meta.Comments;

        % Save the peaks so the y axis of all the plots can be made the same.
        y(j) = m;
        % Save the peak of the x axes so they can all be made the same latter.
        if ~isempty(I2)
            % Use the button event marker if it was found.
            x(j) = max(data.raw.(files{i}).(obj{j}).data.Timestamp_msec_(I2)/1000);
        else
            % Use the time of the maximum pressure.
            x(j) = data.raw.(files{i}).(obj{j}).data.Timestamp_msec_(I)/1000;
        end

        % The sequences will be used as the rows and the trials as the columns. This was chosen based on the intended use of the software.
        subplot(max(sequenceN), max(trialN), j)
        hold on
        % Create a fill to highlight the target rate of pressure application and the boundaries.
        fill([0.01;1;20;20;19;0.01;0.01], [0.01;0.01;19;20;20;1;0.01], [0.9, 0.9, 0.9], 'EdgeColor', 'none')
        % Create a line to mark the exact intended rate.
        plot([0;10], [0;10], 'k:')
        % Draw the data.
        plot(data.raw.(files{i}).(obj{j}).data.Timestamp_msec_/1000, data.raw.(files{i}).(obj{j}).data.Pressure_kPa_, 'k')
        % Draw a vertical line for the maximum.
        plot([0; data.raw.(files{i}).(obj{j}).data.Timestamp_msec_(I)/1000], [m; m], 'k--')
        % Draw a horizontal line for the event pressure.
        if ~isempty(I2)
            plot([data.raw.(files{i}).(obj{j}).data.Timestamp_msec_(I2)/1000; data.raw.(files{i}).(obj{j}).data.Timestamp_msec_(I2)/1000], [0; data.raw.(files{i}).(obj{j}).data.Pressure_kPa_(I2)], 'k-.')
        end
        hold off
        xlabel('Time (s)')
        ylabel('Pressure (kPa)')
        title(regexprep(obj{j}, '_', '\\_'))
        
    end

    % Iterate through all the objects again and make the axes the same.
    for j = 1:length(obj)
        subplot(max(sequenceN), max(trialN), j)
        xlim([0, max(x)])
        ylim([0, max(y)])
    end

    % Save the figure and close it.
    if any(contains(data.raw.(files{i}).groups, ':'))
        name = files{i};
    else
        name = strjoin(data.raw.(files{i}).groups, '_');
    end
    folders = dir([app.Database.Value '\Figures']);
    if ~any(strcmp({folders.name}, 'QST'))
        mkdir([app.Database.Value '\Figures\QST'])
    end
    saveas(H, [app.Database.Value '\Figures\QST\' name '.jpg'])
    close(H)

    % A message will be printed to the main BAR App every 10 files.
    if rem(i, 10) == 0
        app.printLog('024', [num2str(i) ' of ' num2str(length(files)) ' analyzed']);
    end

end

% Run the public BAR App analysisComplete method to get the data back into the app.
analysisComplete(app, data, analysis, 0)

end