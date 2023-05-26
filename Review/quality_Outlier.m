function qualityTable = quality_Outlier(qualityTable)

options = {'median', 'mean', 'quartiles', 'grubbs', 'gesd'};
method = listdlg('ListString', options,...
    'PromptString', 'Please select a method to detect outliers.',...
    'SelectionMode', 'single',...
    'Name', 'Outlier Detection');

methodString = options{method};

if any(contains(fieldnames(qualityTable), 'Measure'))
    types = unique(qualityTable.Measure);
elseif any(contains(fieldnames(qualityTable), 'Signal')) && ~any(contains(fieldnames(qualityTable), 'Measure'))
    types = unique(qualityTable.Signal);
end

for ind_types = 1:length(types)
    if any(contains(fieldnames(qualityTable), 'Measure'))
        b = strcmp(qualityTable.Measure, types{ind_types});
    elseif any(contains(fieldnames(qualityTable), 'Measure')) && any(contains(fieldnames(qualityTable), 'Signal'))
        b = strcmp(qualityTable.Signal, types{ind_types});
    end
    faults = isoutlier(cell2mat(qualityTable.Value(b)), methodString);
    qualityTable.Fault(b) = faults;
end

qualityTable.Notes(find(qualityTable.Fault)) = repmat({[methodString ' outlier']}, sum(qualityTable.Fault), 1);

