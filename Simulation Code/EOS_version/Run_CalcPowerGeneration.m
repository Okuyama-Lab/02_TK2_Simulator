%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Last update ：2024/01/29
% Name : Keigo Mutsuo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all

addpath('function');  % 補助関数フォルダを追加

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

Calc_PowerGeneration(data,DT)