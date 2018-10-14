% Linear amplifier parameter setting

% System parameters
L_c = 3.32e-3 % Magnet inductance [H]
I_c = 1.00   % Fullscale DC curent [A]
R_c = 0.082 % Magnet resistance [Ohm]

% Data for 45º magnets
L_rot = 6.64e-3  % Magnet inductance [H]
I_rot = 0.71    % Fullscale DC current [A]
R_rot = 0.187 % Magnets resistance [Ohm]

% Add to vector with two lines to ease calculation
L = [L_c L_rot];
I = [I_c I_rot];
R = [R_c R_rot];

%Cable  data
Cb_length = 50    % Maximum cable length [m]
Cb_res = 7.98e-3  % Cable resistivity [Ohm/m]

% Desired actuator performance
f_max = 10e3 % Maximum actuator frequency to analyse [Hz]

% Amplifier data, based on OPA559 datasheet and RTM-DAMP design
Vs = 3.3   % Supply voltage [V]
Vswp = 0.08 % Full scale current drop voltage,positive rail [V]
Vswn = 0.08 % Full scale current drop voltage, negative rail [V]
V_mid = Vs/2; % Operation center at tied-load bridge [V]

R_sh = 0.04 % Shunt resistor value [Ohm]


% Total cable resistance
R_cb = 2*Cb_length*Cb_res;
Rt = R_cb + R + R_sh;

% DC operating values

Vomax = Rt.*I;

Vmargin_p = (Vs - Vswp) - (V_mid+Vomax/2); % Lowest margin between
                                           % OpAmp and load,
                                           % positive rail

Vmargin_n = (V_mid - Vomax/2) - Vswn;      % Lowest margin between
                                           % OpAmp and load,
                                           % negative rail

Vmargin = Vmargin_p + Vmargin_n; %Highest step possible at worst
                                 %case

% AC operating values

didt_min = Vmargin ./ L; % Maximum current slew rate for full sweep [A/s]

% Creating a current frequency response plot
f = [0:1e6];
w = 2*pi*f;
h_f = abs((Rt./L)./(1j*w'+(Rt./L))); %Each column cointain frequency
                                      %response for a magnet [1]
i_f = h_f.*Vmargin./Rt; % Current for each frequency [A]
i_f_p = i_f./I;         % Ratio between max current and full scale
                        % current [1]
    
loglog(f,i_f_p'*100);
legend(sprintf('Standard corrector, L = %0.2g mH; I = %0.2g A; R=%0.2g Ohm', L(1)*1e3,I(1),R(1)), ...
       sprintf('45º corrector, L = %0.2g mH; I = %0.2g A; R = %0.2g Ohm', L(2)*1e3,I(2),R(2)));
line([f_max f_max],ylim);

xlabel('Frequency [Hz]')
ylabel('Ratio to full deflection [%]')

title(sprintf('Max current ratio vs frequency for R_{cb} = %0.2g Ohm, V_s = %0.2g V', R_cb, Vs));

i_f_p(f_max,:)

%% Calculating effect of cable length on response for both correctors

Cb_length = [10:100]';
R_cb = 2*Cb_length*Cb_res;
Rt = R_cb + R + R_sh;

Vomax = Rt.*I;

Vmargin_p = (Vs - Vswp) - (V_mid+Vomax/2);
Vmargin_n = (V_mid - Vomax/2) - Vswn;     
Vmargin = Vmargin_p + Vmargin_n;

didt_min = Vmargin ./ L; % Maximum current slew rate for full sweep [A/s]
    
f_max = 10e3;
w_max = 2*pi*f_max;
h = abs((Rt./L)./(1j*w_max+(Rt./L))); %Each column cointain frequency
                                      %response for a magnet [1]
i = h.*Vmargin./Rt;  % Current for each frequency [A]
i_p = i./I;         % Ratio between max current and full scale
                     % current [1]