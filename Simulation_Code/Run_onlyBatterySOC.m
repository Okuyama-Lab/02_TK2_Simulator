%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This simulation file is a script that calculates solar power generation and 
% battery SOC, etc. from the output results of CubeSpace's EOS simulator.
% Last update ：2024/01/29
% Name : Keigo Mutsuo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

warning('off')
clear
close all

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

Caluc_PowerGeneration(data,DT)
Caluc_PowerConsumption_ADCS(data)
MakeGragh(data)

response = input("Result_Orbit.xlsx の準備ができたら 1 を入力: ");

if response == 1
   Analyze_Battery_SOC(DT);
else
   disp("キャンセルされました。バッテリー解析は実行されませんでした。");
end