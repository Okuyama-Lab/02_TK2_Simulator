%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Last update ：2024/01/29
% Name : Keigo Mutsuo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all

addpath('function');  % 補助関数フォルダを追加

%% === 要素数と時間間隔 ===
prompt = "What is the DT value? ";
DT = input(prompt);

response = input("Result_Orbit.xlsx の準備ができたら 1 を入力: ");

if response == 1
   Analyze_Battery_SOC(DT);
else
   disp("キャンセルされました。バッテリー解析は実行されませんでした。");
end