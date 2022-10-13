function [datout]=processEMG_quick(data,freq,HR)

% [names]=Z_emg_3d_fig01(data_emg)
% inputs    - data, time series
%           - freq, sampling frequency
%           - HR, true or false to filter out heart rate
% outputs   - a, alpha or hurst exponent from DFA
%           - r2, r-squeared value from the DFA best-fit line
% Remarks
% - This code was written to run EMG data through DFA.
% Subroutines
% - dfa.m
% Jan 2019 - Created by Ben Senderling, email unonbcf@unomaha.edu

%% Turn off warning common to this processing.

dbstop if error
warning('off','MATLAB:polyfit:RepeatedPointsOrRescale')

%%

time=(0:length(data)-1)/freq;

data=data-mean(data); % remove offset

% Filter
bp=[10,500]/(freq/2);
[b,a]=butter(4,bp,'bandpass');
data_filt=filtfilt(b,a,data);

% Filter out heart rate.
if HR==1
    [b,a]=butter(4,[95,105]/(freq/2),'stop');
    data_filt=filtfilt(b,a,data_filt);
end

data_rect=abs(data_filt); % rectified

%% Not used but availeble.
win=round(50/1000*freq); % milliseconds to frames
data_win=movmean(data_rect,win);
data_rms=zeros(length(data_rect),1);
for i=ceil(win/2)+1:length(data_filt)-ceil(win/2)
    data_rms(i-floor(win/2):i+floor(win/2))=sqrt(mean((data_rect(i-floor(win/2):i+floor(win/2)).^2)));
end

%% Create envelope

cf=6/(freq/2);
[b,a]=butter(4,cf,'low');
data_env=filtfilt(b,a,data_rect);

%%

datout.win=data_win;
datout.rms=data_rms;
datout.env=data_env;









