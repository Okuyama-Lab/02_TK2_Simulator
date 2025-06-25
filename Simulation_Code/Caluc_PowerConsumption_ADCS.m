%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function calculates both MTQ and RW power consumption
% and logs them to one Excel file in the "output" folder.
% Last update ：2025/06/16
% Name : Keigo Mutsuo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = Caluc_PowerConsumption_ADCS(data)

    time = data(:,3);
    %% === MTQ Parameters ===
    Current_max = [245.8, 293.5, 290.2]; % [mA]
    Volt_MTQ = 5.0;                      % [V]

    PWM = abs(data(:,120:122));         % PWM_x, PWM_y, PWM_z
    MTQ_W = (PWM ./ 0.8) .* (Current_max * 1e-3) * Volt_MTQ;  % n×3行列
    MTQ_x = MTQ_W(:,1);
    MTQ_y = MTQ_W(:,2);
    MTQ_z = MTQ_W(:,3);
    MTQ_sum = sum(MTQ_W, 2);            % 合計 [W]

    %% === RW Parameters（ベクトル化） ===
    Nm = data(:,149:151);
    Hm = data(:,152:154);

    ki = 114.0;
    kn = 1085.0;
    ks = 6000.0 / 30.6e-3;
    kf = 1.0e-4;
    offset = 0.095;

    WheelPow = abs(Nm .* Hm) * (ki * ks / kn) + kf * ks * abs(Hm) + offset;
    RW_x = WheelPow(:,1);
    RW_y = WheelPow(:,2);
    RW_z = WheelPow(:,3);
    RW_sum = sum(WheelPow, 2);

    %% === 合計消費電力（MTQ + RW） ===
    ADCS_total = MTQ_sum + RW_sum;

    %% === 出力フォルダの準備 ===
    outdir = 'output';
    if ~exist(outdir, 'dir')
        mkdir(outdir);
    end
    filename = fullfile(outdir, 'PowerConsumption_ADCS.xlsx');

    if isfile(filename)
        delete(filename);
    end

    %% === テーブル作成と保存 ===
    T = table(time, MTQ_x, MTQ_y, MTQ_z, MTQ_sum, ...
              RW_x, RW_y, RW_z, RW_sum, ...
              ADCS_total, ...
              'VariableNames', {'Time[s]', 'MTQ_x_W', 'MTQ_y_W', 'MTQ_z_W', 'MTQ_sum_W', ...
                                'RW_x_W', 'RW_y_W', 'RW_z_W', 'RW_sum_W', ...
                                'ADCS_total_W'});

    writetable(T, filename);

    disp(['Power consumption log saved as: ', filename]);

    plot(MTQ_sum)
    grid on
    xlabel("Time [s]")
    ylabel("PowerConsumption [W]")
    hAxes = findobj(gcf,"Type","axes");
    hAxes.FontSize = 15;
    hAxes.LineWidth = 1;
    hLine = findobj(gcf,"Type","line");
    hLine.LineWidth = 2;
    saveas(gcf, fullfile(outdir, 'MTQ_PowerConsumption.png'));
    saveas(gcf,fullfile(outdir,'MTQ_PowerConsumption.fig'));
    figure

    plot(RW_sum)
    grid on
    xlabel("Time [s]")
    ylabel("PowerConsumption [W]")
    hAxes = findobj(gcf,"Type","axes");
    hAxes.FontSize = 15;
    hAxes.LineWidth = 1;
    hLine = findobj(gcf,"Type","line");
    hLine.LineWidth = 2;
    saveas(gcf, fullfile(outdir, 'RW_PowerConsumption.png'));
    saveas(gcf,fullfile(outdir,'RW_PowerConsumption.fig'));
end