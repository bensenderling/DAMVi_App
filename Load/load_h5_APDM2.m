function h5_APDM2 = load_h5_APDM2(file)

dbstop if error

h5_APDM2.meta = h5info(file);

%%

% for i = 1:length({h5_APDM2.meta.Groups(2).Groups.Name})
%     name = h5readatt(file,[h5_APDM2.meta.Groups(2).Groups(i).Name '/Configuration'], 'Label 0');
    name = 'measures';%regexprep(name, {' ', char(0)}, {'_', ''});
%     time = double(h5read(file,[h5_APDM2.meta.Groups(2).Groups(i).Name '/Time']));
%     h5_APDM2.(name).freq = 1/mean(diff(time - time(1))/1e6);
    h5_APDM2.(name).data.dur = h5read(file, [h5_APDM2.meta.Groups.Name '/Duration'])';
% end





















