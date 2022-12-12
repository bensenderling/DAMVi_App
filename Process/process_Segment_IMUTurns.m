function x_segmented = process_Segment_IMUTurns(x, sel)
% x_segmented = process_Segment_IMUTurns(x, sel)
% inputs  - x, the object to segment. It can be a portion or the entirety
%              of the data structure from the BAR App.
%         - sel, the type of selection from the BAR App. Can be timeseries,
%                file or all.
% outputs - dataout, structure containing file from V3D text file
% Remarks
% - This function will segment data passed from the Segment module of the
%   BAR App. It is partly a template for other segmentation methods. These
%   may act only on a single signal or time series, an object, or a file
%   from the BAR App data structure. The switch case will handle this level
%   of decision making. But the actual segmentation is performed by a
%   subroutine.
% - The method used here will use the Lumbar sensor from an APDM Opal
%   sensor to find turns and segment the data.
% Future Work
% - This is known to not work for stairclimbing data.
% Mar 2022 - Created by Ben Senderling, bsender@bu.edu
%          - Incorporated into the Biomechanics Analysis and Reporting app
%            for publishment.
%          - Reformated output to meet developing BAR App standards.
%% Begin Code

switch sel

    case 'timeseries'

        % This is an error code for the BAR App that indicates the selected
        % item can't be processed with the selected segmentation method.
        x_segmented = '004';

    case 'file'

        % Perform the segmentation. The subroutine allows the same code to
        % be used at different levels.
        ind_Turn = segment(x);

        % Get the objects from the file level.
        objs = fieldnames(x);

        % The different objects will be iterated through but only one is
        % used to create the segments.
        for j = 1:length(objs)

            if strcmp(objs{j}, 'Lumbar')

                % Data from the Lumbar magnetomiter will be segmented out
                % and used to plot in the Segmentation Module.
                x_segmented.raw = x.(objs{j}).data.mag(:,2);

                % Iterate through the segment indexes.
                for k = 1:size(ind_Turn,1) + 1

                    % This if statement is used to make the turn numbers a
                    % consistent 2 character length as strings.
                    if k < 10
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
                        frame_end = length(x_segmented.raw);
                        % The middle segments are from the end index of the
                        % previous turn to the start index of the current turn.
                    else
                        frame_start = ind_Turn(k - 1, 2);
                        frame_end = ind_Turn(k, 1);
                    end
                    % Set the segment to the processed level of the BAR App
                    % data structure.
                    x_segmented.processed{k} = x.(objs{j}).data.mag(frame_start:frame_end, 2);

                    % Create results from the turn information.
                    x_segmented.res.(['Segment']).(['turn' k_string]).startFrame = frame_start;
                    x_segmented.res.(['Segment']).(['turn' k_string]).startTime = frame_start/x.(objs{j}).freq;
                    x_segmented.res.(['Segment']).(['turn' k_string]).endFrame = frame_end;
                    x_segmented.res.(['Segment']).(['turn' k_string]).endTime = frame_end/x.(objs{j}).freq;
                    x_segmented.res.(['Segment']).(['turn' k_string]).duration_frame = frame_end - frame_start;
                    x_segmented.res.(['Segment']).(['turn' k_string]).duration_time = (frame_end - frame_start)/x.(objs{j}).freq;
                end

            end

        end

    case 'all'

        % Create a duplicate of the BAR App data structure.
        x_segmented = x;

        % Get the file names so they can be iterated through.
        files = fieldnames(x.raw);
        ind1 = 1;
        for i = 1:length(files)

            % The segment subroutine only acts on the object level with the
            % IMU data.
            imu = x.raw.(files{i});

            % Run the segmentation code.
            ind_Turn = segment(imu);

            % The objects will be segmented later on but are pulled now.
            objs = fieldnames(x.raw.(files{i}));

            % For each of the detected turns.
            for k = 1:size(ind_Turn,1)

                % This if statement is used to make the turn numbers a
                % consistent 2 character length as strings.
                if k < 10
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
                else
                    frame_start = ind_Turn(k - 1, 2);
                    frame_end = ind_Turn(k, 1);
                end

                % Each of the objects/IMU data will be segmented.
                for j = 1:length(objs)
                    % Meta data is carried over if it is present.
                    if strcmp(objs{j}, 'meta')
                        x_segmented.processed.([files{i} '_seg' k_string]).meta = x.raw.(files{i}).meta;
                    else
                        % If the sampling frequency is present it is carried over.
                        if isfield(x.raw.(files{i}).(objs{j}), 'freq')
                            x_segmented.processed.([files{i} '_seg' k_string]).(objs{j}).freq = x.raw.(files{i}).(objs{j}).freq;
                        end
                        % Iterate through all of the signals and segment
                        % them.
                        sigs = fieldnames(x.raw.(files{i}).(objs{j}).data);
                        for ii = 1:length(sigs)
                            x_segmented.processed.([files{i} '_seg' k_string]).(objs{j}).data.(sigs{ii}) = x.raw.(files{i}).(objs{j}).data.(sigs{ii})(frame_start:frame_end, :);
                            % Create the turn analysis results.
                            x_segmented.res.(['Segment']).(['turn' k_string]).startFrame = frame_start;
                            x_segmented.res.(['Segment']).(['turn' k_string]).startTime = frame_start/x.(objs{j}).freq;
                            x_segmented.res.(['Segment']).(['turn' k_string]).endFrame = frame_end;
                            x_segmented.res.(['Segment']).(['turn' k_string]).endTime = frame_end/x.(objs{j}).freq;
                            x_segmented.res.(['Segment']).(['turn' k_string]).duration_frame = frame_end - frame_start;
                            x_segmented.res.(['Segment']).(['turn' k_string]).duration_time = (frame_end - frame_start)/x.(objs{j}).freq;
                        end

                    end

                end

            end
        end

