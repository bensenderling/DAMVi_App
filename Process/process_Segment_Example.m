function x_segmented = process_Segment_Example(app, x, sel)
% x_segmented = process_Segment_Example(x, sel)
% inputs  - x, the object to segment. It can be a portion or the entirety of the data structure from the BAR App.
%         - sel, the type of selection from the BAR App. Can be timeseries, file or all.
% outputs - dataout, structure containing file from V3D text file
% Remarks
% - This is an example segment mini-module. The main function handles the input data. This is treated differently depending on if the selection is a
%   file, object or time series. However, the code is very similar. The code to do the segmentation is a subroutine located at the bottom of the
%   script. It is likely that data may be segmented using a specific signal, or a combination of signals. Hopefully, that would require code to be
%   removed from this script and not added.
% Future Work
% - Since this code is used in multiple instances it could potentialy be combined into the segment module. The segmentation code itself would become
%   the mini-module.
% - This code here is repeated a lot within this script. It may be better to iterate through everything and segment the level that matches the chossen
%   one. The switch-case would then be at the deeper in the for loops instead of being outside all of them.
% Dec 2022 - Created by Ben Senderling, bsender@be.edu

switch sel

    % For time series selections.
    case 'timeseries'

        % Perform the segmentation. The subroutine allows the same code to
        % be used at different levels.
        ind = segment(x);

        % If no segments were found send an error code back to the BAR App and exit the script. This can also be used for an invalid selection and not
        % a failure to segment. For example segmenting IMU data may require accelerometer, gyroscope and magnetometer data. Selecting an individual
        % signal/time series would allow it to be segmented.
        if any(isnan(ind), 'all')
            x = '004';
            return
        end

        % The raw data will be plotted in the Segmentation Module.
        x_segmented.raw = x;

        % Iterate through the segment indexes.
        for k = 1:size(ind,1) + 1

            % This if statement is used to make the turn numbers a
            % consistent 2 character length as strings.
            if k < 1000
                k_string = num2str(k);
            elseif k < 100
                k_string = ['00' num2str(k)];
            elseif k < 10
                k_string = ['0' num2str(k)];
            else
                k_string = num2str(k);
            end

            % The first segment of data is from the beggining to
            % the first index.
            if k == 1
                frame_start = 1;
                frame_end = ind(k, 1);
                % The last turn is from the last index to the end of
                % the data.
            elseif k == size(ind,1) + 1
                frame_start = ind(k - 1, 2);
                frame_end = size(x, 1);
                % The middle segments are from the end index of the
                % previous turn to the start index of the current turn.
            else
                frame_start = ind(k - 1, 2);
                frame_end = ind(k, 1);
            end
            % Set the segment to the processed level of the BAR App
            % data structure.
            x_segmented.pro{k} = x(frame_start:frame_end, :);

            % Create results from the turn information.
            x_segmented.res.(['Segment']).(['turn' k_string]).data.startFrame = frame_start;
            x_segmented.res.(['Segment']).(['turn' k_string]).data.endFrame = frame_end;

        end

    case 'object'

        % Get the signals from the object level.
        sigs = fieldnames(x.data);
        for j = 1:length(sigs)

            % Perform the segmentation.
            ind = segment(x.data.(sigs{j}));

            % The raw data will be plotted in the Segmentation Module.
            x_segmented.raw.(sigs{j}) = x.data.(sigs{j});

            % Iterate through the segment indexes.
            for k = 1:size(ind,1) + 1

                % This if statement is used to make the turn numbers a
                % consistent 2 character length as strings.
                if k < 1000
                    k_string = num2str(k);
                elseif k < 100
                    k_string = ['00' num2str(k)];
                elseif k < 10
                    k_string = ['0' num2str(k)];
                else
                    k_string = num2str(k);
                end

                % The first segment of data is from the beggining to
                % the first index.
                if k == 1
                    frame_start = 1;
                    frame_end = ind(k, 1);
                    % The last turn is from the last index to the end of
                    % the data.
                elseif k == size(ind,1) + 1
                    frame_start = ind(k - 1, 2);
                    frame_end = length(x.data.(sigs{j}));
                    % The middle segments are from the end index of the
                    % previous turn to the start index of the current turn.
                else
                    frame_start = ind(k - 1, 2);
                    frame_end = ind(k, 1);
                end
                % Set the segment to the processed level of the BAR App
                % data structure.
                x_segmented.pro.([sigs{j} '_' k_string]) = x.data.(sigs{j})(frame_start:frame_end, :);

                % Create results from the turn information.
                x_segmented.res.([sigs{j} '_' k_string]).data.startFrame = frame_start;
                x_segmented.res.([sigs{j} '_' k_string]).data.endFrame = frame_end;
            end
        end

        % For the file level selections.
    case 'file'

        % Only one object will be segmented in this example.
        objs = fieldnames(x);

        % Remove the groups and meta data.
        objs(strcmp(objs, 'groups')) = [];
        objs(strcmp(objs, 'meta')) = [];

        % The different objects will be iterated through but only one is
        % used to create the segments.
        for j = 1:length(objs)

            % Only one signal will be segmented in this example.
            sigs = fieldnames(x.(objs{j}).data);

            for ii = 1:length(sigs)

                % Data from a signal will be segmented and used to plot in the Segmentation Module.
                x_segmented.raw.(objs{j}).data.(sigs{ii}) = x.(objs{j}).data.(sigs{ii});

                % Perform the segmentation. The subroutine allows the same code to
                % be used at different levels.
                ind = segment(x.(objs{j}).data.(sigs{ii}));

                % Iterate through the segment indexes.
                for k = 1:size(ind,1) + 1

                    % This if statement is used to make the turn numbers a
                    % consistent 2 character length as strings.
                    if k < 1000
                        k_string = num2str(k);
                    elseif k < 100
                        k_string = ['00' num2str(k)];
                    elseif k < 10
                        k_string = ['0' num2str(k)];
                    else
                        k_string = num2str(k);
                    end

                    % The first segment of data is from the beggining to
                    % the first index.
                    if k == 1
                        frame_start = 1;
                        frame_end = ind(k, 1);
                        % The last turn is from the last index to the end of
                        % the data.
                    elseif k == size(ind,1) + 1
                        frame_start = ind(k - 1, 2);
                        frame_end = length(x.(objs{j}).data.(sigs{ii}));
                        % The middle segments are from the end index of the
                        % previous turn to the start index of the current turn.
                    else
                        frame_start = ind(k - 1, 2);
                        frame_end = ind(k, 1);
                    end
                    % Set the segment to the processed level of the BAR App
                    % data structure.
                    x_segmented.pro.(objs{j}).data.([sigs{ii} '_' k_string]) = x.(objs{j}).data.(sigs{ii})(frame_start:frame_end, :);

                    % Create results from the turn information.
                    x_segmented.res.(objs{j}).data.([sigs{ii} '_' k_string]).startFrame = frame_start;
                    x_segmented.res.(objs{j}).data.([sigs{ii} '_' k_string]).endFrame = frame_end;
                end
            end
        end

    case 'all'

        % We need to know if it's raw or processed data being segmented.
        switch app.Switch.Value
            case 'Raw'
                type = 'raw';
            case 'Processed'
                type = 'pro';
        end

        x_segmented = x;

        % Get the file names so they can be iterated through.
        files = fieldnames(x.(type));
        for i = 1:length(files)

            % The segmentation in this example if for a particular object and signal within each file.

            % The objects will be segmented later on but are pulled now.
            objs = fieldnames(x.(type).(files{i}));

            % Remove the groups and meta data.
            objs(strcmp(objs, 'groups')) = [];
            objs(strcmp(objs, 'meta')) = [];

            % Each of the objects/IMU data will be segmented.
            for j = 1:length(objs)
                % If the sampling frequency is present it is carried over.
                if isfield(x.(type).(files{i}).(objs{j}), 'freq')
                    x_segmented.pro.(files{i}).(objs{j}).freq = x.(type).(files{i}).(objs{j}).freq;
                end
                % Iterate through all of the signals and segment them.
                sigs = fieldnames(x.(type).(files{i}).(objs{j}).data);
                for ii = 1:length(sigs)

                    % Run the segmentation code.
                    ind = segment(x.(type).(files{i}).(objs{j}).data.(sigs{ii}));

                    % Create NaN results if no turns were found.
                    if any(isnan(ind))
                        continue
                    end

                    % For each of the detected turns.
                    for k = 0:size(ind,1)

                        % This if statement is used to make the turn numbers a
                        % consistent 2 character length as strings.
                        if k < 1000
                            k_string = num2str(k);
                        elseif k < 100
                            k_string = ['00' num2str(k)];
                        elseif k < 10
                            k_string = ['0' num2str(k)];
                        else
                            k_string = num2str(k);
                        end

                        % The first segment of data is from the beggining to the first index.
                        if k == 0
                            frame_start = 1;
                            frame_end = ind(k + 1, 1);
                            % The last turn is from the last index to the end of the data.
                        elseif k == size(ind, 1)
                            frame_start = ind(k, 2);
                            frame_end = length(x.(type).(files{i}).(objs{j}).data.(sigs{ii}));
                        else
                            frame_start = ind(k, 2);
                            frame_end = ind(k + 1, 1);
                        end

                        % Create the segment.
                        x_segmented.pro.(files{i}).(objs{j}).data.([sigs{ii} '_' k_string]) = x.(type).(files{i}).(objs{j}).data.(sigs{ii})(frame_start:frame_end, :);
                        % Create the turn analysis results.
                        x_segmented.res.Segment.(files{i}).(objs{j}).data.([sigs{ii} '_turn' k_string]).startFrame = frame_start;
                        x_segmented.res.Segment.(files{i}).(objs{j}).data.([sigs{ii} '_turn' k_string]).startTime = frame_start/x.(type).(files{i}).(objs{j}).freq;
                        x_segmented.res.Segment.(files{i}).(objs{j}).data.([sigs{ii} '_turn' k_string]).endFrame = frame_end;
                        x_segmented.res.Segment.(files{i}).(objs{j}).data.([sigs{ii} '_turn' k_string]).endTime = frame_end/x.(type).(files{i}).(objs{j}).freq;
                        x_segmented.res.Segment.(files{i}).(objs{j}).data.([sigs{ii} '_turn' k_string]).duration_frame = frame_end - frame_start;
                        x_segmented.res.Segment.(files{i}).(objs{j}).data.([sigs{ii} '_turn' k_string]).duration_time = (frame_end - frame_start)/x.(type).(files{i}).(objs{j}).freq;
                    end
                end
            end
        end
end
end

function ind = segment(x)
% ind_Turn = segment(imu)
% inputs  - imu, the object to segment.
% outputs - ind_Turn, start and end indexes of the turns.
% Remarks
% - This function uses results from APDM's processing the segment Lumbar
%   sensor data.
% Future Work
% - None.
% Dec 2022 - Created by Ben Senderling, bsender@be.edu

% This is some example code that will create three segments.
ind = [floor(length(x)/3), floor(length(x)/3) + 1;...
    floor(2*length(x)/3), floor(2*length(x)/3) + 1;...
    ];

end