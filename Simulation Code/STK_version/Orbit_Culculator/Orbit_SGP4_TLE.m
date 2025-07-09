%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Last update ：2024/01/29
% Name : Keigo Mutsuo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ==== 出力フォルダの作成 ====
outdir = 'output';
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

% ==== TLEファイル保存 ====
tleText = [
"1 25544U 98067A   25175.76713781  .00009265  00000-0  16877-3 0  9994"
"2 25544  51.6388 269.5022 0001927 277.8753 226.8979 15.50227804516332"
];
tleFile = fullfile(tempdir, 'ISS.tle');
fid = fopen(tleFile, 'w');
fprintf(fid, '%s\n', tleText);
fclose(fid);

% ==== シナリオ作成 ====
startTimeJST = datetime(2025,6,25,0,0,0,'TimeZone','Asia/Tokyo');
stopTime = startTimeJST + days(1);
sampleTime = 1;  % [s]
sc = satelliteScenario(startTimeJST, stopTime, sampleTime);

% ==== 衛星追加 ====
sat = satellite(sc, tleFile);

% ==== 地上局 ====
% 日本大学理工学部 航空宇宙工学科 35.72476582064593, 140.05691485473042
gs = groundStation(sc, ...
    'Latitude', 35.72476582064593, ...
    'Longitude', 140.05691485473042, ...
    'Altitude', 0, ...
    'Name', 'Nihon University', ...
    'MinElevationAngle', 15);

% ==== アクセス解析 ====
ac = access(gs, sat);

% ==== 可視時間の取得 ====
visTimes = accessIntervals(ac);

% ==== 秒換算 ====
startTimeJSTs = visTimes.StartTime;
endTimeJSTs = visTimes.EndTime;
startTimeJSTs.TimeZone = 'Asia/Tokyo';
endTimeJSTs.TimeZone = 'Asia/Tokyo';

startSec = round(seconds(visTimes.StartTime - startTimeJST));
endSec   = round(seconds(visTimes.EndTime - startTimeJST));
durationSec = endSec - startSec;

n = height(visTimes);

% ==== データ列を作成 ====
data1 = [ ...
    cellstr(visTimes.Source), ...
    cellstr(visTimes.Target), ...
    num2cell(visTimes.IntervalNumber), ...
    cellstr(string(startTimeJSTs)), ...
    cellstr(string(endTimeJSTs)), ...
    num2cell(startSec), ...
    num2cell(endSec), ...
    num2cell(durationSec), ...
    cell(n,1), ...  % mission states
    cell(n,1), ...  % mission duration
    cell(n,1), ...  % mission start time
    cell(n,1)  ...  % mission end time
];

% ==== ヘッダー定義 ====
header = {'Source','Target','Interval','StartTime','EndTime', ...
          'StartTimeSec','EndTimeSec','Duration','mission states', ...
          'mission duration','mission start time','mission end time'};

% ==== 結合して書き出し ====
output = [header; data1];
writecell(output, fullfile(outdir, 'Result_Orbit.xlsx'));
disp("出力完了：output/Result_Orbit.xlsx");