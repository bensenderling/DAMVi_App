function app = analysis_COP(app, data, analysis)
% app = analysis_COP(app, data, analysis)
% inputs  - app, the BAR App object.
%         - data, the data structure loaded into the BAR App.
%         - analysis, a string stating the type of analysis being
%                      performed.
% outputs - app, the BAR App is returned as an output.
% Remarks
% - This code calculates various linear and frequency based measures for
%   center of pressure data.
% - The code assumes that the x coordinates are along the mediolateral axis
%   and the y coordinates are along the anteroposterior axis or the
%   longitudinal axis.
% - Units are assumed to be in millimeters.
% Future Work
% - None
% Dec 2014 - Created by Ben Senderling, email: bensenderling@gmail.com
% Jan 2015 - Modified by Ben Senderling, email: bensenderling@gmail.com
%          - Found an error in the prieto.slope calculations. The values
%            were inverted. This is primarily used to plot the ellipse and
%            is not used to calculate any of the outputs.
% May 2015 - Modified by Ben Senderling, email: bensenderling@gmail.com
%          - Reconciled with different varients of the same code.
%          - Modified to be mac and windows compatible.
% Feb 2025 - Modified by Ben Senderling, bms322@drexel.edu
%          - Adapted the code to work with the DAMVi App. Removed figure
%          - code to be done in a different function within DAMVi.

% Get all the file names from the data.
files = fieldnames(data.('raw'));

