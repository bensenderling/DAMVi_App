function H = plot_DFA(x, a, r2, out_a, out_l)
% H = plot_DFA(app, data)
% inputs  - x, the time series.
%         - a, alpha.
%         - r2, the goodness of fit of the linear fit.
%         - out_a, an array output from DFA.m used to create the plot.
%         - out_l, an array output from DFA.m used to create the plot.
% outputs - H, figure that will be used by the BAR App to copy into the figure panel.
% Remarks
% - This function will create a specific figure for a detrended fluctuation analysis. This is only subroutine and meant to be used by other methods to
%   create the plot within a larger figure.
% Future Work
% - None.
% Nov 2023 - Created by Ben Senderling, bsender@bu.edu

% Pull out the arrays needed for the plot from the analysis results.
n = out_a(:, 1);
F = out_a(:, 2);
n_fit = out_l(:, 1);
F_fit = out_l(:, 2);
logF_fit = out_l(:, 3);

H = figure('Visible', 'off');

% Create the first plot that is only the data.
subplot(3, 1, 1), plot(x, 'k')
axis tight
xticklabels({})
yticklabels({})

% Create the DFA plot.
subplot(3, 1, [2, 3])
dfa_plot(n, F, n_fit, F_fit, logF_fit); % produce plot of log F vs log n
string = ['\alpha = ', num2str(a, '%.2f'), newline, 'r^2 = ', num2str(r2, '%.2f')];
x_lim = get(gca, 'XLim');
y_lim = get(gca, 'YLim');
text(x_lim(2)/2, y_lim(1)*2, string, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom')

end

% The code below was taken fully from the DFA.m script.

function hAxObj = dfa_plot(n, F, n_fit, F_fit, logF_fit)
% hAxObj = dfa_plot(n, F, n_fit, F_fit, logF_fit)
% Inputs  - n, vector of box sizes
%         - F, vector of fluctuations
%         - n_fit, vector of box sizes to fit
%         - F_fit, vector of best fit values
% Outputs - hAxObj: handle to axis object
% Remarks
% - DFA_PLOT Plots fluctuations as a function of box size on log-log axis
%   with best-fit line.
% Prior    - Created by Naomi Kochi
% Jul 2020 - Modified by Ben Senderling
%          - Reformated comments. Removed commented out code assuming it
%            was never used.
%% Begin Code

loglog(n, F, 'b.', n_fit, F_fit, 'ro', n_fit, logF_fit, '-r')

hAxObj = handle(gca);
x_lim = get(hAxObj, 'XLim');
y_lim = get(hAxObj, 'YLim');
x_decades = log10(x_lim(2)/x_lim(1));
y_decades = log10(y_lim(2)/y_lim(1));
if x_decades >= y_decades % set x- and y-axis to be same size (so a = 1 is on first diagonal)
    y_lim_new = y_lim(1)*10^x_decades;
    set(hAxObj, 'YLim', [y_lim(1), y_lim_new]);
else
    x_lim_new = x_lim(1)*10^y_decades;
    set(hAxObj, 'XLim', [x_lim(1), x_lim_new]);
end
axis square
xlabel('log box size')
ylabel('log RMS fluctuations')

end
