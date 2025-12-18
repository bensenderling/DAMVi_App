function results = run_analysis(app, data, analysis)
% results = run_analysis(app, data, analysis)
% inputs  - app, required mlapp object for apps.
%         - data, data to be analyzed.
%         - analysis, the text name of the analysis method.
% Remarks
% - This function became required when MATLAB stopped allowing code to compile with the feval function. It was deemed a security flaw
%   because any text could be run as code by an unsuspecting user. This function keeps the analysis routines in a single place where
%   they can be modified or added to without going into the larger app code.
% Future Work
% - Exception handling could be useful here, but is currently handled within the DAMVi app.
% Dec 2024 - Created by Ben Senderling, bensenderling@gmail.com

switch analysis
    case 'Actigraph'
        results = analysis_Actigraph(app, data, analysis);
    case 'ContinuousSignalMetrics'
        results = analysis_ContinuousSignalMetrics(app, data, analysis);
    case 'COP' % Center of Pressure
        results = analysis_COP(app, data, analysis);
    case 'CorrelationDimension'
        results = analysis_CorrelationDimension(app, data, analysis);
    case 'CrossSignalMetrics' % Ex. Cross Entropy, Statistical Parametric Mapping
        results = analysis_CrossSignalMetrics(app, data, analysis);
    case 'Delsys'
        results = analysis_Delsys(app, data, analysis);
    case 'DFA' % Detrended FLuctuation Analysis
        results = analysis_DFA(app, data, analysis);
    case 'Entropy'
        results = analysis_Entropy(app, data, analysis);
    case 'FNN' % False Nearest Neighbors
        results = analysis_FNN(app, data, analysis);
    case 'LyE' % Lyapunov Exponents
        results = analysis_LyE(app, data, analysis);
    case 'RQA' % Recurrance Quantification Analysis
        results = analysis_RQA(app, data, analysis); 
end

end