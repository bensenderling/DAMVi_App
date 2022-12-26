function app = analysis_MATLABDependencies(app, data, analysis)
% app = analysis_MATLABDependencies(app, data)
% inputs  - app, required mlapp object.
%         - data, BAR App data structure.
%         - analysis, string of the analysis type.
% Remarks
% - This analysis script find the dependencies of all the found m-files. It does not produce any metrics but is meant to provide information on what
%   MATLAB products are needed for the BAR App and it's methods.
% Future Work
% - None.
% Nov 2022 - Created by Ben Senderling, bsender@bu.edu
%% Begin Code

% Get the file names.
files = fieldnames(data.raw);

% Start iterating through the file names.
for i = 1:length(files)

    % Identify the required functions and programs.
    [fList, pList] = matlab.codetools.requiredFilesAndProducts(data.raw.(files{i}).file.data.file);
    % If there is only one requirement the output will have character arrays. But if there are more they will be cells. Convert the single
    % requirements to cells so they can be appended to each other.
    if length({pList.Name}) == 1
        pList.Name = cellstr({pList.Name});
        pList.Version = cellstr({pList.Version});
    end

    % For the first iteration initialize the list.
    if i == 1
        pListAll = struct2table(pList);
        fListAll = fList';
    else
        % For all other iterations append to the existing list.
        pListAll = [pListAll; struct2table(pList)];
        fListAll = [fListAll; fList'];
    end

end

% Set the results data. This looks odd because there is very little information specifying the data but it needs to fit the generalized BAR App
% results type.
data.res.MATLABDependencies.file.file.data.file.fListAll = unique(fListAll);
data.res.MATLABDependencies.file.file.data.file.pListAll = unique(pListAll);

% Run the public BAR App analysisComplete method to get the data back into the app.
analysisComplete(app, data, analysis)

end