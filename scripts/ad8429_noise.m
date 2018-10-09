function [noise, rg] = ad8429_noise(gain, r_input)
% AD8429_NOISE - Calculate output noise for AD8429 inamp given gain and input noise.
%   It automatically calculates the gain resistor for each given
%   gain in the second variable.

eni_inamp = 1e-9;           % Input voltage noise spectral density [V/sqrt(Hz)]
eno_inamp = 45e-9;          % Output voltage noise spectral density [V/sqrt(Hz)]
in_inamp = 2e-12;           % Input current noise spectral density [A/sqrt(Hz)]

% Calculate range slection resistor (Rg)
rg = 6e3./(gain-1);

% Prevent infinite or negative Rg
rg(gain <= 1) = 0;

% Thermal noise spectral density constant at 300 K temperature [V^2/Hz/Ohm]
k_therm = 1.6568e-20;

% In-amp noise
noise_rti = sqrt((eno_inamp./gain).^2 + eni_inamp.^2 + (r_input*in_inamp).^2 + k_therm*r_input + k_therm*rg);
noise = gain.*noise_rti;

end