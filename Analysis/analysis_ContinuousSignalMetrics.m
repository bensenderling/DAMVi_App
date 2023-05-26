function app = analysis_ContinuousSignalMetrics(app, data, analysis)
% app = analysis_ContinuousSignalMetrics(app, data, analysis)
% inputs  - app, the BAR App object.
%         - data, the data structure loaded into the BAR App.
%         - analysis, a string stating the type of analysis being performed.
% outputs - app, the BAR App is returned as an output.
% Remarks
% - This code will calculate a number of signal metrics. Most of these are intended to be used for quality assurance, not as endpoints for an
%   analysis. The calculations are short and simple and new additions should also be. This code is intended to run quickly through many files and not
%   require intensive computer resources. More intense methods should get their own analysis method.
% - All of the raw and pro data in the structure is processed, but only the pro data if it is present in both.
% - For the various derivative that are calculated (velocity, acceleration, jerk) they are calculated per unit time if the sampling frequency is
%   found. Or they are calculated per N. The variable names changes between 'PerS' or 'PerN' accordingly.
% - Metrics calculated include:
%      Average                  Area                            Mean velocity
%      Mode                     N                               Maximum velocity
%      Median                   Number of bits (nBits)          Minimum velocity
%      Maximum                  Bit density (bitDensity)        Mean acceleration
%      Minimum                                                  Maximum acceleration
%      Range                                                    Minimum acceleration
%      Standard deviation                                       Mean jerk
%                                                               Maximum jerk
%                                                               Minimum jerk
% Future Work
% - There might be other measures that could be added.
% May 2023 - Created by Ben Senderling, bsender@bu.edu

types = {'pro', 'raw'};

for type = types
    % Get all the file names from the data.
    files = fieldnames(data.(type{1}));

    % Iterate through the files.
    for ind_files = 1:length(files)

        % Get the object names so they can be iterated through.
        objs = fieldnames(data.(type{1}).(files{ind_files}));
        % Remove the informational items.
        objs(strcmp(objs, 'groups')) = [];
        objs(strcmp(objs, 'meta')) = [];

        % Iterate through the objects.
        for obj = objs

            % Get the signal names.
            sigs = fieldnames(data.(type{1}).(files{ind_files}).(obj{1}).data);

            % Iterate through the signal names.
            for sig = sigs

                if ~(isfield(data, 'res') && isfield(data.res, 'CSM') && isfield(data.res.CSM, files{ind_files}) && isfield(data.res.CSM.(files{ind_files}), obj{1}) && isfield(data.res.CSM.(files{ind_files}).(obj{1}).data, sig{1}))

                    % Iterate through the dimensions of the signal.
                    for dim = 1:size(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1}), 2)

                        % Average
                        data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).average(1, dim) = mean(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim));
                        % Standard deviation
                        data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).std(1, dim) = std(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim));
                        % Median
                        data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).median(1, dim) = median(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim));
                        % Mode
                        data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).mode(1, dim) = mode(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim));
                        % Maximum
                        data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).maximum(1, dim) = max(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim));
                        % Minimum
                        data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).minimum(1, dim) = min(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim));
                        % Range
                        data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).range(1, dim) = max(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim)) - min(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim));
                        % Area
                        data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).area(1, dim) = sum(trapz(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim)));
                        % N
                        data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).n(1, dim) = length(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim));
                        % Number of bits
                        data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).nBits(1, dim) = length(unique(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim)));
                        % Bits per unit of signal
                        data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).bitDensity(1, dim) = length(unique(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim)))/(max(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim)) - min(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim)));
                        
                        if isfield(data.(type{1}).(files{ind_files}).(obj{1}), 'freq')
                            % These values are all per unit time.
                            % Pull the sampling frequency out so it is easier to reuse.
                            freq = data.(type{1}).(files{ind_files}).(obj{1}).freq;
                            % Mean velocity
                            data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).meanVelocityPerS(1, dim) = mean(diff(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim))*freq);
                            % Maximum velocity
                            data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).maxVelocityPerS(1, dim) = max(diff(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim))*freq);
                            % Minimum velocity
                            data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).minVelocityPerS(1, dim) = min(diff(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim))*freq);
                            % Mean acceleration
                            data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).meanAccelPerS(1, dim) = mean(diff(diff(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim))*freq)*freq);
                            % Maximum acceleration
                            data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).maxAccelPerS(1, dim) = max(diff(diff(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim))*freq)*freq);
                            % Minimum acceleration
                            data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).minAccelPerS(1, dim) = min(diff(diff(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim))*freq)*freq);
                            % Mean jerk
                            data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).meanJerkPerS(1, dim) = mean(diff(diff(diff(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim))*freq)*freq)*freq);
                            % Maximum jerk
                            data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).maxJerkPerS(1, dim) = max(diff(diff(diff(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim))*freq)*freq)*freq);
                            % Minimum jerk
                            data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).minJerkPerS(1, dim) = min(diff(diff(diff(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim))*freq)*freq)*freq);
                        else
                            % These values are all per sample.
                            % Pull the number of samples out so it is easier to reuse.
                            N = length(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim));
                            % Mean velocity
                            data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).meanVelocityPerN(1, dim) = mean(diff(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim))*N);
                            % Maximum velocity
                            data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).maxVelocityPerN(1, dim) = max(diff(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim))*N);
                            % Minimum velocity
                            data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).minVelocityPerN(1, dim) = min(diff(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim))*N);
                            % Mean acceleration
                            data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).meanAccelPerN(1, dim) = mean(diff(diff(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim))*N)*N);
                            % Maximum acceleration
                            data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).maxAccelPerN(1, dim) = man(diff(diff(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim))*N)*N);
                            % Minimum acceleration
                            data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).minAccelPerN(1, dim) = min(diff(diff(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim))*N)*N);
                            % Mean jerk
                            data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).meanJerkPerN(1, dim) = mean(diff(diff(diff(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim))*N)*N)*N);
                            % Maximum jerk
                            data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).maxJerkPerN(1, dim) = man(diff(diff(diff(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim))*N)*N)*N);
                            % Minimum jerk
                            data.res.CSM.(files{ind_files}).(obj{1}).data.(sig{1}).minJerkPerN(1, dim) = min(diff(diff(diff(data.(type{1}).(files{ind_files}).(obj{1}).data.(sig{1})(:, dim))*N)*N)*N);
                        end


                    end
                end
            end
        end

        % This code will print a message to the BAR App with the code's progress. It will print a message every 10 files. It is a public method so it 
        % can be called from outside the app.
        if rem(ind_files, 10) == 0
            printLog(app, '024', [type{1} ': ' num2str(ind_files) ' of ' num2str(length(files)) ' analyzed']);
        end

    end
end

    % This is a public method in the BAR App. It will return the data to the app and prompt to save it.
    analysisComplete(app, data, analysis, 0)

end