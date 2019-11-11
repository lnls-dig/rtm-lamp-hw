%% Power budget for RTM FOFB actuator

%Basic amplifier information
N = 8;     % Number of amplifiers
Iout = 1;  % Maximum current for each amplifier [A]
Vs = 3.5;  % Amplifier supply voltage [V]
Iq_amp = 2*6e-3; % Quiescent current for both amplifiers [A]

% Power network
Vin = 12; % Input for DC-DC [V]
I_in = 3; % Maximum input current [A]
Vpower = 4.2; % Voltage for main power rail [V]

% DAC
I_dac = 20e-6; % Current used by DAC [A]
P_dac = I_dac*Vs; % Total power used by DAC [W]

%ADC



%Calculate