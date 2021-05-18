clbw = 10e3;    % Target closed loop bandwidth [kHz]
L = 2.95e-3;    % Load inductance [H]
R = 1.31;       % Load resistance [Ohm]
Ts = 910e-9;    % Sample time [s]
dly = 3e-6;     % Delay [s]
Vref = 4;       % DAC Vref [V]
shift_Kp = -7;  % P-term bit shift
shift_Ki = -1;  % I-term bit shift

% Plant model in ADC counts/DAC counts units
G = 2*Vref/4.096;

% Controller design
Kp_design = 2*pi*clbw/G*L;
Ki_design = 2*pi*clbw/G*R;

% Calculate Kp and Ki on FPGA raw units
Kp_fpga = round(Kp_design*2^15*2^(shift_Kp));
Ki_fpga = round(Ki_design*2^15*2^(shift_Ki)*Ts);

% Calculate gain errors
Kp_actual = Kp_fpga/2^15/2^(shift_Kp);
Ki_actual = Ki_fpga/2^15/2^(shift_Ki)/Ts;
Kp_error = Kp_actual/Kp_design-1;
Ki_error = Ki_actual/Ki_design-1;

% Calculate phase margin (Matlab-only)
try
    P = tf(G, [L R], 'iodelay', dly);
    C_actual = pid(Kp_actual, Ki_design);
    [~, ph_margin, ~, ~, cl_stable] = margin(P*C_actual);
catch
    ph_margin = NaN;
    cl_stable = 1;
end

fprintf('---- Design report: current loop ----\n\n');
fprintf('Initial parameters: L = %.2f mH, R = %.2f Ohm, Vref_DAC = %.2f V\nTarget closed loop bandwidth = %.1f kHz\n\n', L/1e-3, R, Vref, clbw);
fprintf('Results:\n');
if ~cl_stable
    fprintf('Not possible to achieve target closed loop bandwidth.\n');
else
    fprintf('Kp_shift = %d\n', shift_Kp);
    fprintf('Ki_shift = %d\n', shift_Ki);
    fprintf('Kp = %0.0f / 2^(15 + Kp_shift)\n', Kp_fpga);
    fprintf('Ki = %0.0f / 2^(15 + Ki_shift) / Ts\n', Ki_fpga);
    fprintf('Kp error = %0.2g%%\n', Kp_error*100);
    fprintf('Ki error = %0.2g%%\n', Ki_error*100);
    if ~isnan(ph_margin)
        fprintf('Phase margin = %0.0f°\n', ph_margin);
    end
    fprintf('NOTE: Kp and Ki gain are referred in DAC counts/ADC counts units\n');
end