function x_segmented = process_Segment_WESENSOpal3(x, sel)
% function x_segmented = process_Segment_WESENSOpal3(x, sel)
% Inputs  - x, data structure from the BAR App.
%         - sel, a type of selection from the BAR App specifying what level
%           of the data structure is being segmented. It can have values of
%           'timeseries', 'file' or 'all'.
% Outputs - x_segmented, data segmented according to the code below.
% Remarks
% - This code will trim data recorded from the BU WESENS project using Opal
%   APDM IMU sensors. The file names and knowledge of the data collection
%   proceedure are used to specify how it should be trimmed.

switch sel

    case 'timeseries'

        % This code is used to print to the log in the BAR App. It
        % indicates this segmentation is not compatible with the
        % selection.
        x_segmented = '004';

    case 'file'

        % The same code for the BAR App log as above.
        x_segmented = '004';

    case 'all'

        x_segmented = x;
        x_segmented.processed = x_segmented.raw;

        files = fieldnames(x.raw);
        ind1 = 1;
        for i = 1:length(files)

            objs = fieldnames(x.raw.(files{i}));

            for j = 1:length(objs)
                % Meta data is carried over if it is present.
                if ~strcmp(objs{j}, 'meta')

                    sigs = fieldnames(x.raw.(files{i}).(objs{j}).data);

                    for ii = 1:length(sigs)

                        if contains(files{i}, 'gait')
                            % A 30 s stationary period is at the start of
                            % every 7 m gait test.
                            frame_start = floor(30*x.raw.(files{i}).(objs{j}).freq);
                            frame_end = floor(length(x.raw.(files{i}).(objs{j}).data.(sigs{ii})));
                        elseif contains(files{i}, 'walk6m')
                            % A 3 s stationary period is at the start of
                            % every 6 min walk test.
                            frame_start = 3*x.raw.(files{i}).(objs{j}).freq;
                            frame_end = length(x.raw.(files{i}).(objs{j}).data.(sigs{ii}));
                        else
                            frame_start = 1;
                            frame_end = length(x.raw.(files{i}).(objs{j}).data.(sigs{ii}));
                        end

                        x_segmented.processed.(files{i}).(objs{j}).data.(sigs{ii}) = x.raw.(files{i}).(objs{j}).data.(sigs{ii})(frame_start:frame_end, :);

                    end

                end

            end

        end

end

end