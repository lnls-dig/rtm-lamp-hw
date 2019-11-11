% Noise analysis to aid on selection instrumentation amplifier (in-amp)
% for current measurement.

% Copyright (C) 2017 CNPEM
% Licensed under GNU General Public License v3.0 (GPL)
%
% Author(s): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

Pmax = 1/8;                 % Maximum power dissipation on shunt resistor [W]
req_th_noise = 30e-12;      % Required beam deflection noise spectral density [rad/sqrt(Hz)]

I_FS = 1;                   % Load current full-scale [A]
th_FS = 30e-6;              % Beam deflection full-scale [rad]
FSp = 0.15;                 % maximum current/ADC full-scale ratio

% Shunt resistance for current measurement [ohm]
Rs = [1e-3:1e-3:9e-3 10e-3:10e-3:90e-3 100e-3:100e-3:300e-3]';

% ADC data (based on LTC2320-16 datasheet)
SNR_adc = 80;               % SNR [dBFS]
fs = 1.2e6;                 % Sampling rate [Hz]
FS_adc = 2;                 % Full-scale voltage [V]

G = FS_adc/I_FS*FSp./Rs;

% In-amp data (based on AD8429 datasheet)
eni_inamp = 1e-9;           % Input voltage noise spectral density [V/sqrt(Hz)]
eno_inamp = 45e-9;          % Output voltage noise spectral density [V/sqrt(Hz)]
in_inamp = 2e-12;           % Input current noise spectral density [A/sqrt(Hz)]

% Calculate range slection resistor (Rg)
Rg = 6e3./(G-1);

% Prevent infinite or negative Rg
Rg(G <= 1) = 0;

% Thermal noise spectral density constant at 300 K temperature [V^2/Hz]
k_therm = 1.6568e-20;

% In-amp input resistance
Rinput = Rs;

% In-amp noise power components (referred to input) [V^2]
P_eno_inamp = (eno_inamp./G).^2;
P_eni_inamp = eni_inamp.^2;
P_in_inamp = (Rinput*in_inamp).^2;
P_therm_Rinput = k_therm*Rinput;
P_therm_Rg = k_therm.*Rg;
P_rti = [P_eno_inamp repmat([P_eni_inamp], size(G,1), 1) P_in_inamp P_therm_Rinput P_therm_Rg];

% In-amp noise power components (referred to output) [V^2]
P_rto = P_rti.*G.^2;
noise_rto_total = sqrt(sum(P_rto,2));
noise = sqrt(P_rto)./FS_adc;

imeas_noise = 1./Rs./G.*noise_rto_total;
FS_noise = th_FS./I_FS.*imeas_noise;

% ADC noise floor
noisefloor = FS_adc*10^(-SNR_adc/20)/sqrt(fs/2);
imeas_noisefloor = 1./Rs./G.*noisefloor;
FS_noisefloor = th_FS./I_FS*imeas_noisefloor;

% Ratios
Pdiss = Rs*I_FS.^2;

noise_total = sqrt(noise_rto_total.^2 + noisefloor.^2)/FS_adc;

for i=1:length(FSp)
    if FSp(i) > 1
        warning(sprintf('Current full-scale exceeds ADC full-scale by %0.3g%% for G = %d', FSp(i)*100, G(i)));
    end
end

%Plot results
figure;
loglog(G, [repmat(noisefloor, size(G)) noise_rto_total]/1e-9, '-o');
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

figure;
semilogx(G, 20*log10([repmat([FSp noisefloor/FS_adc], size(G)) noise noise_total]));
xlabel('Gain');
ylabel('Noise density [dBFS/Hz]');
title('Noise density');
grid on;
legend('Full-scale [dB]', 'ADC', 'e_{no_{inamp}}', 'e_{ni_{inamp}}', 'i_{ni_{inamp}}', 'therm_{R_{input}}', 'therm_{R_G}', 'Total noise');

ax(1) = gca;
ax(2) = axes('Position', [0.13 0.12 0.775 0]);

semilogx(G, zeros(size(G)), 'k');

ticks = get(ax(1), 'XTick');
set(ax(1), 'Position', [0.13 0.24 0.775 0.685])
set(ax(2), 'XTick', logspace(-10,10,21));
set(ax(2), 'XTickLabel', cellfun(@num2str, num2cell(FS_adc/I_FS*FSp./logspace(-10,10,21)), 'UniformOutput', 0));
xlabel('Shunt resistance [ohm]');

linkaxes(ax, 'x');


figure;
h = plotyy(G, 20*log10(FS_adc*FSp./[noise_rto_total repmat(noisefloor,size(G,1),1) sqrt(noise_rto_total.^2+repmat(noisefloor,size(G,1),1).^2)]), G, Pdiss);
h(1).XScale = 'log';
h(1).YScale = 'log';
h(2).XScale = 'log';
h(2).YScale = 'linear';
xlabel('Gain');
ylabel('SNR [dB/Hz]');
grid on;
legend('In-amp', 'ADC')