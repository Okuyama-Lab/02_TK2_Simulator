%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 太陽ベクトルを使用せず、1周期あたりの発電量（Wh）と日照/日陰時間を固定値として仮定し、
% 電力収支（バッテリーSOC）を解析する簡易シミュレーション。
%
% 引数 :
%   DT               - タイムステップ [秒]
%   Wh_per_orbit     - 1周期あたりの総発電量 [Wh]
%
% 仕様 :
%   ・1軌道周期 = 60分日照 + 40分日陰（100分 = 6000秒）
%   ・日照時間に限り定数Wで発電（例：7Wh ÷ 1h = 7W）
%
% Last update ：2025/07/10
% Developer Name : Keigo Mutsuo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Analyze_Battery_SOC(DT, Wh_per_orbit)

    %% === 出力フォルダの作成 ===
    outdir = 'output';
    if ~exist(outdir, 'dir')
        mkdir(outdir);
    end

    %% === データ読み込み ===
    data_orbit       = readtable(fullfile(outdir,'Result_Orbit.xlsx'), 'VariableNamingRule', 'preserve');
    data_consumption = readtable('TK2_Power_Consumption.xlsx', 'VariableNamingRule', 'preserve');

    % === 時間ベクトルの取得 ===
    % === 解析開始時刻と終了時刻（秒単位） ===
    start_time = 0;              % 秒で定義（例：0秒）
    end_time   = 7 * 24 * 3600;

    % === 日照・日陰パラメータ（秒）===
    illumination_sec = 60 * 60;
    eclipse_sec = 40 * 60;
    T_orbit = illumination_sec + eclipse_sec;

    % === 時間ベクトル ===
    time = (start_time : DT : end_time).';
    N = length(time);

    % === 日陰区間を計算 ===
    num_periods = floor((end_time - start_time) / T_orbit) + 1;
    eclips_start = zeros(num_periods, 1);
    eclips_end   = zeros(num_periods, 1);

    for k = 1:num_periods
       base_time = (k-1) * T_orbit;
       eclips_start(k) = base_time + illumination_sec;
       eclips_end(k)   = base_time + T_orbit;
    end

    % === 範囲外カット ===
    valid_idx = (eclips_start <= end_time);
    eclips_start = eclips_start(valid_idx);
    eclips_end   = eclips_end(valid_idx);

    T_orbit = illumination_sec + eclipse_sec;  % 1周期 = 100分 = 6000秒

    % === 発電出力の計算 ===
    Const_Generation_W = Wh_per_orbit / (illumination_sec / 3600);  % 例：7Wh ÷ 1h = 7W

    % === Powerベクトルの生成（周期的にON/OFF） ===
    Power = zeros(N, 1);
    for i = 1:N
        t_mod = mod(time(i), T_orbit);
        if t_mod < illumination_sec
            Power(i) = Const_Generation_W;  % 日照中
        else
            Power(i) = 0;  % 日陰中
        end
    end

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
       m_start_time = mission_start_times(k);
       m_end_time   = mission_end_times(k);
       m_state      = mission_states(k);
       if isnan(m_start_time) || isnan(m_end_time) || isnan(m_state)
          continue
       end
       logic_idx = (time >= m_start_time) & (time <= m_end_time);
       mission_state_array(logic_idx) = m_state;
    end

    %% === i=1 のときの状態にも初期消費電力を反映 ===
    state = mission_state_array(1);
    if isKey(mode_map, state)
        P_consumption = mode_map(state);
    else
        P_consumption = mode_map(1); % fallback
    end
    Total_power_log(1) = P_consumption;

    %% === バッテリー更新ループ ===
    DOD_Threshold_Wh = Max_capacity_Wh * 0.3;
    emergency_active = false;
    emergency_counter = 0;

    for i = 2:length(time)
       SOC_current = battery(i-1);
       state = mission_state_array(i);

       if emergency_active
          if SOC_current >= DOD_Threshold_Wh
             state = 1;
             mission_state_array(i) = 1;
             emergency_active = false;
          else
             state = 3;
             mission_state_array(i) = 3;
          end
       elseif SOC_current < DOD_Threshold_Wh
          state = 3;
          mission_state_array(i) = 3;
          emergency_active = true;
          emergency_counter = emergency_counter + 1;
       elseif emergency_counter >= 1
          state = 1;
          mission_state_array(i) = 1;
       end

       if isKey(mode_map, state)
          P_consumption = mode_map(state);
       else
          P_consumption = mode_map(1); % fallback
       end

       total_power = P_consumption;
       Total_power_log(i) = total_power;

       cons_Wh = total_power * DT / 3600;
       gen_Wh  = Power(i) * DT / 3600;

       battery(i) = battery(i-1) + gen_Wh - cons_Wh;
       battery(i) = min(max(battery(i), 0), Max_capacity_Wh);
       Capacity(i) = battery(i) / voltage * 1000;

       disp(['現在の解析時間：' num2str(time(i)) ' 秒']);
    end

    %% === グラフ①：バッテリーSOC ===
    figure;
    plot(time, Capacity);
    xregion(eclips_start, eclips_end);
    hold on;
    yline(Max_capacity_mAh, '--k', sprintf('Max: %.0fmAh', Max_capacity_mAh));
    yline(Max_capacity_mAh * 0.3, '-.r', 'DOD: 70%');
    ylim([0 10000]);
    xlim([0 end_time]);
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
    xlim([0 end_time]);
    xlabel('Time [s]');
    ylabel('Power [W]');
    title('Total Power Consumption');
    setGraghStyle_B();
    saveas(gcf, fullfile(outdir, 'PowerConsumption_History.png'));
    saveas(gcf,fullfile(outdir,'PowerConsumption_History.fig'));

    %% === グラフ③：発電量履歴 ===
    figure;
    plot(time, Power);
    xlim([0 end_time]);
    ylim([0 Wh_per_orbit+1])
    xlabel('Time [s]');
    ylabel('Power [W]');
    title('Total Power Generation (Simplified Model)');
    setGraghStyle_B();
    saveas(gcf, fullfile(outdir, 'PowerGeneration_History.png'));
    saveas(gcf,fullfile(outdir,'PowerGeneration_History.fig'));

    %% === 総消費電力ログ保存 ===
    T_power = table(time, Total_power_log, 'VariableNames', {'Time_s', 'Total_Power_W'});
    writetable(T_power, fullfile(outdir, 'TotalPowerConsumption_Log.xlsx'));
    disp('出力結果を output フォルダに保存しました。');
end