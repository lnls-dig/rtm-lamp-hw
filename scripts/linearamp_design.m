% Analysis script to aid on the design of linear power amplifiers with
% inductive loads.

% Copyright (C) 2017 CNPEM
% Licensed under GNU General Public License v3.0 (GPL)
%
% Author(s): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

R = 1;                  % Load resistance [ohm]
L = 3.5e-3;             % Load inductance [H]

dvdt_max = 1.4e6;       % Maximum amplifier slew rate [V/s]

Vs = 3.6;               % Amplifier supply voltage [V]
I_FS = 1;               % Fullscale current [A]

Pmax = 3.6;             % Maximum power consumption [VA]
Pmax_amp = 3;           % Maximum power dissipation on amplifier [W]

fb_CL_bw = 10e3;        % Current feedback loop reference tracking bandwidth [Hz]
fb_delay = 1/580e3;     % Current feedback loop delay [s]

tavg_P_req = -1;        % Integration time of average power [s]; if tavg_P <= 0, assume one period of periodic signal

plot_limits = true;     % If true, plot the corresponding operation limits

% Current setpoint waveforms
wvfs = {};
j = 1;
% Sine wave: frequency: 10 kHz; amplitude: 1% full scale; offset: aprox. full scale
wvfs{j} = genwvf('sin', 10e3, 0.01*I_FS, 0.99*I_FS, 10, 1000); j=j+1;
% Triangular wave: frequency: 150 Hz; amplitude: full scale; offset: 0
wvfs{j} = genwvf('triang', 150, I_FS, 0, 10, 1000); j=j+1;
% Trapezoidal wave: frequency: 100 Hz; amplitude: full scale; offset: 0; ramp time (from -amplitude to amplitude): 3 ms
wvfs{j} = genwvf('trapz', 100, I_FS, 0, 10, 1000, 3e-3); j=j+1;
% Trapezoidal wave: frequency: 1 kHz; amplitude: 0.8% full scale; offset: 0; ramp time (from -amplitude to amplitude): 3 us
wvfs{j} = genwvf('trapz', 1000, 0.008*I_FS, 0, 10, 10000, 3e-6); j=j+1;

