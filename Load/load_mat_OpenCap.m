function mat_OpenCap = load_mat_OpenCap(file)
% mat_OpenCap = load_mat_OpenCap(file)
% inputs  - file, this is the file path to the file to load.
% outputs - data, The BAR App data structure created from some previous use of the app.
% Remarks
% - This method loads a Python dictionary that was saved as a mat-file. It attempts to largely use the file as is. Attempts to improve this code
%   should start will improving the organization of the data's source.
% Future Work
% - This is a crude load function and could likely be reworked or replaced entirely.
% Apr 2022 - Created by Ben Senderling, bsender@bu.edu

data = load(file);


vars = fieldnames(data);
mat_OpenCap = struct;

% Move some fields that would be considered meta data.
if any(strcmp(vars, 'iter'))
    mat_OpenCap.meta.iter = data.iter;
    vars(contains(vars, 'iter')) = [];
end
if any(strcmp(vars, 'time'))
    freq = 1/mean(diff(data.time));
end

% Find fields that are clear labels for other fields.
labels = vars(contains(vars, 'labels'));
for ind_labels = 1:length(labels)
    label = labels{ind_labels}(1:strfind(labels{ind_labels}, '_') - 1);
    labelVars = vars(contains(vars, label) & ~contains(vars, 'label'));
    for ind_labelVars = 1:length(labelVars)
        for ind_labelVar = 1:size(data.(labelVars{ind_labelVars}), 1)
            mat_OpenCap.(label).data.(data.(labels{ind_labels})(ind_labelVar, :)) = data.(labelVars{ind_labelVars})(ind_labelVar, :)';
        end
        mat_OpenCap.(label).freq = freq;
    end
    vars(contains(vars, label)) = [];
end

% Move the coordinates to objects.
if any(contains(vars, 'coordinates'))
    coors = vars(contains(vars, 'coordinate_'));
    for ind_coors = 1:length(coors)
        label = coors{ind_coors}(strfind(coors{ind_coors}, 'nate_') + 5:end);
        for ind_labels = 1:size(data.coordinates, 1)
            illegalCharacters = {'!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '-', '=', '+', '[', ']', '{', '}', ';', ':', ',', '\.', '<', '>', '/', '?', ' '};
            name = regexprep([label '_' data.coordinates(ind_labels, :)], illegalCharacters, '');
            mat_OpenCap.(coors{ind_coors}).data.(name) = data.(coors{ind_coors})(ind_labels, :)';
        end
        mat_OpenCap.(coors{ind_coors}).freq = freq;
        vars(contains(vars, coors{ind_coors})) = [];
    end
end
vars(contains(vars, 'coordinates')) = [];

% Move torques to objects.
if any(contains(vars, 'torques'))
    torqs = vars((contains(vars, 'torques') & ~contains(vars, '_torques')));
    for ind_torqs = 1:length(torqs)
        for ind_labels = 1:size(data.coordinates, 1)
            illegalCharacters = {'!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '-', '=', '+', '[', ']', '{', '}', ';', ':', ',', '\.', '<', '>', '/', '?', ' '};
            name = regexprep([torqs{ind_torqs} '_' data.coordinates(ind_labels, :)], illegalCharacters, '');
            mat_OpenCap.(torqs{ind_torqs}).data.(name) = data.(torqs{ind_torqs})(ind_labels, :)';
        end
        mat_OpenCap.(torqs{ind_torqs}).freq = freq;
        vars(contains(vars, torqs{ind_torqs})) = [];
    end
end

% Move GRMs with similar labels to GRFs.
if any(contains(vars, 'GRM'))
    labels = fieldnames(mat_OpenCap.GRF.data);
    labels = strrep(labels, 'force', 'moment');
    labelVars = vars(contains(vars, 'GRM'));
    for ind_labelVars = 1:length(labelVars)
        for ind_labels = 1:size(labels, 1)
            mat_OpenCap.GRM.data.(labels{ind_labels}) = data.(labelVars{ind_labelVars})(ind_labelVar, :)';
        end
        mat_OpenCap.GRM.freq = freq;
    end
    vars(contains(vars, 'GRM')) = [];
end



for i = 1:length(vars)
    if isnumeric(data.(vars{i}))
        mat_OpenCap.dict.data.(vars{i}) = data.(vars{i});
    end
end












