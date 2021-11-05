vin = 12; % V
vin_min = 10; % V
vin_max = 14; % V
vout = -9; % V
vd = 0.5; % V
ton_min = 90e-9; % s
toff_min = 75e-9; % s
freq = 4*580e3; % Hz
cur_max = 0.5; % A
ind_ipp_ratio = 0.65

rreg_ratio = (abs(vout) / .8) - 1;
[rreg1 rreg2] = sel_res_ratio(rreg_ratio, 1000, 'E96');

dmax = (vout - vd) / (vout - vd - vin_min);
dmin = (vout - vd) / (vout - vd - vin_max);

if (dmax >= (1 - toff_min * freq))
  printf('Dmax violation: %f\n', dmax);
end

if (dmin <= (ton_min * freq))
  printf('Dmax violation: %f\n', dmin);
end

cur_sw_avg_max = cur_max / (1 - dmax);
sw_ipp = ind_ipp_ratio * cur_sw_avg_max;
ind = (vin_min * dmax) / (0.5 * sw_ipp * freq);

rt = ((51.2e6 / freq) - 5.6) * 1e3;

fprintf('---- Design report: LT8362 ----\n\n');
fprintf('Initial parameters: Vin = %.2f V, Vout = %.2f V, Iload_max = %.2f A,\nFreq = %.1f kHz\n\n', vin, vout, cur_max, freq / 1000);
fprintf('Results:\n');
fprintf('Inductor = %s\n', format_eng(ind, 'H'));
fprintf('Voltage regulator resistors: R1 = %s, R2 = %s\n', format_eng(rreg1, 'Ohms'), format_eng(rreg2, 'Ohms'));
fprintf('Rt = %s\n', format_eng(rt, 'Ohms'));
