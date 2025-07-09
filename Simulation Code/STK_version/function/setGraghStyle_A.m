function setGraghStyle_A()

    ax = gca;

    % Y軸の最大値の絶対値を取得して対称に設定
    yLimits = ylim(ax);
    yAbsMax = max(abs(yLimits));
    ylim(ax, [-yAbsMax, yAbsMax]);

    % ラベルとタイトルのフォント調整
    ax.XLabel.FontSize = 20;
    ax.XLabel.FontWeight = 'bold';
    ax.YLabel.FontSize = 20;
    ax.YLabel.FontWeight = 'bold';
    ax.Title.FontSize  = 15;
    ax.Title.FontWeight = 'normal';

    % 軸・線・グリッドスタイル調整
    ax.FontSize = 20;
    ax.LineWidth = 1.0;
    ax.Box = 'on';
    ax.GridLineStyle = '-';

    % グリッドをON
    grid(ax, 'on');

    % 線の太さを変更（すべてのLineオブジェクトに適用）
    lines = findall(ax, 'Type', 'Line');
    for k = 1:length(lines)
        lines(k).LineWidth = 2.0;
    end
end
