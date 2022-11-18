function app = analysis_V3DAPDMAlignment(app, data, analysis)

dbstop if error

files = fieldnames(data.raw);
for i = 1:length(files)

    for crop = {'CR', 'UC'}

        for sig = {'imu_oa_tib_ACC_X', 'imu_oa_tib_GYRO_X', 'EMG_VL_ACC_X', 'EMG_VL_GYRO_X'}
            obj = fieldnames(data.raw.(files{i}));
            
            if strcmp(crop, 'CR') && any(contains(obj, sig))
                ind = find(contains(obj, sig));
                sig2 = fieldnames(data.raw.(files{i}).(obj{ind}).data);
                imuDelsys = sqrt(data.raw.(files{i}).(obj{ind}).data.ANALOG.^2 + data.raw.(files{i}).([obj{ind}(1:end-1) 'Y']).data.ANALOG.^2 + data.raw.(files{i}).([obj{ind}(1:end-1) 'Y']).data.ANALOG.^2);
                imuDelsys_freq = data.raw.(files{i}).(obj{ind}).freq;
            elseif strcmp(crop, 'UC') && isfield(data.raw.(files{i}), 'DelsysTrignoSDK')
                sig2 = fieldnames(data.raw.(files{i}).DelsysTrignoSDK.data);
                signal = sig2{contains(sig2, sig)};
                imuDelsys = sqrt(data.raw.(files{i}).DelsysTrignoSDK.data.(signal).^2 + data.raw.(files{i}).DelsysTrignoSDK.data.([signal(1:end-1) 'Y']).^2 + data.raw.(files{i}).DelsysTrignoSDK.data.([signal(1:end-1) 'Z']).^2);
                imuDelsys_freq = data.raw.(files{i}).DelsysTrignoSDK.freq;
            else
                continue
            end

            if isempty(imuDelsys_freq)
                imuDelsys_freq = 2000;
            end

            if contains(sig, 'GYR') && contains(sig, 'VL')
                objName = [crop{1} '_thi_gyr'];
            elseif contains(sig, 'ACC') && contains(sig, 'tib')
                objName = [crop{1} '_tib_acc'];
            elseif contains(sig, 'GYR') && contains(sig, 'tib')
                objName = [crop{1} '_tib_gyr'];
            elseif contains(sig, 'ACC') && contains(sig, 'VL')
                objName = [crop{1} '_thi_acc'];
            end

            ind = find(contains(obj, 'AffectedSide'));
            if isempty(ind)
                ind = find(contains(obj, 'METRIC'));
            end

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

            if contains(obj{ind}, 'AffectedSide')
                if data.raw.(files{i}).(obj{ind}).data.METRIC == 0
                    side = 'L';
                elseif data.raw.(files{i}).(obj{ind}).data.METRIC == 1
                    side = 'R';
                end
            elseif contains(obj{ind}, 'METRIC')
                if data.raw.(files{i}).(obj{ind}).data.AffectedSide == 0
                    side = 'L';
                elseif data.raw.(files{i}).(obj{ind}).data.AffectedSide == 1
                    side = 'R';
                end
            end

            if contains(sig, 'tib') && side == 'L'
                opal = 'Left_Lower_Leg';
            elseif contains(sig, 'tib') && side == 'R'
                opal = 'Right_Lower_Leg';
            elseif contains(sig, 'VL') && side == 'L'
                opal = 'Left_Upper_Leg';
            elseif contains(sig, 'VL') && side == 'R'
                opal = 'Right_Upper_Leg';
            end

            if contains(sig, 'ACC')
                sig_opal = 'acc';
            elseif contains(sig, 'GYRO')
                sig_opal = 'gyr';
            end

            imuOpal = sqrt((data.raw.(files{i}).(opal).data.(sig_opal)(:, 1)).^2 + (data.raw.(files{i}).(opal).data.(sig_opal)(:, 2)).^2 + (data.raw.(files{i}).(opal).data.(sig_opal)(:, 3)).^2);
            imuOpal_freq = data.raw.(files{i}).(opal).freq;

            if ~isinteger(imuOpal_freq)
                fprintf('rounding sampliog rate to %i from %f\n', round(imuOpal_freq), imuOpal_freq)
                imuOpal_freq = round(imuOpal_freq);
            end

            imuDelsys = resample(imuDelsys, imuOpal_freq, imuDelsys_freq);

            time_Delsys = (0:length(imuDelsys) - 1)'/imuOpal_freq;
            time_Opal = (0:length(imuOpal) - 1)'/imuOpal_freq;

            imuDelsys = (imuDelsys - min(imuDelsys))/range(imuDelsys);
            imuOpal = (imuOpal - min(imuOpal))/range(imuOpal);

            if strcmp(crop, 'CR')
                N = length(imuOpal) - length(imuDelsys);
                lag_ami = 1:N;
                ami = zeros(N, 1);
                for j = 1:N
                    ami(j) = AMI_Stergiou(imuDelsys, imuOpal(j:j + length(imuDelsys) - 1));
                end
                [~, l_ami] = max(ami);
            elseif strcmp(crop, 'UC')
                lag_ami = -100:100;
                ami = zeros(length(lag_ami), 1);
                if length(imuOpal) < length(imuDelsys)
                    N = length(imuOpal);
                else
                    N = length(imuDelsys);
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
                    ami(j + 101,1) = AMI_Stergiou(imuDelsys(aD:bD), imuOpal(aO:bO));
                end
                [~, l_ami] = max(ami);
                l_ami = lag_ami(l_ami);
            end

            [r, l] = xcorr(imuOpal, imuDelsys);
            [~, lag] = max(r);
            ind_r = l(lag);

            data.res.(files{i}).(objName).data.AMILag = l_ami;
            data.res.(files{i}).(objName).data.AMILagQ = l_ami/N;
            data.res.(files{i}).(objName).data.AMI = max(ami);
            data.res.(files{i}).(objName).data.XCorrLag = ind_r;
            data.res.(files{i}).(objName).data.XCorrLagQ = ind_r/length(imuOpal);
            data.res.(files{i}).(objName).data.XCorr = xcorr(ind_r);
            data.res.(files{i}).(objName).data.AffectedSide = side;

            H = figure('visible', 'off', 'Units', 'Normalized', 'Position', [0 0 1 1]);

            ax(1) = subplot(3,1,1);
            range_opal = ind_r:ind_r + length(time_Delsys) - 1;
            range_opal(length(imuDelsys) + 1:end) = [];
            range_opal(range_opal > length(time_Opal)) = [];
            range_opal(range_opal < 1) = [];
            if strcmp(crop, 'CR')
                plot(time_Opal, imuOpal, 'k', time_Opal(l_ami:l_ami + length(time_Delsys) - 1), imuDelsys, 'r--', time_Opal(range_opal), imuDelsys(1:length(range_opal)), 'b--')
            elseif strcmp(crop, 'UC')
                if l_ami < 0
                    plot(time_Opal, imuOpal, 'k', time_Opal(1:N + l_ami), imuDelsys(-l_ami + 1:N), 'r--', time_Opal(range_opal), imuDelsys(1:length(range_opal)), 'b--')
                elseif l_ami >= 0
                    plot(time_Opal, imuOpal, 'k', time_Opal(1:N - l_ami), imuDelsys(l_ami + 1:N), 'r--', time_Opal(range_opal), imuDelsys(1:length(range_opal)), 'b--')
                end
            end
            xlabel('Time (s)')
            ylabel({'Normalized';'Magnitude'})
            yticklabels('')
            legend('Original', 'AMI', 'XCORR', 'Location', 'northwest')
            switch sig_opal
                case 'acc'
                    title('Mocap matched to APDM through IMU acceleration')
                case 'gyr'
                    title('Mocap matched to APDM through IMU gyration')
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

            saveas(H, [app.Database.Value '\Figures\Figure01_' files{i} '_' objName '.jpg'])
            close(H)

        end

    end

    if rem(i, 10) == 0
        app.printLog('024', [num2str(i) ' of ' num2str(length(files)) ' analyzed']);
    end

end

analysisComplete(app, data, analysis)

end