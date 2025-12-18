function results = run_process(app, data, process)
% results = run_process(app, data, process)
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

switch process
    case 'Eventing'
        results = process_Eventing(app, data, process);
    case 'Segment' % Center of Pressure
        results = process_Segment(app, data, process);
    case 'Treatment'
        results = process_Treatment(app, data, process);
end

end