% Iterate through the files.
for ind_files = 1:length(files)

    % Get the object names so they can be iterated through.
    objs = fieldnames(data.('raw').(files{ind_files}));
    % Remove the informational items.
    objs(strcmp(objs, 'groups')) = [];
    objs(strcmp(objs, 'meta')) = [];

    % Iterate through the objects.
    for ind_obj = 1:length(objs)

        % Get the signal names.
        sigs = fieldnames(data.('raw').(files{ind_files}).(objs{ind_obj}).data);

        % Iterate through the signal names.
        for ind_sig = 1:length(sigs)

            % Skip the results that were already calculated.
            if ~(isfield(data, 'res') && isfield(data.res, 'COP') && isfield(data.res.COP, files{ind_files}) && isfield(data.res.COP.(files{ind_files}), objs{ind_obj}) && isfield(data.res.COP.(files{ind_files}).(objs{ind_obj}).data, sigs{ind_sig}))

                if strcmp(sigs{ind_sig}, 'COP')

                    % Pull out the time series to be easier to work with.
                    COPx = data.raw.(files{ind_files}).(objs{ind_obj}).data.(sigs{ind_sig})(:, 1);
                    COPy = data.raw.(files{ind_files}).(objs{ind_obj}).data.(sigs{ind_sig})(:, 2);
                    sampfreq = data.raw.(files{ind_files}).(objs{ind_obj}).freq;

                    % Create a vector for the time.
                    n = length(COPx);
                    t = (0:n-1)'*1/sampfreq;

                    % Normalize x and y data.
                    COPxnorm = COPx - mean(COPx);
                    COPynorm = COPy - mean(COPy);

                    % Finds radius of COP path.
                    COPradius = sqrt(COPxnorm.^2 + COPynorm.^2);

                    % Linear analyses
                    % (Notes) Root Mean Square (x,y,d) - i.e. Standard 
                    % deviation Prieto equations 6 and 7, p 958. In these 
                    % equations Prieto divides by n, not n-1.
                    rms_x = sqrt((1/length(COPxnorm))*sum(COPxnorm.^2));
                    rms_y = sqrt((1/length(COPynorm))*sum(COPynorm.^2));
                    rms_d = sqrt((1/length(COPradius))*sum(COPradius.^2));

                    rangeml = max(COPxnorm) - min(COPxnorm);
                    rangeap = max(COPynorm) - min(COPynorm);

                    % Sway Path
                    % This produces a measure of the total distance 
                    % traveled along one dimension. It is similar to arc 
                    % length but is not the same. For example the function 
                    % f(t)=sin(t) on the interval [0 2pi] has a swaypath of
                    % 4. The function travels a total of 4 units along the 
                    % y axis within the interval. If y=sin(t) and x=cos(t) 
                    % the resultant function is a circle. If the radial 
                    % distance of this circle is used as the input (a
                    % constant 1 value), the output of this script will be 
                    % zero.
                    % Ref - Measures of Postural Steadiness- Differences 
                    % Between Healthy Young and Elderly Adults, Prieto 1996
                    swaypathd = sum(abs(diff(COPradius)));
                    swaypathx = sum(abs(diff(COPxnorm)));
                    swaypathy = sum(abs(diff(COPynorm)));

                    % This version of the calculation provides the total 
                    % arc length.
                    i = 1:n - 1;
                    swaypathtangential = sum(sqrt((COPxnorm(i + 1) - COPxnorm(i)).^2 + (COPynorm(i+1) - COPynorm(i)).^2));

                    % Area of 95% Confidence Circle

                    % (Notes) Finds the area of a circle that includes 95% 
                    % of radii(COPradius). This is a one sided test so the 
                    % z score has a value of 1.645. It assumes a normal 
                    % distribution of radii, as does Prieto. However the
                    % distribution of radii is not normally distributed. 
                    % For now use 1.645 from the normal pdf. Chi-square pdf
                    % needed?

                    confcir95 = mean(COPradius) + 1.645*std(COPradius);
                    Acir = pi*confcir95^2;

                    % Area of 95% Confidence Ellipse
                    % (Notes) This is from Prieto (1996) and from Sokal and
                    % Rohlf (1995) Biometry p589, also cited by Prieto.

                    sML= sqrt((1/length(COPxnorm))*sum(COPxnorm.^2)); % Prieto
                    sAP= sqrt((1/length(COPynorm))*sum(COPynorm.^2)); % Prieto
                    sAPML= (1/length(COPxnorm))*sum(COPxnorm.*COPynorm); % Prieto

                    prieto.f=3;

                    % (Notes) Prieto has missed squaring the sum of the 
                    % first two terms in his equation(16) page 959. This 
                    % equation is actually from Sokal and Rohlf (1995).

                    prieto.d = sqrt((sAP^2 + sML^2)^2 - 4*(sAP^2*sML^2 - sAPML^2));

                    prieto.ellipRA = sqrt(prieto.f*(sAP^2 + sML^2 + prieto.d)); %Prieto eq 14, (1995)
                    prieto.ellipRB = sqrt(prieto.f*(sAP^2 + sML^2 - prieto.d)); %Prieto eq 15
                    prieto.ellipA = 2*pi*prieto.f*sqrt(sAP^2*sML^2 - sAPML^2); %Prieto eq 18

                    prieto.lambda = (sAP^2 + sML^2 + prieto.d)/2; % from Sokal and Rohlf
                    prieto.slope = prieto.ellipRA/prieto.ellipRB;
                    % prieto.slope = sAPML/(prieto.lambda - sML^2); % from Sokal and Rohlf
                    prieto.angle = atan(prieto.slope);

                    %% Frequency Domain Analyses

                    % (Notes) Prieto, et al (1996) used a sinusiodal 
                    % multitaper method with eight tapers for their 
                    % spectral analyses. They cite Minimum Bias Multiple 
                    % Taper Spectral Emission by Riedel and Sidorenko 
                    % (1995). It was published in the IEEE Transactions on 
                    % Signal Processing 43(1) 188-195. This implementation
                    % follows the equation on page 188, in paragraph 4 of 
                    % Riedel and Sidorenko.

                    N = length(COPradius);
                    n = 1:N;
                    TaperWindow = 0.5*(1 - cos(2*pi*((n - 1)/(N - 1))));
                    WindowedData = (COPradius.*TaperWindow');

                    TransformFFT = fft(WindowedData); % Get fourier transform of data.

                    % Check for an even number of data points, else toss last data point.
                    if mod(length(TransformFFT), 2)
                        TransformFFT(end) = [];
                    end

                    Spectrum = TransformFFT(1:length(TransformFFT)/2).*conj(TransformFFT(1:length(TransformFFT)/2));

                    % (Notes) This is why the index starts at 3 (so points 
                    % 1 and 2 are removed) The big difference is here a 
                    % Hanning window is used, whereas Prieto used a 
                    % multitaper method. (BS) To make sense of this comment
                    % look ahead to the Median Frequency calculation about 
                    % 40 lines down. That is where the index starts at 3.

                    f = (.5/length(Spectrum))*sampfreq*(1:length(Spectrum));

                    % Median Frequency

                    % (Notes) Prieto discards the first two points in the 
                    % spectra and only uses data to 5 Hz. We have 
                    % frequencies up at 7, so cutoff here is at 10 Hz - to 
                    % avoid 60 Hz noise when doing power spectral 
                    % densities. See left-top of p 960

                    freqindex = 1;
                    while f(freqindex) < 10 && freqindex ~= length(f) % biomechanical data is thought to exist primarily under 10 Hz (BS)
                        freqindex = freqindex + 1;
                    end
                    analysisspectrum = Spectrum(3:freqindex);
                    analysisfrequency = f(3:freqindex)';

                    CumSumPower = cumsum(analysisspectrum);
                    FindMedian = find(CumSumPower > .5*sum(analysisspectrum));
                    MedianIndex = min(FindMedian);

                    medianfreq = (.5/length(Spectrum))*sampfreq*MedianIndex;

                    % Frequency Dispersion

                    Mu0 = (1/length(analysisspectrum))*sum(analysisspectrum);
                    Mu1 = (1/length(analysisspectrum))*sum(analysisspectrum.*analysisfrequency);
                    Mu2 = (1/length(analysisspectrum))*sum(analysisspectrum.*analysisfrequency.^2);

                    freqdisp = sqrt(1 - Mu1^2/(Mu0*Mu2));

                    %% Create Output

                    % RMS for ML
                    data.res.COP.(files{ind_files}).(objs{ind_obj}).data.(sigs{ind_sig}).average = rms_x;
                    % RMS for AP
                    data.res.COP.(files{ind_files}).(objs{ind_obj}).data.(sigs{ind_sig}).average = rms_y;
                    % RMS for radial
                    data.res.COP.(files{ind_files}).(objs{ind_obj}).data.(sigs{ind_sig}).average = rms_d;
                    
                    % Range AP
                    data.res.COP.(files{ind_files}).(objs{ind_obj}).data.(sigs{ind_sig}).average = rangeap;
                    % Range ML
                    data.res.COP.(files{ind_files}).(objs{ind_obj}).data.(sigs{ind_sig}).average = rangeml;

                    % Sway path along ML
                    data.res.COP.(files{ind_files}).(objs{ind_obj}).data.(sigs{ind_sig}).average = swaypathx;
                    % Sway path along AP
                    data.res.COP.(files{ind_files}).(objs{ind_obj}).data.(sigs{ind_sig}).average = swaypathy;
                    % Sway path along radial
                    data.res.COP.(files{ind_files}).(objs{ind_obj}).data.(sigs{ind_sig}).average = swaypathd;
                    % Sway path tangential
                    data.res.COP.(files{ind_files}).(objs{ind_obj}).data.(sigs{ind_sig}).average = swaypathtangential;

                    % Circle area
                    data.res.COP.(files{ind_files}).(objs{ind_obj}).data.(sigs{ind_sig}).average = Acir;
                    % Ellipse area
                    data.res.COP.(files{ind_files}).(objs{ind_obj}).data.(sigs{ind_sig}).average = prieto.ellipA;

                    % Median frequency
                    data.res.COP.(files{ind_files}).(objs{ind_obj}).data.(sigs{ind_sig}).average = medianfreq;
                    % Frequency dispersion
                    data.res.COP.(files{ind_files}).(objs{ind_obj}).data.(sigs{ind_sig}).average = freqdisp;

                end

            end
        end
    end

    % This code will print a message to the BAR App with the code's progress. It will print a message every 10 files. It is a public method so it
    % can be called from outside the app.
    if rem(ind_files, 10) == 0
        printLog(app, '024', ['raw' ': ' num2str(ind_files) ' of ' num2str(length(files)) ' analyzed']);
    end

end

% This is a public method in the BAR App. It will return the data to the app and prompt to save it.
analysisComplete(app, data, analysis, 0)

end
