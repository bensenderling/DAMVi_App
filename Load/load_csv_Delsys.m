function csv_Delsys = load_csv_Delsys(file)
% csv_Delsys = load_csv_Delsys(file)
% inputs  - file, directory and file name to import
% outputs - dataout, structure containing data from a Delsys system
% Remarks
% - This code is written to load data exported from Delsys as a csv format.
%   It is writen in a general manner so that it does not matter how many
%   columns of data there are. It will automatically parse the column
%   headers for the channel names. Those name are then used to create 
%   structure fields that store the data.
% - The output format is specific for the BAR App.
% - While the code is (hopefully) written in a way that allow a time column
%   to be located only in the first column. It is suggested that the data
%   be exported with a time column for each column of data. Since the 
%   Trigno channels sample at two different frequencies this makes figuring
%   out the time for each channel much easier.
% - This code reads in one line at a time. This will be slower than csvread
%   for shorter files but will be faster and more efficient for longer 
%   files.
% Future Work
% - It could be made more complicated and flexible to load older Delsys
%   files.
% - This code will need to be updated as Delsys updates their software, as
%   it is likely they will change the output format.
% Sept 2022 - Created by Ben Senderling
%
% Copyright 2022 Movement and Applied Imaging Lab, Department of Physical
% Therapy and Athletic Training, Sargent College, Boston University
%
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
%
% 1. Redistributions of source code must retain the above copyright notice,
%    this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright 
%    notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its 
%    contributors may be used to endorse or promote products derived from 
%    this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS 
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%% Begin Code

dbstop if error

fid=fopen(file); % open file

csv_Delsys=struct; % create structure

line=fgetl(fid); % get first line
count=1;

%% If headers are present they will be used to extract sampling information

while strcmp(line(1:5),'Label')
    
    ind1=strfind(line,':'); % this is used to find the EMG and ACC labels
    ind2=strfind(line,'Sampling'); % used to find EMG and ACC labels and sampling frequency
    ind3=strfind(line,'Number'); % used to get the number of data points
    ind4=strfind(line,'start'); % used to get the number of data points
    
    channel=line(ind1(2)+2:ind2-2);
    channel = regexprep(channel, {' ', '[.]'}, {'_', '_'});
    sampfreq=str2num(line(ind2+20:ind3-2));
    csv_Delsys.(channel).sampfreq=sampfreq;
    
    line=fgetl(fid); % get next line
    count=count+1; % used to track how many lines down the file we are
    
end

%% Continue getting lines untill the headers for each channel are encountered

while ~strcmp(line(1),'X') && ~strcmp(line(1),'T') % 'X' if a time column is present for each channel, 'T' if only one time column is present
    line=fgetl(fid);
    count=count+1;
end

headers=textscan(line,'%s','delimiter',','); % parses headers and seperates them for each column
headers=headers{1};

%% Count lines

count2=1;
while ~feof(fid) % load untill end of file is detected
    line=fgetl(fid);
    count2=count2+1;
end

frewind(fid) % rewinds line indicator to the top of the file
for i=1:count % runs for as many lines of headers were detected before
    line=fgetl(fid);
end

%% Read data

data=zeros(count2-1,length(headers));
count2=1;
while ~feof(fid) % load untill end of file is detected
    line=fgetl(fid);
    line=textscan(line,'%f','delimiter',',');
    data(count2,:)=line{1}';
    count2=count2+1;
end

data(isnan(data))=0; % removes nans that may be present if not fully padded with zeros

%% Assign data to structure fields

for i=1:length(headers)
    
    ind4=[];
    
    if strcmp(headers{i},'X[s]') || strcmp(headers{i},'Time') % stores time when ever a X[s] or Time column is ecountered
        time=data(:,i);
        % The data is sometimes interlaced with 0's, which are present in 
        % both the time stamps and the data.
        if time(end)==0
            ind4=find(time==0);
            ind4(1)=[];
            time(ind4)=[];
        end
    else 
        ind1=strfind(headers{i},':');
        ind2=strfind(headers{i},'"');
        channel=headers{i}(ind1+2:ind2(2)-1);
        channel(strfind(channel,' '))=[];
        channel(strfind(channel,'('))=[];
        channel(strfind(channel,')'))=[];
        channel(strfind(channel,'.'))=[];
         
        csv_Delsys.(channel).data=data(:,i);
        
        csv_Delsys.(channel).data(ind4)=[]; % removes 0's if found in time
        csv_Delsys.(channel).time=time;
        
        % print out sampling frequency.
        sampfreq=1/mean(diff(csv_Delsys.(channel).time));
        csv_Delsys.(channel).sampfreq=sampfreq;
        ind4=[];
    end

end
        













