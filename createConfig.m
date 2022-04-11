function createConfig

% Create the structure that will be the conf file.
config = struct;

% Assign equipment names to the h5 file type option.
config.options.files.h5 = 'APDM';

% Assign equipment names to the text file type option.
config.options.files.txt = 'V3D';

% Assign equipment names to the mat file type option.
config.options.files.mat = 'BAR';

% Available analysis modules.
config.analysis = {...
    'Time Lag', 'analysis_TimeLag',...
    'FNN', 'analysis_FNN',...
    'RQA', 'analysis_RQA'};

% Available treatment modules.
config.treatment = {...
    'General Treatment', 'process_Treatment',...
    'Segment', 'process_Segment'};
% Available export modules.
config.export = {...
    'General',...
    'BU Caltesting'};

% Write the config file to an xml file.
writestruct(config,'config.xml')