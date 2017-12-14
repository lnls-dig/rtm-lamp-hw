function wvf = genwvf(type, f, A, dc, nperiods, npts_period, arg1, arg2)
%GENWVF   Generate a periodic waveform.
%
%   wvf = genwvf(type, f, A, dc, nperiods, npts_period, arg1)
%
%   Inputs:
%       type:           Type of waveform: 'sin', 'triang', 'trapezoida'
%       f:              Frequency [Hz]
%       A:              Amplitude [a.u.]
%       dc:             DC offset value [a.u.]
%       nperiods:       Number of periods
%       npts_period:    Number of points per period
%       arg[1,2,...]:   Waveform arguments, depending on waveform 'type'
%                       For:
%                           type = 'trapz'
%                               arg1: 100% rise time [s] from -A to A
%
%   Outputs:
%       wvf:    waveform struct
%               wvf.y:      Waveform values [a.u.]
%               wvf.t:      Waveform time vector [s]
%               wvf.period: Number of points per period

% Copyright (C) 2017 CNPEM
% Licensed under GNU General Public License v3.0 (GPL)
%
% Author(s): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

if nargin < 6 || isempty(npts_period)
    npts_period = 1000;
end

if nargin < 7 || isempty(arg1)
    arg1 = 0;
end

if nargin < 8 || isempty(arg2)
    arg2 = 0;
end

t_ = (0:nperiods*npts_period-1)';
ts = 1/f/npts_period;
t = t_*ts;

switch type
    case {'sin', 'cos'}
        y = A*cos(2*pi*1/npts_period*t_) + dc;
    case {'triangular', 'triang'}
        y = A*sawtooth(2*pi*1/npts_period*t_ + pi/2, 0.5) + dc;
    case {'trapezoidal', 'trapz'}
        tramp = arg1;
        navg_ramp = round(tramp/ts);
        y = filter(ones(1, navg_ramp)/navg_ramp, 1, A*square(2*pi*1/npts_period*t_)) + dc;
    otherwise
        error('Unknown waveform type.');
end

wvf = struct(...
    'y', y, ...
    't', t, ...
    'period', npts_period ...
    );