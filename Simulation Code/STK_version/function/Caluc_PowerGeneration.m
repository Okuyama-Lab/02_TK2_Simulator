function Caluc_PowerGeneration(data, DT)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function calculates TK2 power generation from CubeSpace EOS simulator results.
% Outputs orbit-wise and time-resolved power data, plots by efficiency level.
% Last update ：2025/07/07
% Name : Keigo Mutsuo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% === 出力先フォルダの作成 ===
    outdir = 'output';
    if ~exist(outdir, 'dir')
        mkdir(outdir);
    end

    %% === 定数・初期設定 ===
    n = size(data, 1);
    Pos_x = 0;
    Neg_x = 0;
    Pos_y = 26.5e-4 * 5;
    Neg_y = 26.5e-4 * 5;
    Pos_z = 26.5e-4 * 12;
    Neg_z = 26.5e-4 * 12;
    efficiency = 27.7 / 100;
    Pow_sun = 1366.1;

    time  = data(:,1);
    Vec_x = data(:,2);
    Vec_y = data(:,3);
    Vec_z = data(:,4);

    Magnitude = double(~(Vec_x == 0 & Vec_y == 0 & Vec_z == 0));

    sunlit_time = time(Magnitude ~= 0);
    diff_data = diff(sunlit_time);
    break_idx = find(diff_data ~= DT);
    sunlit_start = [sunlit_time(1); sunlit_time(break_idx+1)];
    sunlit_end   = [sunlit_time(break_idx); sunlit_time(end)];
    sunlit_dur_h = (sunlit_end - sunlit_start) / 3600;

    eclips_time = time(Magnitude == 0);
    diff_data_e = diff(eclips_time);
    break_idx_e = find(diff_data_e ~= DT);
    eclips_start = [eclips_time(1); eclips_time(break_idx_e+1)];
    eclips_end   = [eclips_time(break_idx_e); eclips_time(end)];
    eclips_dur_h = (eclips_end - eclips_start) / 3600;

    %% === 効率パターンごとの処理 ===
    eff_range = 0.5:0.1:1.0;
    column_names = {'Time(s)', 'Vec_x', 'Vec_y', 'Vec_z', ...
        'Pow_x_pos', 'Pow_x_neg', 'Pow_y_pos', 'Pow_y_neg', ...
        'Pow_z_pos', 'Pow_z_neg', 'Pow_sum(W)', 'Pow_sum(Wh)', ...
        'Pow_sum_orbit(Wh)', 'sunlit_start', 'sunlit_end', 'sunlit_time', ...
        'eclips_start', 'eclips_end', 'eclips_time', ...
        'Min_power', 'Max_power', 'Ave_power', ...
        'Min_sunlit_time', 'Max_sunlit_time', 'Ave_sunlit_time'};

    plots_data = cell(length(eff_range), 1);

    parfor idx = 1:length(eff_range)
        Generation_Efficiency = eff_range(idx);
        eff_str = sprintf('%.0f', Generation_Efficiency * 100);
        folder_name = ['Efficiency_' eff_str '%'];
        output_subdir = fullfile(outdir, folder_name);
        if ~exist(output_subdir, 'dir')
            mkdir(output_subdir);
        end

        filename = ['Power_' eff_str '%.xlsx'];
        fullfile_out = fullfile(output_subdir, filename);

        scale = Pow_sun * efficiency * Generation_Efficiency;

        x_neg = Vec_x < 0; x_pos = ~x_neg;
        y_neg = Vec_y < 0; y_pos = ~y_neg;
        z_neg = Vec_z < 0; z_pos = ~z_neg;

        Pow_x_pos = zeros(n,1); Pow_x_neg = zeros(n,1);
        Pow_y_pos = zeros(n,1); Pow_y_neg = zeros(n,1);
        Pow_z_pos = zeros(n,1); Pow_z_neg = zeros(n,1);

        Pow_x_pos(x_neg) = -Vec_x(x_neg) * Pos_x * scale;
        Pow_x_neg(x_pos) =  Vec_x(x_pos) * Neg_x * scale;

        Pow_y_pos(y_neg) = -Vec_y(y_neg) * Pos_y * scale;
        Pow_y_neg(y_pos) =  Vec_y(y_pos) * Neg_y * scale;

        Pow_z_pos(z_neg) = -Vec_z(z_neg) * Pos_z * scale;
        Pow_z_neg(z_pos) =  Vec_z(z_pos) * Neg_z * scale;


        Pow_sum = Pow_x_pos + Pow_x_neg + Pow_y_pos + Pow_y_neg + Pow_z_pos + Pow_z_neg;
        Wh = Pow_sum * DT / 3600;

        % 各軌道の発電量計算
        Wh_cumsum = [0; cumsum(Wh)];
        time_ext = [time(1) - DT; time];
        start_idx = interp1(time_ext, 1:length(time_ext), sunlit_start, 'nearest');
        end_idx   = interp1(time_ext, 1:length(time_ext), sunlit_end, 'nearest');
        Pow_orbit = Wh_cumsum(end_idx) - Wh_cumsum(start_idx);

        summary_data = [min(Pow_orbit), max(Pow_orbit), mean(Pow_orbit), ...
                        min(sunlit_dur_h), max(sunlit_dur_h), mean(sunlit_dur_h)];

        % === ファイル出力 ===
        if exist(fullfile_out, 'file')
            delete(fullfile_out);
        end
        main_data = [time, Vec_x, Vec_y, Vec_z, ...
                     Pow_x_pos, Pow_x_neg, Pow_y_pos, Pow_y_neg, ...
                     Pow_z_pos, Pow_z_neg, Pow_sum, Wh];

        writecell(column_names, fullfile_out, 'Sheet', 1, 'Range', 'A1');
        writematrix(main_data, fullfile_out, 'Sheet', 1, 'Range', 'A2');
        writematrix(Pow_orbit, fullfile_out, 'Sheet', 1, 'Range', 'M2');
        writematrix([sunlit_start, sunlit_end, sunlit_dur_h], fullfile_out, 'Sheet', 1, 'Range', 'N2');
        writematrix([eclips_start, eclips_end, eclips_dur_h], fullfile_out, 'Sheet', 1, 'Range', 'Q2');
        writematrix(summary_data, fullfile_out, 'Sheet', 1, 'Range', 'T2');

        plots_data{idx} = struct( ...
            'eff_str', eff_str, ...
            'output_subdir', output_subdir, ...
            'time', time, ...
            'Pow_x_pos', Pow_x_pos, ...
            'Pow_x_neg', Pow_x_neg, ...
            'Pow_y_pos', Pow_y_pos, ...
            'Pow_y_neg', Pow_y_neg, ...
            'Pow_z_pos', Pow_z_pos, ...
            'Pow_z_neg', Pow_z_neg, ...
            'Pow_sum', Pow_sum ...
        );

        disp([filename ' の出力完了']);
    end

    %% === 描画 ===
    for idx = 1:length(eff_range)
        data = plots_data{idx};

        % --- 面別発電量 ---
        figure;
        plot(data.time, data.Pow_x_pos, ...
             data.time, data.Pow_x_neg, ...
             data.time, data.Pow_y_pos, ...
             data.time, data.Pow_y_neg, ...
             data.time, data.Pow_z_pos, ...
             data.time, data.Pow_z_neg);
        xlabel('Time (s)');
        ylabel('Power (W)');
        title(['Panel Power: Efficiency ' data.eff_str '%']);
        legend('posX', 'negX', 'posY', 'negY', 'posZ', 'negZ');
        setGraghStyle_B();
        saveas(gcf, fullfile(data.output_subdir, ['PanelPower_' data.eff_str '.png']));
        saveas(gcf, fullfile(data.output_subdir, ['PanelPower_' data.eff_str '.fig']));
        close;

        % --- 合計発電量 ---
        figure;
        plot(data.time, data.Pow_sum);
        xlabel('Time (s)');
        ylabel('Power (W)');
        title(['Total Power: Efficiency ' data.eff_str '%']);
        setGraghStyle_B();
        saveas(gcf, fullfile(data.output_subdir, ['TotalPower_' data.eff_str '.png']));
        saveas(gcf, fullfile(data.output_subdir, ['TotalPower_' data.eff_str '.fig']));
        close;
    end
end