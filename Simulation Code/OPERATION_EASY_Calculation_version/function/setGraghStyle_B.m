function setGraghStyle_B()
    ax = gca;

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

    % グリッド明示的にON
    grid(ax, 'on');

    % 現在の線にも適用（オプション：複数線対応）
    lines = findall(ax, 'Type', 'Line');
    for k = 1:length(lines)
        lines(k).LineWidth = 2.0;
    end
end
