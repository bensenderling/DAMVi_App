function x_segmented = process_Segment_IMUTurns(x, sel)

switch sel

    case 'timeseries'
        
        x_segmented = '004';

    case 'file'
        
        
        ind_Turn = segment(x);

        objs = fieldnames(x);

        for j = 1:length(objs)
            % Meta data is carried over if it is present.
            if strcmp(objs{j}, 'Lumbar')

                x_segmented.raw = x.(objs{j}).data.mag(:,2);

                for k = 1:size(ind_Turn,1) + 1

                    if k < 10
                        k_string = ['0' num2str(k)];
                    else
                        k_string = num2str(k);
                    end

                    if k == 1
                        frame_start = 1;
                        frame_end = ind_Turn(k, 1);
                    elseif k == size(ind_Turn,1) + 1
                        frame_start = ind_Turn(k - 1, 2);
                        frame_end = length(x_segmented.raw);
                    else
                        frame_start = ind_Turn(k - 1, 2);
                        frame_end = ind_Turn(k, 1);
                    end
                    x_segmented.processed{k} = x.(objs{j}).data.mag(frame_start:frame_end, 3);

                    x_segmented.res.(['IMUTurns']).(['turn' k_string]).startFrame = frame_start;
                    x_segmented.res.(['IMUTurns']).(['turn' k_string]).startTime = frame_start/x.(objs{j}).freq;
                    x_segmented.res.(['IMUTurns']).(['turn' k_string]).endFrame = frame_end;
                    x_segmented.res.(['IMUTurns']).(['turn' k_string]).endTime = frame_end/x.(objs{j}).freq;
                    x_segmented.res.(['IMUTurns']).(['turn' k_string]).duration_frame = frame_end - frame_start;
                    x_segmented.res.(['IMUTurns']).(['turn' k_string]).duration_time = (frame_end - frame_start)/x.(objs{j}).freq;
                end

            end

        end

    case 'all'

    x_segmented = x;

    files = fieldnames(x.raw);
    ind1 = 1;
    for i = 1:length(files)

        % Find the turns.

        imu = x.raw.(files{i});

        ind_Turn = segment(imu);

        % Use the indexes of the turns to segment the data.

        objs = fieldnames(x.raw.(files{i}));

        for k = 1:size(ind_Turn,1)

            if k < 10
                k_string = ['0' num2str(k)];
            else
                k_string = num2str(k);
            end

            if k == 1
                frame_start = 1;
                frame_end = ind_Turn(k, 1);
            else
                frame_start = ind_Turn(k - 1, 2);
                frame_end = ind_Turn(k, 1);
            end

            for j = 1:length(objs)
                % Meta data is carried over if it is present.
                if strcmp(objs{j}, 'meta')
                    x_segmented.processed.([files{i} '_seg' k_string]).meta = x.raw.(files{i}).meta;
                else
                    % If the sampling frequency is present it is carried over.
                    if isfield(x.raw.(files{i}).(objs{j}), 'freq')
                        x_segmented.processed.([files{i} '_seg' k_string]).(objs{j}).freq = x.raw.(files{i}).(objs{j}).freq;
                    end

                    sigs = fieldnames(x.raw.(files{i}).(objs{j}).data);
                    for ii = 1:length(sigs)
                        x_segmented.processed.([files{i} '_seg' k_string]).(objs{j}).data.(sigs{ii}) = x.raw.(files{i}).(objs{j}).data.(sigs{ii})(frame_start:frame_end, :);
                    end

                end

            end

        end
    end

end

end

function ind_Turn = segment(imu)

        FUSE = ahrsfilter('SampleRate', imu.Lumbar.freq, 'MagneticDisturbanceNoise', 2);

        accelReadings = imu.Lumbar.data.acc;
        gyroReadings = imu.Lumbar.data.gyr;
        magReadings = imu.Lumbar.data.mag;
        [orientation,angularVelocity] = FUSE(accelReadings,gyroReadings,magReadings);
        t = (0:length(imu.Lumbar.data.mag)-1)'/imu.Lumbar.freq;
        ang = abs(180/pi*euler(orientation, 'ZYX', 'frame'));
        
        turn_times_full = zeros(length(orientation),1);
        turn_times_start = zeros(length(orientation),1);
        turn_times_end = zeros(length(orientation),1);
        for diff_time = 0.2:0.1:1
            
            d = abs(diff(ang(1:round(diff_time*imu.Lumbar.freq):end,1)));
            t_d = t(1:round(diff_time*imu.Lumbar.freq):end);
            t_d(end) = [];

            d_step = d >= 30;

            ind_start = (find(diff(d_step) == 1))*round(diff_time*imu.Lumbar.freq);
            turn_times_start(ind_start) = 1;
            ind_end = (find(diff(d_step) == -1))*round(diff_time*imu.Lumbar.freq);
            turn_times_end(ind_end) = 1;

            for jj = 1:size(ind_start,1)
                turn_times_full(ind_start(jj):ind_end(jj)) = 1;
            end

%             figure
%             subplot(4,1,1), plot(t, ang, 'k', t(logical(turn_times_start)), ang(logical(turn_times_start),1), '.g', t(logical(turn_times_end)), ang(logical(turn_times_end),1), '.r')
%             xlim([0, 60])
%             subplot(4,1,2), plot(t_d, d(:,1), 'k')
%             xlim([0, 60])
%             subplot(4,1,3), plot(t_d, d_step, 'k')
%             xlim([0, 60])
%             subplot(4,1,4), plot(t, turn_times_full, 'k')
%             xlim([0, 60])

        end

%         figure
%         subplot(2,1,1), plot(t, ang, 'k', t(logical(turn_times_start)), ang(logical(turn_times_start),1), '.g', t(logical(turn_times_end)), ang(logical(turn_times_end),1), '.r')
%         subplot(2,1,2), plot(t, turn_times_full, 'k')

        ind_Turn = [find(diff(turn_times_full) == 1), find(diff(turn_times_full) == -1)];

end