function app = analysis_custom(app, data, analysis)

files = fieldnames(data.raw);
for i = 1:length(files)

    if isfield(data.raw.(files{i}), 'ORIGINAL_imu_oa_tib_GYRO_X')

        imuDelsys = sqrt(data.raw.(files{i}).ORIGINAL_imu_oa_tib_GYRO_X.data.ANALOG.^2 + data.raw.(files{i}).ORIGINAL_imu_oa_tib_GYRO_Y.data.ANALOG.^2 + data.raw.(files{i}).ORIGINAL_imu_oa_tib_GYRO_Z.data.ANALOG.^2);
        imuDelsys_freq = data.raw.(files{i}).ORIGINAL_imu_oa_tib_GYRO_X.freq;

        if contains(data.raw.(files{i}).ORIGINAL_imu_oa_tib_GYRO_X.file, '_L')
            side = 'L';
        elseif contains(data.raw.(files{i}).ORIGINAL_imu_oa_tib_GYRO_X.file, '_R')
            side = 'R';
        end

        switch side
            case 'L'
                imuOpal = sqrt((data.raw.(files{i}).Left_Lower_Leg.data.gyr(:, 1)).^2 + (data.raw.(files{i}).Left_Lower_Leg.data.gyr(:, 2)).^2 + (data.raw.(files{i}).Left_Lower_Leg.data.gyr(:, 3)).^2);
                imuOpal_freq = data.raw.(files{i}).Left_Lower_Leg.freq;
            case 'R'
                imuOpal = sqrt((data.raw.(files{i}).Right_Lower_Leg.data.gyr(:, 1)).^2 + (data.raw.(files{i}).Right_Lower_Leg.data.gyr(:, 2)).^2 + (data.raw.(files{i}).Right_Lower_Leg.data.gyr(:, 3)).^2);
                imuOpal_freq = data.raw.(files{i}).Right_Lower_Leg.freq;
        end

        if ~isinteger(imuOpal_freq)
            fprintf('rounding sampliog rate to %i from %f\n', round(imuOpal_freq), imuOpal_freq)
            imuOpal_freq = round(imuOpal_freq);
        end

        imuDelsys = resample(imuDelsys, imuOpal_freq, imuDelsys_freq);

        time_Delsys = (0:length(imuDelsys) - 1)'/imuOpal_freq;
        time_Opal = (0:length(imuOpal) - 1)'/imuOpal_freq;

        imuDelsys = (imuDelsys - min(imuDelsys))/range(imuDelsys);
        imuOpal = (imuOpal - min(imuOpal))/range(imuOpal);

        N = length(imuOpal) - length(imuDelsys);
        ami = zeros(N, 1);
        for j = 1:N
            ami(j) = AMI_Stergiou(imuDelsys, imuOpal(j:j + length(imuDelsys) - 1));
        end
        [~, ind_ami] = max(ami);

        [r, l] = xcorr(imuOpal, imuDelsys);
        [~, lag] = max(r);
        ind_r = l(lag);

        data.res.Sync.(files{i}).imu_oa_tib_GYRO.Lower_Leg.lag_ami = ind_ami;
        data.res.Sync.(files{i}).imu_oa_tib_GYRO.Lower_Leg.ami = ami(ind_ami);
        data.res.Sync.(files{i}).imu_oa_tib_GYRO.Lower_Leg.lag_xcorr = ind_r;
        data.res.Sync.(files{i}).imu_oa_tib_GYRO.Lower_Leg.xcorr = xcorr(ind_r);

        H = figure('visible', 'off');

        subplot(2,2,[1:2])
        plot(time_Opal, imuOpal, 'k', time_Opal(ind_ami:ind_ami + length(time_Delsys) - 1), imuDelsys, 'r--', time_Opal(ind_r:ind_r + length(time_Delsys) - 1), imuDelsys, 'b--')
        xlabel('Time (s)')
        ylabel('Normalized Magnitude')
        legend('Original', 'AMI', 'XCORR')

        subplot(2,2,3)
        plot(1:N, ami, 'r', [ind_ami; ind_ami], [min(ami); max(ami)], 'k')
        axis tight
        xlabel('Lag')
        ylabel('Average Mutual Information')

        subplot(2,2,4)
        plot(l, r, 'b', [l(lag); l(lag)], [min(r); max(r)], 'k')
        axis tight
        xlabel('Lag')
        ylabel('Cross Correlation')

        saveas(H, [app.Database.Value '\Figures\Figure01_' files{i} '.jpg'])

    end

end

analysisComplete(app, data, analysis)

end