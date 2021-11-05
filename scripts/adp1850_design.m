%%%% ADP1850 design %%%%

%%% VS1+ and VS2+ rail (ADP1850 CH1/CH2) %%%
adp_ch1_h_mos_rds_max = 4e-3; % Ohm
adp_ch1_h_mos_rds_min = 3e-3; % Ohm
adp_ch1_h_mos_qg = 8.4e-9; % C

adp_ch1_l_mos_rds_max = 1.1e-3; % Ohm
adp_ch1_l_mos_rds_min = 0.8e-3; % Ohm
adp_ch1_l_mos_qg = 29e-9; % C

adp_ch1_vin = 12;
adp_ch1_vout = 3.7;
adp_ch1_max_cur = 10; % A
adp_ch1_nom_cur = 8; % A
adp_ch1_freq = 580e3; % kHz
adp_ch1_acs = 24; % can be 3, 6, 12 or 24
adp_ch1_cout = 880e-6; % F

adp_ch1_ind_ipp = 0.3 * adp_ch1_max_cur;
adp_ch1_ind = (adp_ch1_vout*(adp_ch1_vin - adp_ch1_vout))/(adp_ch1_vin * adp_ch1_freq * adp_ch1_ind_ipp);
adp_ch1_ratio = (adp_ch1_vout - 0.6) / 0.6;
[adp_ch1_reg_r1 adp_ch1_reg_r2] = sel_res_ratio(adp_ch1_ratio);
adp_ch1_rfreq = 1000 * 96568 * ((adp_ch1_freq / 1000) ^ (-1.065));
adp_ch1_rlim = (adp_ch1_max_cur * 1.3 * adp_ch1_l_mos_rds_max) / 47e-6;
adp_ch1_rramp = (adp_ch1_ind * 7e9) / (adp_ch1_acs * adp_ch1_l_mos_rds_max);
adp_ch1_fcross = adp_ch1_freq / 12;
adp_ch1_rcomp = (0.97 * adp_ch1_acs * adp_ch1_l_mos_rds_min * 2 * pi * adp_ch1_fcross * adp_ch1_cout * adp_ch1_vout) / (500e-6 * 0.6);
adp_ch1_ccomp = 2 / (pi * adp_ch1_rcomp * adp_ch1_fcross);
adp_ch1_cc2 = adp_ch1_ccomp / 10;
adp_ch1_vcsmin = 0.75 - 0.5 * adp_ch1_ind_ipp * adp_ch1_l_mos_rds_min * adp_ch1_acs;
adp_ch1_vcsmax = 0.75 + (adp_ch1_max_cur - 0.5 * adp_ch1_ind_ipp) * adp_ch1_l_mos_rds_max * adp_ch1_acs;

adp_ch1_rcsg_str = '';
switch (adp_ch1_acs)
  case 3
	adp_ch1_rcsg_str = '47 kOhms';
  case 6
	adp_ch1_rcsg_str = '22 kOhms';
  case 12
	adp_ch1_rcsg_str = 'OPEN';
  case 24
	adp_ch1_rcsg_str = '100 kOhms';
end

fprintf('---- Design report: ADP1850 CH1 and CH2 ----\n\n');
fprintf('Initial parameters: Vin = %.2f V, Vout = %.2f V, Iload_max = %.2f A,\nFreq = %.1f kHz, Acs = %d, Cout = %.1f uF\n\n', adp_ch1_vin, adp_ch1_vout, adp_ch1_max_cur, adp_ch1_freq / 1000, adp_ch1_acs, adp_ch1_cout * 1e6);
fprintf('Results:\n');
fprintf('Inductor = %s\n', format_eng(adp_ch1_ind, 'H'));
fprintf('Voltage regulator resistors: R1 = %s, R2 = %s\n', format_eng(adp_ch1_reg_r1, 'Ohms'), format_eng(adp_ch1_reg_r2, 'Ohms'));
fprintf('Rfreq = %s\n', format_eng(adp_ch1_rfreq, 'Ohms'));
fprintf('Rlim = %s\n', format_eng(adp_ch1_rlim, 'Ohms'));
fprintf('Rramp = %s\n', format_eng(adp_ch1_rramp, 'Ohms'));
fprintf('Rcomp = %s\n', format_eng(adp_ch1_rcomp, 'Ohms'));
fprintf('Ccomp = %s\n', format_eng(adp_ch1_ccomp, 'F'));
fprintf('Cc2 = %s\n', format_eng(adp_ch1_cc2, 'F'));
fprintf('Rcsg = %s\n', adp_ch1_rcsg_str);
