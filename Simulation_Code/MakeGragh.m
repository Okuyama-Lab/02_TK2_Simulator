function [] = MakeGragh(data)

   outdir = 'output';
   if ~exist(outdir, 'dir')
      mkdir(outdir);
   end

   %%% 出力パラメータ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   n = size(data, 1);
   time = data(:,3);
   Roll = data(:,25);
   Pitch = data(:,26);
   Yaw = data(:,27);
   BodyAngulaRate_x = data(:,144);
   BodyAngulaRate_y = data(:,145);
   BodyAngulaRate_z = data(:,146);
   MagnetorquerControlTorqueVector_X = data(:,114);
   MagnetorquerControlTorqueVector_Y = data(:,115);
   MagnetorquerControlTorqueVector_Z = data(:,116);
   MagnetorquerMagneticDipoleMoment_X = data(:,117);
   MagnetorquerMagneticDipoleMoment_Y = data(:,118);
   MagnetorquerMagneticDipoleMoment_Z = data(:,119);
   Nadir_x = data(:,133);
   Nadir_y = data(:,134);
   Nadir_z = data(:,135);
   RW_anguler_momentumX = data(:,152);
   RW_anguler_momentumY = data(:,153);
   RW_anguler_momentumZ = data(:,154);
   RW_speed_x = data(:,158);
   RW_speed_y = data(:,159);
   RW_speed_z = data(:,160);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %%%% グラフの出力　%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   plot(time,Roll,time,Pitch,time,Yaw)
   % title('EulerAngles')
   xlabel('Time [s]', 'FontSize', 15)
   ylabel('Euler Angle [deg]', 'FontSize', 15)
   legend({'Roll','Pitch','Yaw'},'Location','southeast')
   % 軸のフォントサイズを設定
   set(gca, 'FontSize', 15);
   saveas(gcf,fullfile(outdir,'EulerAngles.png'));
   saveas(gcf,fullfile(outdir,'EulerAngles.fig'));
   figure

   plot(time, BodyAngulaRate_x,time,BodyAngulaRate_y,time,BodyAngulaRate_z)
   % title('Angular Rate')
   xlabel('Time [s]', 'FontSize', 15)
   ylabel('Angular velocity [deg/s]', 'FontSize', 15)
   legend({'ω_x','ω_y','ω_z'},'Location','southeast')
   % 軸のフォントサイズを設定
   set(gca, 'FontSize', 15);
   saveas(gcf,fullfile(outdir,'InertialBodyAngulaRates.png '));
   saveas(gcf,fullfile(outdir,'InertialBodyAngulaRates.fig'));

   fprintf("Next Angular Moment is [ x=%f y=%f z=%f ]\n",data(n,36),data(n,37),data(n,38));
   fprintf("Next Euler Initial Angle is [ Roll=%f Pitch=%f Yaw=%f ]\n",data(n,25),data(n,26),data(n,27));

end