function app = process_APDM(app, data, process)
% app = analysis_APDM(app, data, analysis)
% inputs  - app, the BAR App object.
%         - data, the data structure loaded into the BAR App.
%         - process, a string stating the type of analysis being
%                     performed.
% outputs - app, the BAR App is returned as an output.
% Remarks
% - This script will calculate euler angles from quaternions from APDM Opal sensors.
% Future Work
% - None.
% Dec 2022 - Created by Ben Senderling
%% Begin Code

% Get all the file names from the data. This uses the raw data.
files = fieldnames(data.raw);

% Iterate through the files.
for i = 1:length(files)

    obj = fieldnames(data.raw.(files{i}));
    obj(strcmp(obj, 'meta')) = [];
    obj(strcmp(obj, 'groups')) = [];

    for ii = 1:length(obj)

        eul = quat2eul(data.raw.(files{i}).(obj{ii}).data.qua)*180/pi;

        d = diff(eul);
        for k = 1:size(d, 2)
            ind = find(abs(d(:, k)) > 170);
            for j = 1:length(ind)
                eul(ind(j) + 1:end, 1) = eul(ind(j) + 1:end, 1) - d(ind(j), k);
            end
        end

        data.raw.(files{i}).(obj{ii}).data.eul = eul;

    end

    % Every 10 files print to the BAR App log.
    if rem(i, 10) == 0
        app.printLog('024', [num2str(i) ' of ' num2str(length(files)) ' analyzed']);
    end

end

analysisComplete(app, data, process)

end