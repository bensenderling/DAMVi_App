function app = analysis_V3DAPDMAlignment2(app, data, analysis)

dbstop if error

files = fieldnames(data.raw);
for i = 1:length(files)

    for crop = {'CR'}

        for sig = {'CGAcc', 'AngVel'}
            obj = fieldnames(data.raw.(files{i}));
            
            if strcmp(crop, 'CR') && (any(contains(obj, 'RPV')) || any(contains(obj, 'RTH')))
                if strcmp(sig, 'CGAcc')
                    ind = find(contains(obj, 'RPV'));
                elseif strcmp(sig, 'AngVel')
                    ind = find(contains(obj, 'RTH'));
                end
                signal = sig{1};
                imuSeg = sqrt(sum(data.raw.(files{i}).(obj{ind}).data.(signal).^2, 2));
                imuSeg(isnan(imuSeg)) = 0;
                imuSeg_freq = data.raw.(files{i}).(obj{ind}).freq;
            elseif strcmp(crop, 'UC') && isfield(data.raw.(files{i}), 'DelsysTrignoSDK')
                sig2 = fieldnames(data.raw.(files{i}).DelsysTrignoSDK.data);
                signal = sig2{contains(sig2, sig)};
                imuSeg = sqrt(data.raw.(files{i}).DelsysTrignoSDK.data.(signal).^2 + data.raw.(files{i}).DelsysTrignoSDK.data.([signal(1:end-1) 'Y']).^2 + data.raw.(files{i}).DelsysTrignoSDK.data.([signal(1:end-1) 'Z']).^2);
                imuSeg_freq = data.raw.(files{i}).DelsysTrignoSDK.freq;
            else
                continue
            end

            if isempty(imuSeg_freq)
                imuSeg_freq = 2000;
            end

            ind = find(contains(obj, 'METRIC'));
            if isempty(ind)
                data.res.(files{i}).(objName).data.AMILag = NaN;
                data.res.(files{i}).(objName).data.AMILagQ = NaN;
                data.res.(files{i}).(objName).data.AMI = NaN;
                data.res.(files{i}).(objName).data.XCorrLag = NaN;
                data.res.(files{i}).(objName).data.XCorrLagQ = NaN;
                data.res.(files{i}).(objName).data.XCorr = NaN;
                data.res.(files{i}).(objName).data.AffectedSide = NaN;
                continue
            end

            side = 'R';

            if strcmp(sig, 'CGAcc')
                opal = 'Lumbar';
                sig_opal = 'acc';
                imuOpal = sqrt((data.raw.(files{i}).(opal).data.(sig_opal)(:,1)+9.81).^2 + data.raw.(files{i}).(opal).data.(sig_opal)(:,2).^2 + data.raw.(files{i}).(opal).data.(sig_opal)(:,3).^2);
            elseif strcmp(sig, 'AngVel')
                opal = 'Right_Upper_Leg';
                sig_opal = 'gyr';
                imuOpal = sqrt(sum(data.raw.(files{i}).(opal).data.(sig_opal).^2, 2));
            end
            
            imuOpal_freq = data.raw.(files{i}).(opal).freq;

            if ~isinteger(imuOpal_freq)
                fprintf('rounding sampliog rate to %i from %f\n', round(imuOpal_freq), imuOpal_freq)
                imuOpal_freq = round(imuOpal_freq);
            end

            imuSeg = resample(imuSeg, imuOpal_freq, 250);
%             imuSeg = resample(imuSeg, imuOpal_freq, imuSeg_freq);

            time_Seg = (0:length(imuSeg) - 1)'/imuOpal_freq;
            time_Opal = (0:length(imuOpal) - 1)'/imuOpal_freq;

            imuSeg = (imuSeg - min(imuSeg))/(max(imuSeg)-min(imuSeg));
            imuOpal = (imuOpal - min(imuOpal))/(max(imuOpal)-min(imuOpal));

            if strcmp(crop, 'CR')
                N = length(imuOpal) - length(imuSeg);
                lag_ami = 1:N;
                ami = zeros(N, 1);
                for j = 1:N
                    ami(j) = AMI_Stergiou(imuSeg, imuOpal(j:j + length(imuSeg) - 1));
                end
                [~, l_ami] = max(ami);
            elseif strcmp(crop, 'UC')
                lag_ami = -100:100;
                ami = zeros(length(lag_ami), 1);
                if length(imuOpal) < length(imuSeg)
                    N = length(imuOpal);
                else
                    N = length(imuSeg);
                end
                if N <= 100
                    data.res.(files{i}).(objName).data.AMILag = NaN;
                    data.res.(files{i}).(objName).data.AMILagQ = NaN;
                    data.res.(files{i}).(objName).data.AMI = NaN;
                    data.res.(files{i}).(objName).data.XCorrLag = NaN;
                    data.res.(files{i}).(objName).data.XCorrLagQ = NaN;
                    data.res.(files{i}).(objName).data.XCorr = NaN;
                    data.res.(files{i}).(objName).data.AffectedSide = NaN;
                    continue
                end
                for j = -100:100
                    if j < 0
                        aD = 1;
                        bD = N + j + 1;
                        aO = -j;
                        bO = N;
                    elseif j == 0
                        aD = 1;
                        bD = N;
                        aO = 1;
                        bO = N;
                    elseif j > 0
                        aD = j;
                        aO = 1;
                        bD = N;
                        bO = N - j + 1;
                    end
                    ami(j + 101,1) = AMI_Stergiou(imuSeg(aD:bD), imuOpal(aO:bO));
                end
                [~, l_ami] = max(ami);
                l_ami = lag_ami(l_ami);
            end

            [r, l] = xcorr(imuOpal, imuSeg);
            [~, lag] = max(r);
            ind_r = l(lag);

            if contains(sig, 'GYRO') && contains(sig, 'VL')
                objName = [crop{1} '_thi_gyr'];
            elseif contains(sig, 'ACC') && contains(sig, 'tib')
                objName = [crop{1} '_tib_acc'];
            elseif contains(sig, 'GYRO') && contains(sig, 'tib')
                objName = [crop{1} '_tib_gyr'];
            elseif contains(sig, 'ACC') && contains(sig, 'VL')
                objName = [crop{1} '_thi_acc'];
            elseif contains(sig, 'CGAcc')
                objName = [crop{1} '_CGAcc'];
            elseif contains(sig, 'AngVel')
                objName = [crop{1} '_AngVel'];
            end

            data.res.(files{i}).(objName).data.AMILag = l_ami;
            data.res.(files{i}).(objName).data.AMILagQ = l_ami/N;
            data.res.(files{i}).(objName).data.AMI = max(ami);
            data.res.(files{i}).(objName).data.XCorrLag = ind_r;
            data.res.(files{i}).(objName).data.XCorrLagQ = ind_r/length(imuOpal);
            data.res.(files{i}).(objName).data.XCorr = xcorr(ind_r);
            data.res.(files{i}).(objName).data.AffectedSide = side;

            H = figure('visible', 'off', 'Units', 'Normalized', 'Position', [0 0 1 1]);

            ax(1) = subplot(3,1,1);
            range_opal = ind_r:ind_r + length(time_Seg) - 1;
            range_opal(length(imuSeg) + 1:end) = [];
            range_opal(range_opal > length(time_Opal)) = [];
            range_opal(range_opal < 1) = [];
            if strcmp(crop, 'CR')
