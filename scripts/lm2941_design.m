vin = 12; % V
vout = 7; % V

rratio = (vout - 1.275) / 1.275;
[rreg1 rreg2] = sel_res_ratio(rratio);

fprintf('---- Design report: LM2941 ----\n\n');
fprintf('Initial parameters: Vin = %.2f V, Vout = %.2f V\n\n', vin, vout);
fprintf('Results:\n');
fprintf('Voltage regulator resistors: R1 = %s, R2 = %s\n', format_eng(rreg1, 'Ohms'), format_eng(rreg2, 'Ohms'));
