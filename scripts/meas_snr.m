% Noise analysis to aid on selection instrumentation amplifier (in-amp)
% for current measurement.

% Copyright (C) 2017 CNPEM
% Licensed under GNU General Public License v3.0 (GPL)
%
% Author(s): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br
clear;

Pmax = 1/8;                 % Maximum power dissipation on shunt resistor [W]
req_th_noise = 300e-12;     % Required beam deflection noise spectral density [rad/sqrt(Hz)]

I_FS = 1;                   % Load current full-scale [A]
th_FS = 30e-6;              % Beam deflection full-scale [rad]

Rs = [1:50]*1e-3;

Gain = [ ...                   % Gain
    1; ...                  
    5; ...
    10; ...
    20; ...
    50; ...
    100; ...
    200;...
    400];

gain_n = length(Gain);
rs_n = length(Rs);

k_therm = 1.6568e-20;

% ADC data (based on LTC2320-16 datasheet)
SNR_adc = 80;               % SNR [dBFS]
fs = 1.2e6;                 % Sampling rate [Hz]
FS_adc = 2/sqrt(2);                 % Full-scale voltage [V]

% ADC noise floor
ADC_noisefloor = FS_adc*10^(-SNR_adc/20)/sqrt(fs/2);

Rs_power = Rs*(I_FS.^2);    %power dissipated in resistor

total_noise = zeros(gain_n,rs_n);
ADC_signal = zeros(gain_n, rs_n);
Fp_ADC = zeros(gain_n,rs_n);
SNR_ADC  = zeros(gain_n,rs_n);

for i = 1:gain_n

    G = Gain(i);
    noise = ad8429_noise(G,Rs);
    imeas_noise = 1./Rs./G.*noise;
    FS_noise = th_FS./I_FS.*imeas_noise;

    ADC_signal(i,:) = G*Rs*I_FS;
    ADC_signal(i,ADC_signal(i,:)>FS_adc) = NaN;
    Fp_ADC(i,:) = ADC_signal(i,:)./FS_adc; %proportion of signal to ADC full
                                %scale

    total_noise(i,:) = sqrt(ADC_noisefloor.^2+noise.^2)*sqrt(fs/2);
    SNR_ADC(i,:) = 20*log10(ADC_signal(i,:)./total_noise(i,:));
end


figure;
plot(Rs, SNR_ADC, '-o');
legend('ADC noise floor', 'In-amp noise');

title('SNR');
grid on;

xlabel('Shunt resistance');
ylabel('');
legend(num2str(Gain))