%                 plot(time_Opal, imuOpal, 'k', time_Opal(l_ami:l_ami + length(time_Delsys) - 1), imuDelsys, 'r--', time_Opal(range_opal), imuDelsys(1:length(range_opal)), 'b--')
                plot(time_Opal, imuOpal, 'k', time_Opal(range_opal), imuSeg(1:length(range_opal)), 'b--')
            elseif strcmp(crop, 'UC')
                if l_ami < 0
                    plot(time_Opal, imuOpal, 'k', time_Opal(1:N + l_ami), imuSeg(-l_ami + 1:N), 'r--', time_Opal(range_opal), imuSeg(1:length(range_opal)), 'b--')
                elseif l_ami >= 0
                    plot(time_Opal, imuOpal, 'k', time_Opal(1:N - l_ami), imuSeg(l_ami + 1:N), 'r--', time_Opal(range_opal), imuSeg(1:length(range_opal)), 'b--')
                end
            end
            xlabel('Time (s)')
            ylabel({'Normalized';'Magnitude'})
            yticklabels('')
            legend('Original', 'XCORR', 'Location', 'northwest')
            axis tight
            switch signal
                case 'CGAcc'
                    title('Pelvis CoM matched to APDM Lumbar through acceleration')
                case 'AngVel'
                    title('Thigh Angular Velocity matched to APDM Thigh IMU gyration')
            end

            ax(2) = subplot(3,1,2);
            ax(3) = copyobj(ax(1), H);
            ax(3).Position = ax(2).Position;
            delete(ax(2))
            title('Overlap View')
            xlim([min(time_Opal(range_opal)), max(time_Opal(range_opal))])
            yticklabels('');


%             subplot(2,2,3)
%             plot(lag_ami, ami, 'r', [l_ami; l_ami], [min(ami); max(ami)], 'k')
%             axis tight
%             xlabel('Lag')
%             ylabel('Average Mutual Information')

            subplot(3,1,3)
            plot(l, r, 'b', [l(lag); l(lag)], [min(r); max(r)], 'k')
            axis tight
            xlabel('Lag')
            ylabel('Cross Correlation')
            title(['Lag = ' num2str(ind_r)])

%             G = figure;
%             subplot(411),plot(time_Opal, data.raw.(files{i}).(opal).data.(sig_opal)(:,3), 'k', time_Opal(range_opal), data.raw.(files{i}).(obj{ind}).data.(signal)(1:length(range_opal),2), 'b')
%             subplot(412),plot(time_Opal, -data.raw.(files{i}).(opal).data.(sig_opal)(:,2), 'k', time_Opal(range_opal), data.raw.(files{i}).(obj{ind}).data.(signal)(1:length(range_opal),1), 'b')
%             subplot(413),plot(time_Opal, -data.raw.(files{i}).(opal).data.(sig_opal)(:,1), 'k', time_Opal(range_opal), data.raw.(files{i}).(obj{ind}).data.(signal)(1:length(range_opal),3), 'b')
%             subplot(414),plot(time_Opal, imuOpal, 'k', time_Opal(range_opal), imuSeg, 'b')

            saveas(H, [app.Database.Value '\Figures\Figure02_' files{i} '_' objName '.jpg'])
            close(H)

        end

    end

    if rem(i, 10) == 0
        app.printLog('024', [num2str(i) ' of ' num2str(length(files)) ' analyzed']);
    end

end

analysisComplete(app, data, analysis)

end