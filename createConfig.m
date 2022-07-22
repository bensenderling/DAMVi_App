function createConfig

% Create the structure that will be the conf file.
config = struct;

% Creates an empty directory to search for files. This will be remembered
% after running the app the first time.
config.directory = '';

% Creates an empty directory to specify the database. This will be
% remembered after running the app the first time. When a folder is
% selected the app will check that all the needed subfolders are present
% and if they aren't, create them.
config.database = '';

% Assign equipment names to the h5 file type option.
config.options.files.h5 = 'APDM';

% Assign equipment names to the text file type option.
config.options.files.txt = 'V3D';

% Assign equipment names to the mat file type option.
config.options.files.mat = 'BAR';

% Assign equipment names to the mat file type option.
config.options.files.xls = 'XLSX';

% Available treatment modules.
config.treatment = {...
    'General Treatment', 'process_Treatment',...
    'Segment', 'process_Segment'};
config.treatment_general = {...
    'Low-pass Filter', 'process_Treatment_LowPass',...
    'Resample', 'process_Treatment_Resample'};
config.segmentation_general = {...
    'Threshold', 'process_Segment_Threshold',...
    'Turning in IMUs', 'process_Segment_IMUTurns'};

% Available analysis modules.
config.analysis = {...
    'Time Lag', 'analysis_TimeLag',...
    'FNN', 'analysis_FNN',...
    'RQA', 'analysis_RQA'};

% Available review modules.
config.review = {...
    'Raw Data', 'review_RAW',...
    'Time Lag', 'review_TimeLag',...
    'FNN', 'review_FNN',...
    'RQA', 'review_RQA'};

config.figures = {...
    '1D', '',...
    '2D', '',...
    '3D', '',...
    'MD', 'figure_MD'};

% Available export modules.
config.export = {...
    'General',...
    'BU Caltesting'};

% Write the config file to an xml file.
writestruct(config,'config.xml')