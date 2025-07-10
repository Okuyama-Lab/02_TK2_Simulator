%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STKから出力された太陽ベクトルを用いて、発電量を計算し、MATLAB（SGP4)を用いて計算した地上局可視解析結果から
% 地上局通信を模擬し、それによる電力収支解析を実施するプログラムです。
% 引数 : DT - タイムステップ [秒]
% Last update ：2025/07/09
% Developper Name : Keigo Mutsuo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Analyze_Battery_SOC(DT)

    %% === 出力フォルダの作成 ===
    outdir = 'output';
    if ~exist(outdir, 'dir')
        mkdir(outdir);
    end

    %% === Powerデータの選択 ===
    [power_file, power_path] = uigetfile('*.xlsx', 'Select Power Excel File');
    if isequal(power_file, 0)
        disp('User canceled file selection.');
        return;
    end

    %% === データ読み込み ===
    data_power       = readtable(fullfile(power_path, power_file), 'VariableNamingRule', 'preserve');
    data_orbit       = readtable(fullfile(outdir,'Result_Orbit.xlsx'), 'VariableNamingRule', 'preserve');
    data_consumption = readtable('TK2_Power_Consumption.xlsx', 'VariableNamingRule', 'preserve');

    % === 時刻と発電量取得 ===
    time = data_power{:, "Time(s)"};
    Pow_sum = data_power{:, {'Pow_x_pos','Pow_x_neg','Pow_y_pos','Pow_y_neg','Pow_z_pos','Pow_z_neg'}};
    Power = sum(Pow_sum, 2); % 発電量 [W]

    % === missionデータ ===
    mission_start_times = data_orbit{:, "mission start time"};
    mission_end_times   = data_orbit{:, "mission end time"};
    mission_states      = data_orbit{:, "mission states"};

    %% === バッテリー初期設定 ===
    voltage = 3.6;
    Max_capacity_Wh = (3200 * 1e-3 * voltage) * 3;
    Max_capacity_mAh = Max_capacity_Wh / voltage * 1000;
    battery = zeros(length(time), 1);
    battery(1) = Max_capacity_Wh;
    Capacity = zeros(length(time), 1);
    Capacity(1) = Max_capacity_mAh;

    Total_power_log = zeros(length(time), 1);  % 消費電力履歴

    %% === 消費電力マッピング ===
    mode_numbers = data_consumption{:,1};
    mode_power = data_consumption{:,3};
    mode_map = containers.Map(mode_numbers, mode_power);

    mission_state_array = ones(length(time),1);
    for k = 1:height(data_orbit)
        start_time = mission_start_times(k);
        end_time   = mission_end_times(k);
        m_state    = mission_states(k);
        if isnan(start_time) || isnan(end_time) || isnan(m_state)
            continue
        end
        logic_idx = (time >= start_time) & (time <= end_time);
        mission_state_array(logic_idx) = m_state;
    end

    %% === i=1 のときの状態にも初期消費電力を反映 ===
    state = mission_state_array(1);
    if isKey(mode_map, state)
        P_consumption = mode_map(state);
    else
        P_consumption = mode_map(1); % ノミナル消費電力
    end
    Total_power_log(1) = P_consumption;

    %% === バッテリー更新ループ ===
    DOD_Threshold_Wh = Max_capacity_Wh * 0.3;
    emergency_active = false;
    emergency_counter = 0;

    for i = 2:length(time)
       % --- 現在のSOC（Wh）
       SOC_current = battery(i-1);
       % --- 状態取得（元の状態）
       state = mission_state_array(i);

       % === 状態自動遷移ロジック ===
       if emergency_active
          if SOC_current >= DOD_Threshold_Wh
             % SOCが30%以上に回復 → ノミナルに戻す
             state = 1;
             mission_state_array(i) = 1;
             emergency_active = false;
          else
             % まだエマージェンシー継続
             state = 3;
             mission_state_array(i) = 3;
          end
       elseif SOC_current < DOD_Threshold_Wh
          % 初めて or 再度エマージェンシーに突入
          state = 3;
          mission_state_array(i) = 3;
          emergency_active = true;
          emergency_counter = emergency_counter + 1;
       elseif emergency_counter >= 1
          % エマージェンシーを1度でも経験後は、常にノミナルに設定する
          state = 1;
          mission_state_array(i) = 1;
       end

       % === 消費電力 ===
       if isKey(mode_map, state)
          P_consumption = mode_map(state);
       else
          P_consumption = mode_map(1); % fallback
       end

       % === 合計消費電力 ===
       total_power = P_consumption;
       Total_power_log(i) = total_power;

       % === バッテリー更新 ===
       cons_Wh = total_power * DT / 3600;
       gen_Wh  = Power(i) * DT / 3600;

       battery(i) = battery(i-1) + gen_Wh - cons_Wh;
       battery(i) = min(max(battery(i), 0), Max_capacity_Wh);
       Capacity(i) = battery(i) / voltage * 1000;
       disp(['現在の解析時間：' num2str(time(i)) ' 秒']);
    end

    %% === 日照・日陰区間判定 ===
    Vec_x = data_power{:,2};
    Vec_y = data_power{:,3};
    Vec_z = data_power{:,4};

    Magnitude = double(~(Vec_x == 0 & Vec_y == 0 & Vec_z == 0));
    eclips_time = time(Magnitude == 0);
    diff_data_e = diff(eclips_time);
    break_idx_e = find(diff_data_e ~= DT);
    eclips_start = [eclips_time(1); eclips_time(break_idx_e+1)];
    eclips_end   = [eclips_time(break_idx_e); eclips_time(end)];

    %% === グラフ①：バッテリーSOC ===
    figure;
    plot(time, Capacity);
    xregion([eclips_start], [eclips_end])
    hold on;
    yline(Max_capacity_mAh, '--k', sprintf('Max: %.0fmAh', Max_capacity_mAh));
    yline(Max_capacity_mAh * 0.3, '-.r', 'DOD: 70%');
    ylim([0 10000]); 
    xlabel('Time [s]');
    ylabel('Battery Capacity [mAh]');
    title('Battery State of Charge (SOC)');
    setGraghStyle_B();
    legend(["SOC [mAh]", "Max Capacity"], "FontSize", 15, "Position", [0.7288 0.9336 0.1760, 0.0588])
    hConstantline = findobj(gcf,"Type","constantline");
    hConstantline(2).LineWidth = 1.5000;
    hConstantline(2).FontSize = 15;
    hConstantline(1).LineWidth = 1.5000;
    hConstantline(1).FontSize = 15;
    saveas(gcf, fullfile(outdir, 'Battery_SOC.png'));
    saveas(gcf,fullfile(outdir,'Battery_SOC.fig'));

    %% === グラフ②：消費電力履歴 ===
    figure;
    plot(time, Total_power_log);
    xlabel('Time [s]');
    ylabel('Power [W]');
    title('Total Power Consumption');
    setGraghStyle_B();
    saveas(gcf, fullfile(outdir, 'PowerConsumption_History.png'));
    saveas(gcf,fullfile(outdir,'PowerConsumption_History.fig'));

    %% === グラフ③：発電量履歴 ===
    figure;
    plot(time, Power);
    xlabel('Time [s]');
    ylabel('Power [W]');
    title('Total Power Generation');
    setGraghStyle_B();
    saveas(gcf, fullfile(outdir, 'PowerGeneration_History.png'));
    saveas(gcf,fullfile(outdir,'PowerGeneration_History.fig'));

    %% === 総消費電力ログ保存 ===
    T_power = table(time, Total_power_log, 'VariableNames', {'Time_s', 'Total_Power_W'});
    writetable(T_power, fullfile(outdir, 'TotalPowerConsumption_Log.xlsx'));
    disp('出力結果を output フォルダに保存しました。');
end