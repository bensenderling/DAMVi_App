function h5_APDM2 = load_h5_APDM2(file)
% h5_APDM2 = load_h5_APDM2(file)
% inputs  - file, directory and file name to import
% outputs - dataout, structure containing data from a h5 file from APDM.
% Remarks
% - This code is written to load data exported from a h5 file file that was
%   created by running an h5 file through APDM processing code written in
%   Python. These files differed notably from other results files processed
%   with the same code but a different algorithm. Because of this the code 
%   pulls data out of the h5 file recursively. All of the data is pulled 
%   out. The files this code was tested on had 'Analysis' in the file name,
%   and only had results. Files with more raw data may end loading a
%   significant of data and taking up more RAM.
% - The h5 results files included both left and right side data together
%   but in different rows. Left was the top row and right was the bottom
%   row.
% Future Work
% - This function has recently been made more general but has not been
%   tested on varied h5 files.
% Nov 2022 - Created by Ben Senderling
%
%% Begin Code

% Pull the information from the h5 file and save it as the meta data.
h5_APDM2.meta = h5info(file);
% Get the remaining data recursively.
h5_APDM2 = getData(file, h5_APDM2.meta.Groups, h5_APDM2);

end

function h5_APDM2 = getData(file, h5_struct, h5_APDM2)

% Iterate through the current group of the h5 file.
for i = 1:length(h5_struct)
    % Check if the current group has subgroups and get the data from them.
    if ~isempty(h5_struct(i).Groups)
        h5_APDM2 = getData(file, h5_struct(i).Groups, h5_APDM2);
    end
    % Check if the current group has data associated with it.
    if ~isempty(h5_struct(i).Datasets)
        % Group names can have illegal characters that must be removed.
        measure = regexprep(h5_struct(i).Name, {' ', '/'}, {''});
        % Iterate through the multiple datasets of the current group and
        % pull out the data.
        for j = 1:length(h5_struct(i).Datasets)
            name = regexprep(h5_struct(i).Datasets(j).Name, {' ', char(0), '+'}, {'', '', 'Plus'});
            h5_APDM2.(measure).data.(name) = h5read(file, [h5_struct(i).Name '/' h5_struct(i).Datasets(j).Name]);
        end
    end
end

end



















