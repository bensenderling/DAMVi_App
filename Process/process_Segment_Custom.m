function x_segmented = process_Segment_Custom(app, x, sel)
% x_segmented = process_Segment_Custom(x, sel)
% inputs  - x, the object to segment. It can be a portion or the entirety of the data structure from the BAR App.
%         - sel, the type of selection from the BAR App. Can be timeseries, file or all.
% outputs - dataout, structure containing file from V3D text file
% Remarks
% - This is an example segment mini-module. The main function handles the input data. This is treated differently depending on if the selection is a
%   file, object or time series. The code to do the segmentation is a subroutine located at the bottom of the script.
% Future Work
% - Since this code is used in multiple instances it could potentialy be combined into the segment module. The segmentation code itself would become
%   the mini-module.
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
        if isnan(ind)
            x = '004';
            return
        end

        % Iterate through the segment indexes.
        for k = 1:size(ind,1) + 1

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
            x_segmented{k} = x(frame_start:frame_end, :);

        end

    case 'object'

        % Perform a calculation using the signals and then segment the data. This is only an example where the magnitude of a signal is calculated.
        signal = sqrt(sum(x.data.eul.^2, 2));

        % Perform the segmentation. The subroutine allows the same code to
        % be used at different levels.
        ind = segment(signal);

        % If no segments were found send an error code back to the BAR App and exit the script.
        if any(isnan(ind), 'all')
            x_segmented = '004';
            return
        end

        % Get the signals from the object level.
        sigs = fieldnames(x.data);
        for j = 1:length(sigs)

            % Data from a signal will be segmented and used to plot in the Segmentation Module.
            x_segmented.raw = x.data.(sigs{j});

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
                x_segmented.pro{k} = x.data.(sigs{j})(frame_start:frame_end, :);

                % Create results from the turn information.
                x_segmented.res.(['Segment']).(['turn' k_string]).data.startFrame = frame_start;
                x_segmented.res.(['Segment']).(['turn' k_string]).data.startTime = frame_start/x.freq;
                x_segmented.res.(['Segment']).(['turn' k_string]).data.endFrame = frame_end;
                x_segmented.res.(['Segment']).(['turn' k_string]).data.endTime = frame_end/x.freq;
                x_segmented.res.(['Segment']).(['turn' k_string]).data.duration_frame = frame_end - frame_start;
                x_segmented.res.(['Segment']).(['turn' k_string]).data.duration_time = (frame_end - frame_start)/x.freq;
            end
        end

        % For the file level selections.
    case 'file'

        % Perform a calculation using the signals and then segment the data. This is only an example where the magnitude of two signals from different
        % objects are multiplied together.
        signal = sqrt(sum(x.Right_Foot.data.eul.^2, 2)).*sqrt(sum(x.Left_Foot.data.eul.^2, 2));

        % Perform the segmentation. The subroutine allows the same code to
        % be used at different levels.
        ind = segment(signal);

        % If no segments were found send an error code back to the BAR App and exit the script.
        if any(isnan(ind), 'all')
            x_segmented = '004';
            return
        end

        % Only one object will be segmented in this example.
        objs = {'Lumbar'};
        % The different objects will be iterated through but only one is
        % used to create the segments.
        for j = 1:length(objs)

            % Only one signal will be segmented in this example.
            sig = 'eul';

            % Data from a signal will be segmented and used to plot in the Segmentation Module.
            x_segmented.raw = x.(objs{j}).data.(sig);

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
                    frame_end = length(x.(objs{j}).data.(sig));
                    % The middle segments are from the end index of the
                    % previous turn to the start index of the current turn.
                else
                    frame_start = ind(k - 1, 2);
                    frame_end = ind(k, 1);
                end
                % Set the segment to the processed level of the BAR App
                % data structure.
                x_segmented.pro{k} = x.(objs{j}).data.(sig)(frame_start:frame_end, :);

                % Create results from the turn information.
                x_segmented.res.(['Segment']).(['turn' k_string]).data.startFrame = frame_start;
                x_segmented.res.(['Segment']).(['turn' k_string]).data.startTime = frame_start/x.(objs{j}).freq;
                x_segmented.res.(['Segment']).(['turn' k_string]).data.endFrame = frame_end;
                x_segmented.res.(['Segment']).(['turn' k_string]).data.endTime = frame_end/x.(objs{j}).freq;
                x_segmented.res.(['Segment']).(['turn' k_string]).data.duration_frame = frame_end - frame_start;
                x_segmented.res.(['Segment']).(['turn' k_string]).data.duration_time = (frame_end - frame_start)/x.(objs{j}).freq;
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

        % Get the file names so they can be iterated through.
        files = fieldnames(x.(type));
        for i = 1:length(files)

            % The segmentation in this example if for a particular object and signal within each file.

            % Run the segmentation code.
            ind = segment(x.(type).(files{i}).Lumbar.data.eul(:, 3));

            % Create NaN results if no turns were found.
            if isnan(ind)
                continue
            end

            % The objects will be segmented later on but are pulled now.
            objs = fieldnames(x.(type).(files{i}));

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

                % Each of the objects/IMU data will be segmented.
                for j = 1:length(objs)
                    if strcmp(objs{j}, 'Lumbar')
                        % If the sampling frequency is present it is carried over.
                        if isfield(x.(type).(files{i}).(objs{j}), 'freq')
                            x.pro.(files{i}).(objs{j}).freq = x.(type).(files{i}).(objs{j}).freq;
                        end
                        % Iterate through all of the signals and segment them.
                        sigs = {'eul'};
                        for ii = 1:length(sigs)

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
                            x.pro.(files{i}).(objs{j}).data.([sigs{ii} '_' k_string]) = x.(type).(files{i}).(objs{j}).data.(sigs{ii})(frame_start:frame_end, :);
                            % Create the turn analysis results.
                            x.res.Segment.(files{i}).(objs{j}).data.([sigs{ii} '_turn' k_string]).startFrame = frame_start;
                            x.res.Segment.(files{i}).(objs{j}).data.([sigs{ii} '_turn' k_string]).startTime = frame_start/x.(type).(files{i}).(objs{j}).freq;
                            x.res.Segment.(files{i}).(objs{j}).data.([sigs{ii} '_turn' k_string]).endFrame = frame_end;
                            x.res.Segment.(files{i}).(objs{j}).data.([sigs{ii} '_turn' k_string]).endTime = frame_end/x.(type).(files{i}).(objs{j}).freq;
                            x.res.Segment.(files{i}).(objs{j}).data.([sigs{ii} '_turn' k_string]).duration_frame = frame_end - frame_start;
                            x.res.Segment.(files{i}).(objs{j}).data.([sigs{ii} '_turn' k_string]).duration_time = (frame_end - frame_start)/x.(type).(files{i}).(objs{j}).freq;
                        end
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
ind = [floor(length(x)/3), floor(length(x)/3);...
    floor(2*length(x)/3), floor(2*length(x)/3);...
    ];

end