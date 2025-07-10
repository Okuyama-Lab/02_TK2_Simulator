%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Last update ：2024/01/29
% Name : Keigo Mutsuo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all

addpath('function');  % 補助関数フォルダを追加
addpath('Orbit_Culculator');

%% === EOS出力ファイルの選択　===
[file_name, file_path] = uigetfile('*.csv', 'Select a CSV file');
if isequal(file_name, 0)
    disp('User canceled file selection.');
    return;
end
data = readmatrix(fullfile(file_path, file_name));

%% === 要素数と時間間隔 ===
prompt = "What is the DT value? ";
DT = input(prompt);

% run("Orbit_SGP4_TLE.m");
run("Orbit_SGP4.m");
Calc_PowerGeneration(data,DT);
Calc_PowerConsumption_ADCS(data);

response = input("Result_Orbit.xlsx の準備ができたら 1 を入力: ");

if response == 1
   Analyze_Battery_SOC(DT);
   MakeGragh(data)
else
   disp("キャンセルされました。バッテリー解析は実行されませんでした。");
end