function x_segmented = process_Segment_HeelStrikeAPDM(x, sel)
% x_segmented = process_Segment_HeelStrikeAPDM(x, sel)
% inputs  - x, the object to segment. It can be a portion or the entirety of the data structure from the BAR App.
%         - sel, the type of selection from the BAR App. Can be timeseries, file or all.
% outputs - dataout, structure containing file from V3D text file
% Remarks
% - This function will segment data passed from the Segment module of the BAR App.
% - The method used here will segment time series from APDM Opal sensors using processed heel strike information from the same data structure. This 
%   requires the raw h5 data to be loaded into the BAR App and then merged with its analysis results.
% Future Work
% - Since this code is used in multiple instances it could potentialy be combined into the segment module.
% Jul 2023 - Created by Ben Senderling, bsender@bu.edu

switch sel

    % For time series selections.
    case 'timeseries'

        % This is an error code for the BAR App that indicates the selected
        % item can't be processed with the selected segmentation method.
        x_segmented = '004';

    % For object selections.
    case 'object'

        % This is an error code for the BAR App that indicates the selected
        % item can't be processed with the selected segmentation method.
        x_segmented = '004';

    % For the file level selections.
    % For the file level selections.
    case 'file'

        x_segmented = segment(x);
        
    case {'pro', 'res'}
        
        % Create a duplicate of the BAR App data structure.
        x_segmented = x;

        % Get the file names so they can be iterated through.
        files = fieldnames(x.(sel));
        for i = 1:length(files)

            % The segment subroutine only acts on the file level with the IMU data.
            file_segmented = segment(x.(sel).(files{i}));

            x_segmented.pro.(files{i}) = file_segmented;
             
        end
end
end

function x_segmented = segment(x)
% ind_Turn = segment(imu)
% inputs  - imu, the object to segment.
% outputs - ind_Turn, start and end indexes of the turns.
% Remarks
% - This function uses results from APDM's processing the segment Lumbar
%   sensor data.
% Future Work
% - None.
% Dec 2022 - Created by Ben Senderling, bsender@be.edu

if isfield(x, 'EventsGaitLowerLimb') && isfield(x.EventsGaitLowerLimb.data, 'InitialContact')
    if isfield(x, 'Left_Foot')
        freq = x.Left_Foot.freq;
        x_segmented.raw.Left_Foot.data.acc_x = x.Left_Foot.data.acc(:, 1);
        for ind_LHS = 1:size(x.EventsGaitLowerLimb.data.InitialContact, 1) - 1
            temp = x.Left_Foot.data.acc(floor(freq*x.EventsGaitLowerLimb.data.InitialContact(ind_LHS, 1)):floor(freq*x.EventsGaitLowerLimb.data.InitialContact(ind_LHS + 1, 1)));
            x_segmented.pro.Left_Foot.data.acc_x(:, ind_LHS) = resample(temp, 101, length(temp));
            x_segmented.res.Left_Foot.data.acc_x.startFrame(ind_LHS, 1) = floor(freq*x.EventsGaitLowerLimb.data.InitialContact(ind_LHS, 1));
            x_segmented.res.Left_Foot.data.acc_x.endFrame(ind_LHS, 1) = floor(freq*x.EventsGaitLowerLimb.data.InitialContact(ind_LHS + 1, 1));
        end
    end
    % if isfield(x, 'Right_Foot')
    %     freq = x.Right_Foot.freq;
    %     x_segmented.raw.Right_Foot.data.acc_x = x.Right_Foot.data.acc(:, 1);
    %     for ind_RHS = 1:size(x.EventsGaitLowerLimb.data.InitialContact, 2) - 1
    %         temp = x.Right_Foot.data.acc(floor(freq*x.EventsGaitLowerLimb.data.InitialContact(ind_RHS, 2)):floor(freq*x.EventsGaitLowerLimb.data.InitialContact(ind_RHS + 1, 2)));
    %         x_segmented.pro.Right_Foot.data.acc_x(:, ind_RHS) = resample(temp, 101, length(temp));
    %         x_segmented.res.Right_Foot.data.acc_x.startFrame(ind_RHS, 1) = floor(freq*x.EventsGaitLowerLimb.data.InitialContact(ind_RHS, 1));
    %         x_segmented.res.Right_Foot.data.acc_x.endFrame(ind_RHS, 1) = floor(freq*x.EventsGaitLowerLimb.data.InitialContact(ind_RHS + 1, 1));
    %     end
    % end
end

end