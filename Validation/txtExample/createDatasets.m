function createDatasets
% createDatasets
% Remarks
% - This code creates example datasets to use with the BAR App. All the functions of the app should be able to run on these data.
% Future Work
% - As new capabilities are added this may need to be revised.
% Jan 2023 - Created by Ben Senderling, bsender@bu.edu

% TWo data sets will be created so the merge module can be tested.
sets = {'Set1', 'Set2'};

% The number of files that will be created for each data set.
N_files = 3;
% The number of objects that will be created for each file.
N_objects = 3;
% The number of signals that will be created for each object.
N_signals = 3;
% The total number of data points to create.
N_data = 100*N_signals*N_objects*N_files;
% The number of files to create with different dates.
N_dates = 3;

% Iterate through the data sets.
for ii = 1:length(sets)

    % Iterate through the files.
    for i = 1:N_files

        for jj = 1:N_dates

            % Create a file name. The underscores are used to check the grouping and merge modules.
            if jj < 10
                date1_File = ['2022010' num2str(jj)];
                date2_File = ['010' num2str(jj) '22'];
            elseif jj < 30
                date1_File = ['202201' num2str(jj)];
                date2_File = ['01' num2str(jj) '22'];
            else
                error('The number of dates must be below 30')
            end
            file{i} = ['C:\Users\bsender\OneDrive - Boston University\BU\Projects\001 BAR\Data\txtExample\example_' sets{ii} '_File' num2str(i) '_Duplicate' num2str(i) '_Duplicate' num2str(i) '_' date1_File '_' date2_File '_ObjectMatch' num2str(i + (jj - 1)*N_dates) '.txt'];
            % Open the file for writing.
            fid = fopen(file{i}, 'w');
            % Create an array of NaNs to hold the numerical data.
            data = NaN*ones(N_data, N_objects*N_signals);
            objectsN = 1:N_objects;
            ind2 = 1;
            % Iterate through the objects.
            while ~isempty(objectsN)
                ind = floor(rand(1)*length(objectsN)) + 1;
                j = objectsN(ind);
                % Iterate through the signals.
                for k = 1:N_signals
                    % Create the object header that is repeated for each signal. The underscore is used to test the grouping and merge modules.
                    objects{k + (ind2 - 1)*N_objects} = ['example_Object' num2str(j) '_Duplicate' num2str(j) '_Duplicate' num2str(j) '_ObjectMatch' num2str(j + (i - 1)*N_dates)];
                    % Create the signal header.
                    signals{k + (ind2 - 1)*N_objects} = ['exampleSignal' num2str(k)];
                    % The number of data points to create. Each signal has a different length.
                    n = 10*(k + (j - 1)*N_objects + (i - 1)*N_files);
                    % Create the data with different means plus noise.
                    data(1:n, k + (ind2 - 1)*N_objects) = (k + (j - 1)*N_signals + (i - 1)*N_objects*N_signals + (ii - 1)*N_files*N_objects*N_signals)*ones(n, 1) + 0.5*randn(n, 1);
                    % Multiple three sections of the data buy different numbers so the segmentation can be checked.
                    data(1:floor(n/3), k + (ind2 - 1)*N_objects) = data(1:floor(n/3), k + (ind2 - 1)*N_objects)*1;
                    data(floor(n/3) + 1:floor(2*n/3), k + (ind2 - 1)*N_objects) = data(floor(n/3) + 1:floor(2*n/3), k + (ind2 - 1)*N_objects)*10;
                    data(floor(2*n/3) + 1:end, k + (ind2 - 1)*N_objects) = data(floor(2*n/3) + 1:end, k + (ind2 - 1)*N_objects)*100;
                end
                ind2 = ind2 + 1;
                objectsN(ind) = [];
            end
            % Write the object header.
            fprintf(fid, '%s', strjoin(objects, ','));
            fprintf(fid, '\n');
            % Write the signal header.
            fprintf(fid, '%s', strjoin(signals, ','));
            fprintf(fid, '\n');
            % Write the numerical data.
            dlmwrite(file{i}, data, '-append')
            % Close the file.
            fclose(fid);

        end

    end

end