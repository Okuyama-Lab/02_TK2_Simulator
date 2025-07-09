%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Last update ：2024/01/29
% Name : Keigo Mutsuo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ==== 出力フォルダの作成 ====
outdir = 'output';
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

% ==== 固定パラメータ設定 ====
sma = 6871e3 + 500e3;        % 軌道長半径 [m]
ecc = 0.0001;                % 離心率
inc = 51.6;                  % 軌道傾斜角 [deg]
argPeriapsis = 0;            % 近地点引数 [deg]
trueAnomaly = 0;             % 真近点角 [deg]

% ==== JSTのシナリオ開始時刻 ====
startTimeJST = datetime(2025,10,1,0,0,0,'TimeZone','Asia/Tokyo');
stopTime = startTimeJST + days(1);
sampleTime = 1;  % [s]

% ==== 地上局情報 ====
gsLat = 35.72476582064593;
gsLon = 140.05691485473042;

% ==== RAANループ ====
for RAAN = 0:10:360
    % TLE生成（シナリオと同じエポックに設定）
    tleText = generateTLEfromElements(sma, ecc, inc, RAAN, argPeriapsis, trueAnomaly, startTimeJST);
    tleFile = fullfile(tempdir, sprintf('generated_RAAN_%03d.tle', RAAN));
    fid = fopen(tleFile, 'w');
    fprintf(fid, '%s\n', tleText);
    fclose(fid);

    % シナリオ作成
    sc = satelliteScenario(startTimeJST, stopTime, sampleTime);
    sat = satellite(sc, tleFile);
    gs = groundStation(sc, 'Latitude', gsLat, 'Longitude', gsLon, ...
        'Altitude', 0, 'Name', 'Nihon University', 'MinElevationAngle', 15);

    % アクセス解析
    ac = access(gs, sat);
    visTimes = accessIntervals(ac);

    startTimeJSTs = visTimes.StartTime;
    endTimeJSTs = visTimes.EndTime;
    startTimeJSTs.TimeZone = 'Asia/Tokyo';
    endTimeJSTs.TimeZone = 'Asia/Tokyo';
    visTimes.StartTime = datetime(visTimes.StartTime, 'TimeZone', 'Asia/Tokyo');
    visTimes.EndTime   = datetime(visTimes.EndTime, 'TimeZone', 'Asia/Tokyo');

    % JST時刻を秒換算
    startSec = round(seconds(visTimes.StartTime - startTimeJST));
    endSec   = round(seconds(visTimes.EndTime - startTimeJST));
    durationSec = endSec - startSec;
    n = height(visTimes);

    % データ列
    data = [ ...
        cellstr(visTimes.Source), ...
        cellstr(visTimes.Target), ...
        num2cell(visTimes.IntervalNumber), ...
        cellstr(string(startTimeJSTs)), ...
        cellstr(string(endTimeJSTs)), ...
        num2cell(startSec), ...
        num2cell(endSec), ...
        num2cell(durationSec), ...
        cell(n,1), cell(n,1), cell(n,1), cell(n,1) ...
    ];

    header = {'Source','Target','Interval','StartTime','EndTime', ...
              'StartTimeSec','EndTimeSec','Duration','mission states', ...
              'mission duration','mission start time','mission end time'};

    output = [header; data];
    fileName = sprintf('Result_Orbit_RAAN_%03d.xlsx', RAAN);
    writecell(output, fullfile(outdir, fileName));
    fprintf("RAAN = %3d の可視情報を %s に出力しました。\n", RAAN, fileName);
end

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