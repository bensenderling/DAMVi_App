function createConfig

% Create the structure that will be the conf file.
config = struct;

% Assign equipment names to the h5 file type option.
config.options.files.h5 = 'APDM';

% Assign equipment names to the text file type option.
config.options.files.txt = 'V3D';

% Create analysis options.
config.analysis = {...
    'Time Lag', 'analysis_TimeLag'};

% Write the config file to an xml file.
writestruct(config,'config.xml')