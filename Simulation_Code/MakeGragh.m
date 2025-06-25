function [] = MakeGragh(data)

   outdir = 'output';
   if ~exist(outdir, 'dir')
      mkdir(outdir);
   end

   %%% 出力パラメータ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   n = size(data, 1);
   time = data(:,3);
   Roll = data(:,26);
   Pitch = data(:,27);
   Yaw = data(:,28);
   BodyAngulaRate_x = data(:,144);
   BodyAngulaRate_y = data(:,145);
   BodyAngulaRate_z = data(:,146);
   MagnetorquerControlTorqueVector_X = data(:,115);
   MagnetorquerControlTorqueVector_Y = data(:,116);
   MagnetorquerControlTorqueVector_Z = data(:,117);
   MagnetorquerMagneticDipoleMoment_X = data(:,117);
   MagnetorquerMagneticDipoleMoment_Y = data(:,118);
   MagnetorquerMagneticDipoleMoment_Z = data(:,119);
   Nadir_x = data(:,133);
   Nadir_y = data(:,134);
   Nadir_z = data(:,135);
   RW_anguler_momentumX = data(:,152);
   RW_anguler_momentumY = data(:,153);
   RW_anguler_momentumZ = data(:,154);
   RW_Control_Torque_Vector_X = data(:,150);
   RW_Control_Torque_Vector_Y = data(:,151);
   RW_Control_Torque_Vector_Z = data(:,152);
   RW_speed_x = data(:,159);
   RW_speed_y = data(:,160);
   RW_speed_z = data(:,161);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %%%% グラフの出力　%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   plot(time,Roll,time,Pitch,time,Yaw)
   % title('EulerAngles')
   xlabel('Time [s]', 'FontSize', 15)
   ylabel('Euler Angle [deg]', 'FontSize', 15)
   legend({'Roll','Pitch','Yaw'},'Location','southeast')
   x = findobj(gcf,"DisplayName","Roll");
   x.LineWidth = 2;
   y = findobj(gcf,"DisplayName","Pitch");
   y.LineWidth = 2;
   z = findobj(gcf,"DisplayName","Yaw");
   z.LineWidth = 2;
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
   x = findobj(gcf,"DisplayName","ω_x");
   x.LineWidth = 2;
   y = findobj(gcf,"DisplayName","ω_y");
   y.LineWidth = 2;
   z = findobj(gcf,"DisplayName","ω_z");
   z.LineWidth = 2;
   saveas(gcf,fullfile(outdir,'InertialBodyAngulaRates.png'));
   saveas(gcf,fullfile(outdir,'InertialBodyAngulaRates.fig'));
   figure

   plot(time, MagnetorquerControlTorqueVector_X,time,MagnetorquerControlTorqueVector_Y,time,MagnetorquerControlTorqueVector_Z)
   % title('Angular Rate')
   xlabel('Time [s]', 'FontSize', 15)
   ylabel('[N*m]', 'FontSize', 15)
   legend({'x','y','z'},'Location','southeast')
   % 軸のフォントサイズを設定
   set(gca, 'FontSize', 15);
   x = findobj(gcf,"DisplayName","x");
   x.LineWidth = 2;
   y = findobj(gcf,"DisplayName","y");
   y.LineWidth = 2;
   z = findobj(gcf,"DisplayName","z");
   z.LineWidth = 2;
   saveas(gcf,fullfile(outdir,'MagnetorquerControlTorqueVector.png'));
   saveas(gcf,fullfile(outdir,'MagnetorquerControlTorqueVector.fig'));
   figure

   plot(time, RW_Control_Torque_Vector_X,time,RW_Control_Torque_Vector_Y,time,RW_Control_Torque_Vector_Z)
   % title('Angular Rate')
   xlabel('Time [s]', 'FontSize', 15)
   ylabel('[N*m]', 'FontSize', 15)
   legend({'x','y','z'},'Location','southeast')
   % 軸のフォントサイズを設定
   set(gca, 'FontSize', 15);
   x = findobj(gcf,"DisplayName","x");
   x.LineWidth = 2;
   y = findobj(gcf,"DisplayName","y");
   y.LineWidth = 2;
   z = findobj(gcf,"DisplayName","z");
   z.LineWidth = 2;
   saveas(gcf,fullfile(outdir,'RW_Control_Torque_Vector.png'));
   saveas(gcf,fullfile(outdir,'RW_Control_Torque_Vector.fig'));
   figure

   plot(time, RW_speed_x,time,RW_speed_y,time,RW_speed_z)
   % title('Angular Rate')
   xlabel('Time [s]', 'FontSize', 15)
   ylabel('[rev/min]', 'FontSize', 15)
   legend({'x','y','z'},'Location','southeast')
   % 軸のフォントサイズを設定
   set(gca, 'FontSize', 15);
   saveas(gcf,fullfile(outdir,'RW_speed.png'));
   saveas(gcf,fullfile(outdir,'RW_speed.fig'));
   x = findobj(gcf,"DisplayName","x");
   x.LineWidth = 2;
   y = findobj(gcf,"DisplayName","y");
   y.LineWidth = 2;
   z = findobj(gcf,"DisplayName","z");
   z.LineWidth = 2;
   fprintf("Next Angular Moment is [ x=%f y=%f z=%f ]\n",data(n,36),data(n,37),data(n,38));
   fprintf("Next Euler Initial Angle is [ Roll=%f Pitch=%f Yaw=%f ]\n",data(n,25),data(n,26),data(n,27));

end