function data = load_mat_BAR(file)
% m_MATLAB = load_m_MATLAB(file)
% inputs  - file, this is the file path to the file to load.
% outputs - data, The BAR App data structure created from some previous use of the app.
% Remarks
% - This method allows a user to load any BAR App data structure into the app.
% Future Work
% - There could be some code added to make sure the object is an actual BAR
%   App data structure.
% Dec 2022 - Created by Ben Senderling, bsender@bu.edu

load(file);