for j=1:length(wvfs)
    i_setpoint = wvfs{j}.y;
    t = wvfs{j}.t;
    npts_period = wvfs{j}.period;
    ts = t(2)-t(1);
    nperiods = length(t)/npts_period;
    
    % Transfer functions
    tf_i_v = tf(1, [L R]);
    tf_vl_v = tf([L 0], [L R]);
    tf_vr_v = tf(R, [L R]);
    tf_v_isetpoint = tf([L R], [1/(2*pi*fb_CL_bw) 1]);
    
    % Simulate signals
    v = lsim(tf_v_isetpoint, i_setpoint, t);
    dvdt = lsim(tf_v_isetpoint*tf([1 0],[ts/2 1]), i_setpoint, t);
    i = lsim(tf_v_isetpoint*tf_i_v, i_setpoint, t);
    v_l = lsim(tf_v_isetpoint*tf_vl_v, i_setpoint, t);
    v_r = lsim(tf_v_isetpoint*tf_vr_v, i_setpoint, t);
    
    % Calculate power consuption/dissipation in different elements
    P_l = v_l.*i;
    P_r = v_r.*i;
    P_amp = (Vs.*sign(i)-v).*i;
    P_total = Vs.*abs(i);
    
    % Bundle signals
    v_all = [v v_r v_l];
    i_all = [i i_setpoint];
    P_all = [P_total P_amp P_r P_l];
    
    % Calculate average power
    if tavg_P_req <= 0
        navg_P = npts_period;
    else
        navg_P = round(tavg_P_req/ts);
        if navg_P == 0
            navg_P = 1;
        end
    end
    tavg_P = navg_P*ts;
    avg_P = filter(ones(navg_P, 1)/navg_P, 1, P_all);
    avg_P_1cycle = avg_P(end, :);
    
    % Crop data to avoid transient
    npts_discard = (nperiods-1)*npts_period;
    v_all = v_all(npts_discard+1:end, :);
    i_all = i_all(npts_discard+1:end, :);
    P_all = P_all(npts_discard+1:end, :);
    dvdt = dvdt(npts_discard+1:end, :);
    avg_P = avg_P(npts_discard+1:end, :);
    t_crop = t(1:end-npts_discard);
    
    if any(abs(v_all(:,1)) > Vs)
        warning(sprintf('Power amplifier output voltage exceeds supply voltage in waveform #%d.', j));
    end
    
    if any(abs(dvdt) > dvdt_max)
        warning(sprintf('dv/dt exceeds maximum slew rate of power amplifier in waveform #%d.', j));
    end
    
    % Plot results
    %figure;
    figure('units', 'normalized', 'outerposition', [0 0 1 1], 'name', sprintf('Waveform #%d', j))
    
    % Currents
    subplot(221);
    ax(1) = gca;
    if plot_limits
        plot([0 t_crop(end) 0 0 t_crop(end)], [repmat(I_FS, 2, 1); NaN; repmat(-I_FS, 2, 1)], 'LineWidth', 2);
        
        hold on
    end
    plot(t_crop, i_all);
    if plot_limits
        legend(sprintf('I_{max} = %0.2g A', I_FS), 'i', 'i_{setpoint}')
    else
        legend('i_{setpoint}', 'i')
    end
    xlabel('Time [s]');
    ylabel('Current [A]');
    title('Currents');
    grid on
    
    % Voltages
    subplot(222);
    ax(2) = gca;
    if plot_limits
        plot([0 t_crop(end) 0 0 t_crop(end)], [repmat(Vs, 2, 1); NaN; repmat(-Vs, 2, 1)], 'LineWidth', 2);
        hold on
    end
    plot(t_crop, v_all);
    if plot_limits
        legend(sprintf('V_{max} = %0.2g V', Vs), 'v', 'v_R', 'v_L')
    else
        legend('v', 'v_R', 'v_L')
    end
    xlabel('Time [s]');
    ylabel('Voltage [V]');
    title('Voltages');
    grid on

    % Slew rate
    subplot(223);
    ax(3) = gca;
    if plot_limits
        plot([0 t_crop(end) 0 0 t_crop(end)], [repmat(dvdt_max/1e6, 2, 1); NaN; repmat(-dvdt_max/1e6, 2, 1)], 'LineWidth', 2);
        hold on
    end
    plot(t_crop, dvdt/1e6);
    if plot_limits
        legend(sprintf('dv/dt_{max} = %0.2g \\muV/s', dvdt_max/1e6), 'dv/dt')
    else
        legend('dv/dt')
    end
    xlabel('Time [s]');
    ylabel('Slew rate [\muV/s]');
    title('Slew rate');
    grid on
    
    % Power
    subplot(224);
    ax(4) = gca;
    if plot_limits
        plot([0 t_crop(end)], [repmat(Pmax, 2, 1) repmat(Pmax_amp, 2, 1)], 'LineWidth', 2)
        clr = lines;
        clr = [clr([1 2], :); clr([1:4 1:4], :)];
        set(gca, 'ColorOrder', clr);
        hold on
    end
    plot(t_crop, P_all);
    if plot_limits
        plot(t_crop, avg_P, '--');
    end
    if plot_limits
        legend(sprintf('P_{max} = %0.2g W', Pmax), sprintf('P_{amp_{max}} = %0.2g W', Pmax_amp), 'P_{total}', 'P_{amp}', 'P_R', 'P_L', sprintf('P_{total_{avg}} (\\tau = %0.2g s)', tavg_P), sprintf('P_{amp_{avg}} (\\tau = %0.2g s)', tavg_P), sprintf('P_{R_{avg}} (\\tau = %0.2g s)', tavg_P), sprintf('P_{L_{avg}} (\\tau = %0.2g s)', tavg_P))
    else
        legend('P_{total}', 'P_{amp}', 'P_R', 'P_L')        
    end
    xlabel('Time [s]');
    ylabel('Power [VA] or [W]');
    title('Power');
    grid on
    
    try
        linkaxes(ax, 'x')
    end
    
    % Plot parameters text
    axes('Position',[0 0.375 0.09 0.25], 'Visible', 'off');
    text(.1, 0.5, ...
        {'Load'; ...
        '- - - - - - - - - - - - - - -'; ...
        sprintf('R = %0.2g ohm', R); ...
        sprintf('L = %0.2g mH', L/1e-3); ...
        ''; ...
        'Current Feedback'; ...
        '- - - - - - - - - - - - - - -'; ...
        sprintf('BW = %0.3g kHz', fb_CL_bw/1e3); ...
        sprintf('delay = %0.3g \\mus', fb_delay*1e6)} ...
        );
end