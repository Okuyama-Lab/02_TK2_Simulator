%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EOSの出力CSV内にある評価用パラメータのグラフを作成する関数
% Last update ：2025/07/07
% Developper : Keigo Mutsuo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = MakeGragh(data)

   outdir = fullfile('output', 'Simulation LOG');
   if ~exist(outdir, 'dir')
      mkdir(outdir);
   end


   %%% 出力パラメータ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   n = size(data, 1);
   time = data(:,3);
   % === 姿勢角 ===
   EulerAngle = data(:, 26:28);

   % === 外乱トルク ===
   Torque.GravityGradient = data(:,57:59);
   Torque.Aerodynamic     = data(:,66:68);
   Torque.Solar           = data(:,69:71);
   Torque.SolarPanel.X = sum(data(:, [83, 86, 89, 92, 95, 98, 101, 104]), 2);
   Torque.SolarPanel.Y = sum(data(:, [84, 87, 90, 93, 96, 99, 102, 105]), 2);
   Torque.SolarPanel.Z = sum(data(:, [85, 88, 91, 94, 97, 100, 103, 106]), 2);

   % === 太陽ベクトル ===
   SunVec = data(:,72:74);

   % === 角速度 ===
   AngularRate = data(:,144:146);

   % === MTQ関連 ===
   MTQ.ControlTorque = data(:,115:117);
   MTQ.PulseDuration = data(:,121:123);

   % === RW関連 ===
   RW.ControlTorque = data(:,150:152);
   RW.Speed         = data(:,159:161);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %%%% グラフの出力　%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   plot(time,EulerAngle)
   title('EulerAngles')
   xlabel('Time [s]')
   ylabel('Euler Angle [deg]')
   legend({'Roll','Pitch','Yaw'})
   setGraghStyle_A();
   saveas(gcf,fullfile(outdir,'EulerAngles.png'));
   saveas(gcf,fullfile(outdir,'EulerAngles.fig'));
   figure

   plot(time,Torque.GravityGradient)
   title('Gravity Gradient Torque')
   xlabel('Time [s]')
   ylabel('[Nm]')
   legend({'x','y','z'})
   setGraghStyle_A();
   saveas(gcf,fullfile(outdir,'GravityGradientTorque.png'));
   saveas(gcf,fullfile(outdir,'GravityGradientTorque.fig'));
   figure

   plot(time,Torque.Aerodynamic)
   title('Aerodynamic Torque')
   xlabel('Time [s]')
   ylabel('[Nm]')
   legend({'x','y','z'})
   setGraghStyle_A();
   saveas(gcf,fullfile(outdir,'AerodynamicTorque.png'));
   saveas(gcf,fullfile(outdir,'AerodynamicTorque.fig'));
   figure

   plot(time,Torque.Solar)
   title('Solar Torque')
   xlabel('Time [s]')
   ylabel('[Nm]')
   legend({'x','y','z'})
   setGraghStyle_A();
   saveas(gcf,fullfile(outdir,'SolarTorque.png'));
   saveas(gcf,fullfile(outdir,'SolarTorque.fig'));
   figure

   plot(time,SunVec)
   title('Sun Vector')
   xlabel('Time [s]')
   ylabel('[-]')
   legend({'x','y','z'})
   setGraghStyle_A();
   saveas(gcf,fullfile(outdir,'SunVector.png'));
   saveas(gcf,fullfile(outdir,'SunVector.fig'));
   figure

   plot(time,Torque.SolarPanel.X, time,Torque.SolarPanel.Y, time,Torque.SolarPanel.Z)
   title('Solar Pannel Torque')
   xlabel('Time [s]')
   ylabel('[Nm]')
   legend({'x','y','z'})
   setGraghStyle_A();
   saveas(gcf,fullfile(outdir,'SolarPannelTorque.png'));
   saveas(gcf,fullfile(outdir,'SolarPannelTorque.fig'));
   figure

   plot(time, AngularRate)
   title('Rate Sensor Measured Angular Rate')
   xlabel('Time [s]')
   ylabel('Angular velocity [deg/s]')
   legend({'ω_x','ω_y','ω_z'})
   setGraghStyle_A();
   saveas(gcf,fullfile(outdir,'InertialBodyAngulaRates.png'));
   saveas(gcf,fullfile(outdir,'InertialBodyAngulaRates.fig'));
   figure

   plot(time, MTQ.ControlTorque)
   title('MTQ Control Torque Vector')
   xlabel('Time [s]')
   ylabel('[N*m]')
   legend({'x','y','z'})
   setGraghStyle_A();
   saveas(gcf,fullfile(outdir,'MagnetorquerControlTorqueVector.png'));
   saveas(gcf,fullfile(outdir,'MagnetorquerControlTorqueVector.fig'));
   figure

   plot(time, MTQ.PulseDuration)
   title('MTQ Duty Cycle')
   xlabel('Time [s]')
   ylabel('[-]')
   ylim([-1, 1])
   legend({'x','y','z'})
   setGraghStyle_A();
   saveas(gcf,fullfile(outdir,'MagnetorquerPulseDuration.png'));
   saveas(gcf,fullfile(outdir,'MagnetorquerPulseDuration.fig'));
   figure

   plot(time, RW.ControlTorque)
   title('RW Control Torque Vector')
   xlabel('Time [s]')
   ylabel('[N*m]')
   legend({'x','y','z'})
   setGraghStyle_A();
   saveas(gcf,fullfile(outdir,'RW_Control_Torque_Vector.png'));
   saveas(gcf,fullfile(outdir,'RW_Control_Torque_Vector.fig'));
   figure

   plot(time, RW.Speed)
   title('RW Measured Speed')
   xlabel('Time [s]')
   ylabel('[rev/min]')
   legend({'x','y','z'})
   setGraghStyle_A();
   saveas(gcf,fullfile(outdir,'RW_speed.png'));
   saveas(gcf,fullfile(outdir,'RW_speed.fig'));

   fprintf("Next Angular Moment is [ x=%f y=%f z=%f ]\n",data(n,36),data(n,37),data(n,38));
   fprintf("Next Euler Initial Angle is [ Roll=%f Pitch=%f Yaw=%f ]\n",data(n,25),data(n,26),data(n,27));

end