end

end

function ind_Turn = segment(imu)

% Perform sensor fusion to turn the IMU information into roll, pitch and
% yaw.
FUSE = ahrsfilter('SampleRate', imu.Lumbar.freq, 'MagneticDisturbanceNoise', 2);
accelReadings = imu.Lumbar.data.acc;
gyroReadings = imu.Lumbar.data.gyr;
magReadings = imu.Lumbar.data.mag;
[orientation,angularVelocity] = FUSE(accelReadings,gyroReadings,magReadings);

% Create a time variable.
t = (0:length(imu.Lumbar.data.mag)-1)'/imu.Lumbar.freq;
% Convert the quaternions into Euler angles for roll, pitch and yaw.
ang = abs(180/pi*euler(orientation, 'ZYX', 'frame'));

% Initialize turn indexes.
turn_times_full = zeros(length(orientation),1);
turn_times_start = zeros(length(orientation),1);
turn_times_end = zeros(length(orientation),1);
% The turn identification is run at different time scales relative to the
% sampling rate.
for diff_time = 0.2:0.1:1

    % The angles are downsampled, differenced and rectified. The difference
    % calculates the range of potential turns. The rectification means
    % turns over a certain value can be found
    d = abs(diff(ang(1:round(diff_time*imu.Lumbar.freq):end,1)));
    % Create a corresponding time variable.
    t_d = t(1:round(diff_time*imu.Lumbar.freq):end);
    t_d(end) = [];

    % Find where turns over 30 deg are present. This could be made to be
    % tuneable.
    d_step = d >= 30;

    % Find where the turns start and adjust it for the downsampling.
    ind_start = (find(diff(d_step) == 1))*round(diff_time*imu.Lumbar.freq);
    % Place a 1 for the turn start times where ever a change in d_step was
    % found.
    turn_times_start(ind_start) = 1;
    % Find where the turns end and adjust it for the downsampling.
    ind_end = (find(diff(d_step) == -1))*round(diff_time*imu.Lumbar.freq);
    % Place a 1 for the turn end times where ever a change in d_step was
    % found.
    turn_times_end(ind_end) = 1;

    % It is assumed that ever turn start has a turn end. All values between
    % them will be made a 1.
    for jj = 1:size(ind_start,1)
        turn_times_full(ind_start(jj):ind_end(jj)) = 1;
    end

    %             figure
    %             subplot(4,1,1), plot(t, ang, 'k', t(logical(turn_times_start)), ang(logical(turn_times_start),1), '.g', t(logical(turn_times_end)), ang(logical(turn_times_end),1), '.r')
    %             subplot(4,1,2), plot(t_d, d(:,1), 'k')
    %             subplot(4,1,3), plot(t_d, d_step, 'k')
    %             subplot(4,1,4), plot(t, turn_times_full, 'k')

end

%         figure
%         subplot(2,1,1), plot(t, ang, 'k', t(logical(turn_times_start)), ang(logical(turn_times_start),1), '.g', t(logical(turn_times_end)), ang(logical(turn_times_end),1), '.r')
%         subplot(2,1,2), plot(t, turn_times_full, 'k')

% The final turn times are where the turn index increase to 1 and decrease
% to 0.
ind_Turn = [find(diff(turn_times_full) == 1), find(diff(turn_times_full) == -1)];

end