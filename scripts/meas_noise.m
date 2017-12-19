% Noise analysis to aid on selection instrumentation amplifier for current
% measurement.

% Copyright (C) 2017 CNPEM
% Licensed under GNU General Public License v3.0 (GPL)
%
% Author(s): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

Pmax = 1/8;                     % Maximum power dissipation on shunt resistor [W]

th_FS = 30e-6;                  % Beam deflection full-scale [rad]
req_Th_noise = 300e-12;         % Required beam deflection noise spectral density [rad/sqrt(Hz)]

I_FS = 1;                       % Load current full-scale [A]
Rs = 50e-3;                     % Shunt resistance for current measurement [ohm]

SNR_adc = 80;                   % ADC SNR [dBFS]
fs = 1.2e6;                     % ADC sampling rate
FS_adc = 2;                     % ADC full-scale voltage [V]

G_inamp = logspace(-2, 3, 9)';  % In-amp gain
eni_inamp = 50e-9;              % In-amp input noise spectral density [V/sqrt(Hz)]
eno_inamp = 45e-9;              % In-amp output noise spectral density [V/sqrt(Hz)]

% Voltage noise
en_inamp = sqrt(G_inamp*eni_inamp.^2 + eno_inamp.^2);
en_adc = FS_adc*10^(-SNR_adc/20)./sqrt(fs/2);
en_total = sqrt(en_inamp.^2 + en_adc.^2);

% Measured current noise
in_inamp = en_inamp./Rs;
in_adc = en_adc./Rs;
in_total = sqrt(in_inamp.^2 + in_adc.^2);

% Measured beam deflection noise
thn_inamp = th_FS./I_FS*in_inamp;
thn_adc = th_FS./I_FS*in_adc;
thn_total = sqrt(thn_inamp.^2 + thn_adc.^2);

% Thermal noise spectral density at 300 K temperature
en_R = sqrt(1.6568e-20*Rs);
in_R = en_R./Rs;
thn_R = th_FS./I_FS*in_R;

% Ratios
Pp = Rs*I_FS.^2./Pmax;
FSp = Rs*I_FS./FS_adc;

% Show results
if length(en_inamp) > 1
    figure;
    loglog(G_inamp([1 end]), [en_adc en_adc]/1e-9);
    hold all
    loglog(G_inamp, [en_inamp en_total]/1e-9);
    xlabel('Gain');
    ylabel('nV/\surdHz');
    grid on;
    legend('ADC noise floor', 'In-amp', 'Total');
    
    figure;
    loglog(G_inamp([1 end]), [in_adc in_adc]/1e-6);
    hold all
    loglog(G_inamp, [in_inamp in_total]/1e-6);
    xlabel('Gain');
    ylabel('\muA/\surdHz');
    grid on;
    legend('ADC noise floor', 'In-amp', 'Total');
    
    figure;
    loglog(G_inamp([1 end]), [req_Th_noise req_Th_noise]/1e-12, 'LineWidth', 2);
    hold all
    loglog(G_inamp([1 end]), [thn_adc thn_adc]/1e-12);    
    loglog(G_inamp, [thn_inamp thn_total]/1e-12);
    xlabel('Gain');
    ylabel('prad/\surdHz');
    grid on;
    legend('Specification', 'ADC noise floor', 'In-amp', 'Total');
else
    fprintf('\n');
    fprintf('Voltage noise\n');
    fprintf('-------------\n');
    fprintf('In-amp noise: %0.3g nV/sqrt(Hz)\n', en_inamp/1e-9);
    fprintf('ADC noise floor: %0.3g nV/sqrt(Hz)\n', en_adc/1e-9);
    fprintf('\n');
    fprintf('Measured current\n');
    fprintf('----------------\n');
    fprintf('In-amp noise: %0.3g uA/sqrt(Hz)\n', in_inamp/1e-6);
    fprintf('ADC: %0.3g uA/sqrt(Hz)\n', in_adc/1e-6);
    fprintf('\n');
    fprintf('Measured beam deflection\n');
    fprintf('------------------------\n');
    fprintf('In-amp noise: %0.3g prad/sqrt(Hz)\n', thn_inamp/1e-12);
    fprintf('ADC noise floor: %0.3g prad/sqrt(Hz)\n', thn_adc/1e-12);
    fprintf('\n');
end

fprintf('Dissipated power (percent of power budget): %0.3g%% (must be < 100%%)\n', Pp*100);
fprintf('ADC full-scale to current full-scale ratio: %0.3g%% (must be < 100%%)\n', FSp*100);
fprintf('\n');