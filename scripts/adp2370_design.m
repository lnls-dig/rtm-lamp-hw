vin = 12; % V
vout = 5; % V
freq = 2*580e3; % kHz

ind = (1.2 * vout) / (0.478 * freq);
rratio = (vout - 0.8) / 0.8;
[rreg1 rreg2] = sel_res_ratio(rratio);

fprintf('---- Design report: ADP2370 ----\n\n');
fprintf('Initial parameters: Vin = %.2f V, Vout = %.2f V, \nFreq = %.1f kHz\n\n', vin, vout, freq / 1000);
fprintf('Results:\n');
fprintf('Inductor = %s\n', format_eng(ind, 'H'));
fprintf('Voltage regulator resistors: R1 = %s, R2 = %s\n', format_eng(rreg1, 'Ohms'), format_eng(rreg2, 'Ohms'));
