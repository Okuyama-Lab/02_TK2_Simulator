%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Last update ：2024/01/29
% Name : Keigo Mutsuo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ==== 出力フォルダの作成 ====
outdir = 'output';
if ~exist(outdir, 'dir')
    mkdir(outdir);
end


% 既存ファイルの削除（tle と xlsx）
existingTLE = fullfile(outdir, 'generated.tle');
existingXLSX = fullfile(outdir, 'Result_Orbit.xlsx');

if exist(existingTLE, 'file')
    delete(existingTLE);
end
if exist(existingXLSX, 'file')
    delete(existingXLSX);
end

% ==== 軌道要素の設定 ====
sma = 6871e3 + 500e3;        % 軌道長半径 [m]
ecc = 0.0001;                % 離心率
inc = 51.6;                  % 軌道傾斜角 [deg]
RAAN = 0;                    % 昇交点赤経 [deg]
argPeriapsis = 0;            % 近地点引数 [deg]
trueAnomaly = 0;             % 真近点角 [deg]

% ==== JSTのシナリオ開始時刻 ====
startTimeJST = datetime(2025,6,25,0,0,0,'TimeZone','Asia/Tokyo');
stopTime = startTimeJST + days(2);
sampleTime = 1;  % [s]

% ==== TLE生成 ====
tleText = generateTLEfromElements(sma, ecc, inc, RAAN, argPeriapsis, trueAnomaly, startTimeJST);
tleFile = fullfile(outdir, 'generated.tle');
fid = fopen(tleFile, 'w');
fprintf(fid, '%s\n', tleText);
fclose(fid);

% ==== シナリオ作成 ====
sc = satelliteScenario(startTimeJST, stopTime, sampleTime);

% ==== 衛星追加 ====
sat = satellite(sc, tleFile);

% ==== 地上局 ====
gs = groundStation(sc, ...
    'Latitude', 35.72476582064593, ...
    'Longitude', 140.05691485473042, ...
    'Altitude', 0, ...
    'Name', 'Nihon University', ...
    'MinElevationAngle', 0);

% ==== アクセス解析 ====
ac = access(gs, sat);

% ==== 可視時間の取得 ====
visTimes = accessIntervals(ac);

% ==== JSTのまま秒換算 ====
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

%% ========== 関数: generateTLEfromElements ==========
function tleText = generateTLEfromElements(sma, ecc, inc, RAAN, argPeriapsis, trueAnomaly, startTimeJST)
    mu = 398600.4418e9;  % 地球の重力定数 [m^3/s^2]
    T = 2*pi*sqrt(sma^3 / mu);      
    meanMotion = 86400 / T;       
    meanAnomaly = trueAnomaly;     

    % JSTでエポック生成
    nowJST = startTimeJST;
    epochYear = mod(year(nowJST), 100);
    epochDay = day(nowJST, 'dayofyear') + ...
               hour(nowJST)/24 + minute(nowJST)/1440 + second(nowJST)/86400;

    % TLEフォーマットに整形
    line1 = sprintf('1 99999U 24001A   %02d%012.8f  .00000000  00000-0  00000-0 0  0001', ...
        epochYear, epochDay);

    line2 = sprintf('2 99999 %8.4f %8.4f %07d %8.4f %8.4f %11.8f00001', ...
        inc, RAAN, round(ecc * 1e7), argPeriapsis, meanAnomaly, meanMotion);

    % 各行を69文字に揃える
    line1 = pad(line1, 69);
    line2 = pad(line2, 69);

    tleText = string({line1; line2});
end