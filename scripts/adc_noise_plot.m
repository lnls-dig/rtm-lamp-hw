function adc_noise_plot(csv_file, period)
  data = csvread(csv_file) * 6.25e-2; % convert to mA
  time = 0:period:(length(data)-1)*period;
  freq = (1/(period * length(time) * 2)):(1/(period * length(time) * 2)):1/period;
  freq = freq(1:(length(time)/2));

  for i = 0:1:(size(data,2) - 1)
	cur_vec = data(:,i + 1);
	figure();
	subplot(2, 1, 1);
	set(gca, 'ytick', -1:0.2:1);
	plot(time, cur_vec);
	ylabel("Current [mA]");
	xlabel("Time [s]");
	title(sprintf("CH%d", i));
	grid on;

	subplot(2, 1, 2);
	spectrum = fft(cur_vec);
	half_spectrum = spectrum(1:length(freq));
	half_spectrum(1) = 0;
	semilogx(freq, abs(half_spectrum)/length(cur_vec));
	ylabel("Current [mA]");
	xlabel("Frequency [Hz]");
	title(sprintf("CH%d", i));
	grid on;
	file = sprintf("noise_ch%d.png", i);
	saveas(gcf, file);
	close;
  end
end
