function results = run_review(app, data, review)
% results = run_review(app, data, process)
% inputs  - app, required mlapp object for apps.
%         - data, data to be analyzed.
%         - process, the text name of the processing method.
% Remarks
% - This function became required when MATLAB stopped allowing code to compile with the feval function. It was deemed a security flaw
%   because any text could be run as code by an unsuspecting user. This function keeps the analysis routines in a single place where
%   they can be modified or added to without going into the larger app code.
% Future Work
% - Exception handling could be useful here, but is currently handled within the DAMVi app.
% Dec 2024 - Created by Ben Senderling, bensenderling@gmail.com

switch review
    case 'General'
        results = review_General(app, data);
    case 'QC'
        results = review_QC(app, data);
end

end