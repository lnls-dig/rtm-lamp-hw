%% Calculating possible values for R and Gain with SNR

%System parameters
I_FS =  1; % full-scale current, rms [A]
Rs = [10:100]*1e-3; % shunt resistor values

rs_len = length(Rs)

% AD8429 parameters
max_gain = 10e3;

% Set noise target
SNR_target = 80;

%Set ADC noise (will dominate noise)
SNR_adc = 82;
fs = 1.2e6;
FS_adc = 2/sqrt(2);
ADC_noisefloor = FS_adc*10^(-SNR_adc/20)/sqrt(fs/2);

Gain = FS_adc*sqrt(2)./(Rs*I_FS); % max peak voltage equal to ADC
                                  % full scale

Rs(Gain > max_gain) = NaN;
Gain(Gain > max_gain) = NaN;

inamp_noise = zeros(1,rs_len);

for i = 1:rs_len
    inamp_noise(i) = ad8429_noise(Gain(i),Rs(i));
end

total_noise = sqrt(inamp_noise.^2+ADC_noisefloor.^2)*sqrt(fs/2);
final_snr = db(FS_adc./total_noise);

plot(Rs,Gain, '-o');
xlabel('Shunt resistance');
ylabel('InAmp (AD8429) gain');

yyaxis right;
plot(Rs,final_snr,'-o');
ylabel('Full-bandwidth SNR at ADC');
grid on;
legend('InAmp Gain','Final SNR');

title('Resistance vs Gain and SNR for full-scale signal at ADC');

