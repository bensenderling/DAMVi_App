function app = analysis_APDM(app, data, analysis)
% app = analysis_APDM(app, data, analysis)
% inputs  - app, the BAR App object.
%         - data, the data structure loaded into the BAR App.
%         - analysis, a string stating the type of analysis being
%                     performed.
% outputs - app, the BAR App is returned as an output.
% Remarks
% - This script will run a number of executables from APDM on h5 files. It
%   will match expected strings in the file names and directory path with
%   the specific executable that will be run.
% - File paths are not stored in their entirety within the BAR App but are
%   instead stored in pieces in the group object. This can not be processed
%   using the group processing within the BAR App for this script to be
%   successful. Once a file is loaded it's path is broken into group
%   information. This script will re-compile that group information.
% - The following are the expected strings in the filenames or directory
%   paths and the executable that will be run.
%   - Executable:
% Future Work
% - This script will need to be updated directly if changes are made to the
%   executables. This script has not been made adaptable because of the
%   very specific nature of the processing.
% Dec 2022 - Created by Ben Senderling
%% Begin Code

% Get the path to the executables.
pathExeRoot = mfilename('fullpath');
pathExeRoot = [pathExeRoot(1:strfind(pathExeRoot, '\Analysis')) 'Process\APDM\'];

% Get all the file names from the data. This uses the raw data.
files = fieldnames(data.raw);

% This example will only iterate through the files. One could also iterate
% through the objects and signals.
for i = 1:length(files)

    % The h5 files use the path to the original file.
    pathInput = data.raw.(files{i}).meta.Filename;
    % This assumes that group information has been processed to remove
    % extra entries and directory paths.
    if any(strcmp(data.raw.(files{i}).groups, 'R:'))
        app.printLog('029', analysis);
        return
    end
    pathOutput = [app.Database.Value '\Data\' strjoin(data.raw.(files{i}).groups, '_') '_Analysis.h5'];

    if any(contains(data.raw.(files{i}).groups, 'w')) || any(contains(data.raw.(files{i}).groups, 'fw')) || any(contains(data.raw.(files{i}).groups, 'walk6m')) || any(contains(data.raw.(files{i}).groups, 'sct'))
        
        % Set the arguments for this option.
        if any(contains(data.raw.(files{i}).groups, 'opal8'))
            args = ' -k -t';
        else
            args = '';
        end
        
        % Set the path to the executable.
        pathExe = [pathExeRoot 'AnalyzeWalk.exe'];

    elseif any(contains(data.raw.(files{i}).groups, 'bal'))
        
        args = '';
        
        % Set the path to the executable.
        pathExe = [pathExeRoot 'AnalyzeSway.exe'];
        
    elseif any(contains(data.raw.(files{i}).groups, 'sts')) || any(contains(data.raw.(files{i}).groups, 's2s'))
        
        % Set the arguments for this option.
        if any(contains(data.raw.(files{i}).groups, 'opal8'))
            args = ' -k';
        else
            args = '';
        end

        % Set the path to the executable.
        pathExe = [pathExeRoot 'Analyze5xSitStand.exe'];
        
    elseif any(contains(data.raw.(files{i}).groups, 'gait'))

        % Set the arguments for this option.
        args = '';

        % Run the AnalyzeSAW executable.
        pathExe = [pathExeRoot 'AnalyzeSAW.exe'];
    else
        
        % Set the arguments for this option.
        if any(contains(data.raw.(files{i}).groups, 'opal8'))
            args = ' -k -t';
        else
            args = '';
        end
        
        % Set the path to the executable.
        pathExe = [pathExeRoot 'AnalyzeWalk.exe'];
        
    end

    % Run the executable.
    out = system(['"' pathExe  '" -i "' pathInput '" -o "' pathOutput '"' args]);

    % Every 10 files print to the BAR App log.
    if rem(i, 10) == 0
        app.printLog('024', [num2str(i) ' of ' num2str(length(files)) ' analyzed']);
    end

end

analysisComplete(app, data, analysis)

end