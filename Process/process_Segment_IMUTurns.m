function x_segmented = process_Segment_IMUTurns(x)

if isnumeric(x)

    x_segmented{1} = x(1:floor(end/2),1);
    x_segmented{2} = x(ceil(end/2):end,1);

elseif isstruct(x)

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
                        x_segmented.processed.([files{i} '_seg' k_string]).(objs{j}).data.(sigs{ii}) = x.raw.(files{i}).(objs{j}).data.(sigs{ii})(ind_Turn(k,1):ind_Turn(k,2), :);
                    end

                end

            end

        end
    end

end

end

function ind_Turn = segment(imu)

ind_Turn = [1, floor(length(imu.Lumbar.data.mag)/2);...
    floor(length(imu.Lumbar.data.mag)/2), length(imu.Lumbar.data.mag)];

end