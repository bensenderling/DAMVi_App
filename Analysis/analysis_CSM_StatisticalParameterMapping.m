function results = analysis_CSM_StatisticalParameterMapping(app, signal1, signal2, plotName)

a = size(signal1, 1);
b = size(signal2, 1);
if a > b
    signal2 = [signal2; NaN*ones(a - b, size(signal2, 2))];
elseif a < b
    signal1 = [signal1; NaN*ones(a - b, size(signal1, 2))];
end

alpha      = 0.05;
two_tailed = true;
iterations = 100;
force_iterations = true;
snpm       = spm1d.stats.nonparam.ttest(signal1', signal2');
snpmi      = snpm.inference(alpha, 'two_tailed', two_tailed, 'iterations', iterations, 'force_iterations', force_iterations);
% disp('Non-Parametric results')
% disp( snpmi )

H = figure('Visible', 'off', 'Position', [0, 0, 500, 1200]);
subplot(3, 1, 1)
plot(signal1, 'b')
hold on
plot(signal2, 'r')
hold off
title(regexprep(plotName,'_','\\_'))
axis tight
x1 = [(0:size(signal1) - 1)'; flipud((0:size(signal1) - 1)')];
y1 = [mean(signal1, 2, 'omitnan') - std(signal1, [], 2, 'omitnan'); flipud(mean(signal1, 2, 'omitnan') + std(signal1, [], 2, 'omitnan'))];
x1(isnan(y1)) = [];
y1(isnan(y1)) = [];
x2 = [(0:size(signal2) - 1)'; flipud((0:size(signal2) - 1)')];
y2 = [mean(signal2, 2, 'omitnan') - std(signal2, [], 2, 'omitnan'); flipud(mean(signal2, 2, 'omitnan') + std(signal2, [], 2, 'omitnan'))];
x2(isnan(y2)) = [];
y2(isnan(y2)) = [];
subplot(3, 1, 2), fill(x1, y1, 'k', 'FaceColor', 'b', 'LineStyle', 'none', 'FaceAlpha', 0.3)
hold on
fill(x2, y2, 'k', 'FaceColor', 'r', 'LineStyle', 'none', 'FaceAlpha', 0.3)
plot(mean(signal1, 2, 'omitnan'), 'b')
plot(mean(signal2, 2, 'omitnan'), 'r')
hold off
axis tight
subplot(3, 1, 3), plot([]), hold on
snpmi.plot();
snpmi.plot_threshold_label();
snpmi.plot_p_values();
hold off
title('Statistical Non-Parametric Mapping')

saveas(H, [app.Database.Value '\Figures\' plotName '.jpg'])
close(H)

results.ana.snpm = snpml;
results.ana.snpmi = snpmi;
results.ana.signal1 = signal1;
results.ana.signal2 = signal2;











