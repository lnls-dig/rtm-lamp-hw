vin = -9; % V
vout = -7; % V

rratio = (abs(vout) - 1.21) / 1.21;
[rreg1 rreg2] = sel_res_ratio(rratio);

printf('---- Design report: LM2991 ----\n\n');
printf('Initial parameters: Vin = %.2f V, Vout = %.2f V\n\n', vin, vout);
printf('Results:\n');
printf('Voltage regulator resistors: R1 = %s, R2 = %s\n', format_eng(rreg1, 'Ohms'), format_eng(rreg2, 'Ohms'));
