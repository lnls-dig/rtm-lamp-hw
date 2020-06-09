%% 3.3V supply %%
vin_3v3 = 5; % V
vout_3v3 = 3.3; % V

rratio_3v3 = (vout_3v3 - 1.25) / 1.25;
[rreg1_3v3 rreg2_3v3] = sel_res_ratio(rratio_3v3);

printf('---- Design report: NJM11100F1 3.3v ----\n\n');
printf('Initial parameters: Vin = %.2f V, Vout = %.2f V\n\n', vin_3v3, vout_3v3);
printf('Results:\n');
printf('Voltage regulator resistors: R1 = %s, R2 = %s\n', format_eng(rreg1_3v3, 'Ohms'), format_eng(rreg2_3v3, 'Ohms'));

%% 3.3V supply %%
vin_2v5 = 5; % V
vout_2v5 = 2.5; % V

rratio_2v5 = (vout_2v5 - 1.25) / 1.25;
[rreg1_2v5 rreg2_2v5] = sel_res_ratio(rratio_2v5);

printf('\n---- Design report: NJM11100F1 2.5v ----\n\n');
printf('Initial parameters: Vin = %.2f V, Vout = %.2f V\n\n', vin_2v5, vout_2v5);
printf('Results:\n');
printf('Voltage regulator resistors: R1 = %s, R2 = %s\n', format_eng(rreg1_2v5, 'Ohms'), format_eng(rreg2_2v5, 'Ohms'));
