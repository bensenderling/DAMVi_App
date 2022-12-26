function x = process_Segment_TurnsAPDM(app, x, sel)
% x_segmented = process_Segment_TurnsAPDM(x, sel)
% inputs  - x, the object to segment. It can be a portion or the entirety of the data structure from the BAR App.
%         - sel, the type of selection from the BAR App. Can be timeseries, file or all.
% outputs - dataout, structure containing file from V3D text file
% Remarks
% - This function will segment data passed from the Segment module of the BAR App.
% - The method used here will segment time series from APDM Opal sensors using processed turn information from the same data structure. This requires 
%   the raw h5 data to be loaded into the BAR App and then merged with its analysis results. As of 12/01/2022 those analysis results are created by 
%   running the raw h5 files through executables from APDM.
% Future Work
% - Since this code is used in multiple instances it could potentialy be combined into the segment module.
% Dec 2022 - Created by Ben Senderling, bsender@be.edu

switch sel

    % For time series selections.
    case 'timeseries'

        % This is an error code for the BAR App that indicates the selected
        % item can't be processed with the selected segmentation method.
        x = '004';

    % For the file level selections.
    case 'file'

        % Perform the segmentation. The subroutine allows the same code to
        % be used at different levels.
        ind_Turn = segment(x);

        % If no segments were found send an error code back to the BAR App and exit the script.
        if isnan(ind_Turn)
            x = '004';
            return
        end

        % Get the objects from the file level.
        objs = fieldnames(x);

        % The different objects will be iterated through but only one is
        % used to create the segments.
        for j = 1:length(objs)

            if strcmp(objs{j}, 'Lumbar')

                % Data from the Lumbar magnetomiter will be segmented out
                % and used to plot in the Segmentation Module.
                x.raw = x.(objs{j}).data.eul(:,1);

                % Iterate through the segment indexes.
                for k = 1:size(ind_Turn,1) + 1

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
                        frame_end = ind_Turn(k, 1);
                        % The last turn is from the last index to the end of
                        % the data.
                    elseif k == size(ind_Turn,1) + 1
                        frame_start = ind_Turn(k - 1, 2);
                        frame_end = length(x.raw);
                        % The middle segments are from the end index of the
                        % previous turn to the start index of the current turn.
                    else
                        frame_start = ind_Turn(k - 1, 2);
                        frame_end = ind_Turn(k, 1);
                    end
                    % Set the segment to the processed level of the BAR App
                    % data structure.
                    x.pro{k} = x.(objs{j}).data.eul(frame_start:frame_end, 1);

                    % Create results from the turn information.
                    x.res.(['Segment']).(['turn' k_string]).data.startFrame = frame_start;
                    x.res.(['Segment']).(['turn' k_string]).data.startTime = frame_start/x.(objs{j}).freq;
                    x.res.(['Segment']).(['turn' k_string]).data.endFrame = frame_end;
                    x.res.(['Segment']).(['turn' k_string]).data.endTime = frame_end/x.(objs{j}).freq;
                    x.res.(['Segment']).(['turn' k_string]).data.duration_frame = frame_end - frame_start;
                    x.res.(['Segment']).(['turn' k_string]).data.duration_time = (frame_end - frame_start)/x.(objs{j}).freq;
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

        % Get the file names so they can be iterated through.
        files = fieldnames(x.(type));
        for i = 1:length(files)

            % The segment subroutine only acts on the object level with the
            % IMU data.
            imu = x.(type).(files{i});

            % Run the segmentation code.
            ind_Turn = segment(imu);

            % Create NaN results if no turns were found.
            if isnan(ind_Turn)
                continue
            end

            % The objects will be segmented later on but are pulled now.
            objs = fieldnames(x.(type).(files{i}));

            % For each of the detected turns.
            for k = 0:size(ind_Turn,1)

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
                                frame_end = ind_Turn(k + 1, 1);
                                % The last turn is from the last index to the end of the data.
                            elseif k == size(ind_Turn, 1)
                                frame_start = ind_Turn(k, 2);
                                frame_end = length(x.(type).(files{i}).(objs{j}).data.(sigs{ii}));
                            else
                                frame_start = ind_Turn(k, 2);
                                frame_end = ind_Turn(k + 1, 1);
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

function ind_Turn = segment(imu)
% ind_Turn = segment(imu)
% inputs  - imu, the object to segment.
% outputs - ind_Turn, start and end indexes of the turns.
% Remarks
% - This function uses results from APDM's processing the segment Lumbar
%   sensor data.
% Future Work
% - None.
% Dec 2022 - Created by Ben Senderling, bsender@be.edu

if ~isfield(imu, 'Lumbar')
    % If there is no Lumbar sensor return a NaN. It will serve as a placeholder for the missing data.
    ind_Turn = NaN;
elseif isfield(imu, 'EventsTurns') && isfield(imu, 'MeasuresTurns')
    % These are the turn start times and duration produced by the APDM processing algorithms to get a start and end time for the turns.
    ind_Turn = floor([imu.EventsTurns.data.Start, imu.EventsTurns.data.Start + imu.MeasuresTurns.data.Duration]*imu.Lumbar.freq);
else
    % If there were not turns use the entire data as the segment.
    ind_Turn = [length(imu.Lumbar.data.eul), length(imu.Lumbar.data.eul)];
end

end