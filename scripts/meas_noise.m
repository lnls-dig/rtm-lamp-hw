% Noise analysis to aid on selection instrumentation amplifier (in-amp)
% for current measurement.

% Copyright (C) 2017 CNPEM
% Licensed under GNU General Public License v3.0 (GPL)
%
% Author(s): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

Pmax = 1/8;                     % Maximum power dissipation on shunt resistor [W]
req_th_noise = 300e-12;         % Required beam deflection noise spectral density [rad/sqrt(Hz)]

I_FS = 1;                       % Load current full-scale [A]
th_FS = 30e-6;                 % Beam deflection full-scale [rad]

Rs = 15e-3;                     % Shunt resistance for current measurement [ohm]

% ADC data (based on LTC2320-16 datasheet)
SNR_adc = 80;                   % SNR [dBFS]
fs = 1.2e6;                     % sampling rate
FS_adc = 2;                     % Full-scale voltage [V]

% In-amp data (based on AD8429 datasheet)
G = [1; ...                     % Gain
     5; ...
     10; ...
     20; ...
     50; ...
     100];
eni_inamp = 1e-9;               % Input voltage noise spectral density [V/sqrt(Hz)]
eno_inamp = 45e-9;              % Output voltage noise spectral density [V/sqrt(Hz)]
in_inamp = 2e-12;               % Input current noise spectral density [A/sqrt(Hz)]

% Calculate range slection resistor (Rg)
Rg = 6e3./(G-1);

% Prevent infinite or negative Rg
Rg(G <= 1) = 0;

% Thermal noise spectral density constant at 300 K temperature [V^2/Hz]
k_therm = 1.6568e-20;

% In-amp input resistance
R_input = Rs;

% In-amp noise
noise_rti = sqrt((eno_inamp./G).^2 + eni_inamp.^2 + (R_input*in_inamp).^2 + k_therm*R_input + k_therm*Rg);
noise = G.*noise_rti;
imeas_noise = 1./Rs./G.*noise;
FS_noise = th_FS./I_FS.*imeas_noise;

% ADC noise floor
noisefloor = FS_adc*10^(-SNR_adc/20)/sqrt(fs/2);
imeas_noisefloor = 1./Rs./G.*noisefloor;
FS_noisefloor = th_FS./I_FS*imeas_noisefloor;

% Ratios
Pp = Rs*I_FS.^2./Pmax;
FSp = G*Rs*I_FS./FS_adc;

for i=1:length(FSp)
    if FSp(i) > 1
        warning(sprintf('Current full-scale exceeds ADC full-scale by %0.3g%% for G = %d', FSp(i)*100, G(i)));
    end
end 

% Plot results
figure;
loglog(G, [repmat(noisefloor, size(G)) noise]/1e-9, '-o');
xlabel('Gain');
ylabel('nV/\surdHz');
title('Voltage noise');
grid on;
legend('ADC noise floor', 'In-amp noise');

figure;
loglog(G, [imeas_noisefloor imeas_noise]/1e-6, '-o');
xlabel('Gain');
ylabel('\muA/\surdHz');
title('Current measurement noise');
grid on;
legend('ADC noise floor', 'In-amp noise');

figure;
loglog(G([1 end]), [req_th_noise req_th_noise]/1e-12, 'LineWidth', 2);
hold all
loglog(G, [FS_noisefloor FS_noise]/1e-12, '-o');
xlabel('Gain');
ylabel('prad/\surdHz');
title('Beam deflection noise');
grid on;
legend('Specification', 'ADC noise floor', 'In-amp noise');