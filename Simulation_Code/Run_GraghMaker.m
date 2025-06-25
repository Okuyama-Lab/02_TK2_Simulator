%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

MakeGragh(data)