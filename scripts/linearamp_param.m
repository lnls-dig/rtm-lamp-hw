% Linear amplifier parameter setting
 
% System parameters
L_c = 3.e-3 % Magnet inductance [H]
I_c = 1.0   % Fullscale DC curent [A]
R_c = 0.142 % Magnet resistance [Ohm]

% Data for 45º magnets
L_rot = 6.64e-3  % Magnet inductance [H]
I_rot = 0.71    % Fullscale DC current [A]
R_rot = 0.187 % Magnets resistance [Ohm]

% Add to vector with two lines to ease calculation
L = [L_c L_rot];
I = [I_c I_rot];
R = [R_c R_rot];

%Cable  data
Cb_length = 40    % Maximum cable length [m]
Cb_res = 3.08e-3  % Cable resistivity [Ohm/m]

% Desired actuator performance
f_max = 10e3 % Maximum actuator frequency to analyse [Hz]

% Amplifier data, based on OPA559 datasheet and RTM-DAMP design
Vs = 3.5   % Supply voltage [V]
Vswp = 0.08 % Full scale current drop voltage, positive rail [V]
Vswn = 0.08 % Full scale current drop voltage, negative rail [V]
R_sh = 40e-3 % Shunt resistor value [Ohm]

Vmid = (Vs-Vswp+Vswn)/2;
Vswing = Vs - Vswp - Vswn;


%% Frequency response for standard case
% Total cable resistance
R_cb = 2*Cb_length*Cb_res;
Rt = R_cb + R + R_sh;

% DC operating values
Vomax = Rt.*I;

Vmargin = Vswing - Vomax;

% AC operating values
didt_min = Vmargin ./ L; % Maximum current slew rate for full sweep [A/s]

% Creating a current frequency response plot
f = [0:1e6];
i_p_f = deflection_response(f', Rt, L, Vmargin, I);

figure()
loglog(f,i_p_f'*100);
legend(sprintf('Standard corrector, L = %0.2g mH; I = %0.2g A; R = %0.2g Ohm', L(1)*1e3,I(1),R(1)), ...
       sprintf('45degree corrector, L = %0.2g mH; I = %0.2g A; R = %0.2g Ohm', L(2)*1e3,I(2),R(2)));
line([f_max f_max],ylim);

xlabel('Frequency [Hz]')
ylabel('Ratio to full deflection [%]')

title(sprintf('Max current ratio vs frequency for R_{cb} = %0.2g Ohm, V_s = %0.2g V', R_cb, Vs));

%% Calculating effect of cable length on response for both correctors
Cb_length = [10:100]';
R_cb_cl = 2*Cb_length*Cb_res;
Rt_cl = R_cb_cl + R + R_sh;

Vomax_cl = Rt_cl.*I;

Vmargin_cl = Vswing - Vomax_cl;

didt_min_cl = Vmargin_cl ./ L; % Maximum current slew rate for full sweep [A/s]
i_p_cl = deflection_response(f_max, Rt_cl, L, Vmargin_cl, I);

figure()
cl_df = subplot(2,2,1);
plot(Cb_length,i_p_cl*100);
legend('Standard magnet', '45^{\circ} magnet');
title(sprintf('Max deflection at f = %0.2g kHz vs cable length (resistivity = %0.2g mOhm/m)', ...
              f_max/1e3,Cb_res*1e3));
xlabel('Cable length [m]');
ylabel(sprintf('Max deflection [%% of Full scale]',f_max));
grid on;


cl_sr = subplot(2,2,3)
plot(Cb_length,didt_min_cl);
ylabel('Maximum current slew rate [A/s]')
xlabel('Cable length [m]')
legend('Standard magnet', '45^{\circ} magnet');
title(sprintf('Max current slew rate vs cable length (resistivity = %0.2g mOhm/m)', ...
              Cb_res*1e3));
grid on;

%% Plotting effect of increased Vs on response
Vs_v = [3:0.1:5]';

Vmid_s = (Vs_v - Vswp + Vswn)/2;
Vswing_v = Vs_v - Vswp - Vswn;

Vmargin_v = Vswing_v - Vomax;

didt_min_v = Vmargin_v ./ L;
i_p_v = deflection_response(f_max, Rt, L, Vmargin_v, I);

%Plotting
vs_df = subplot(2,2,2);
plot(Vs_v,i_p_v*100);
legend('Standard magnet', '45^{\circ} magnet');
title(sprintf('Max deflection at f = %0.2g kHz vs supply voltage', ...
              f_max/1e3));
xlabel('OpAmp supply voltage [V]');
ylabel(sprintf('Max deflection [%% of Full scale]',f_max));
grid on;

vs_sr = subplot(2,2,4)
plot(Vs_v,didt_min_v);
ylabel('Maximum current slew rate [A/s]')
xlabel('Supply voltage [V]')
legend('Standard magnet', '45^{\circ} magnet');
title(sprintf('Max current slew rate vs supply voltage', ...
              f_max/1e3));
grid on;

linkaxes([cl_df, cl_sr],'x');
linkaxes([vs_df, vs_sr],'x')

function i_p = deflection_response(f, R, L, V, I)
    w = 2*pi*f;
    H = abs((R./L)./(1j*w+(R./L)));
    i = H.*V./R;
    i_p = i./I;        
end