function str = format_eng(num, unit)
  %% -- str = format_eng(num, unit)
  %%
  %% Format the provided number [num] using engineering notation and
  %% append the unit [unit] to the final string.
  %%
  %% Example: >> format_eng(15000, 'Ohms') 15.00 kOhms

  eng_mag = {'T', 'G', 'M', 'k', '', 'm', 'u', 'n', 'p', 'f', 'a'};
  mag_sel = 5;

  while (abs(num) >= 1000 && mag_sel > 1)
	num = num / 1000;
	mag_sel = mag_sel - 1;
  end

  while (abs(num) < 1 && mag_sel < 11)
	num = num * 1000;
	mag_sel = mag_sel + 1;
  end

  str = sprintf('%.2f %s%s', num, eng_mag{mag_sel}, unit);
end
