function [r1 r2 err] = sel_res_ratio(ratio, min_res, series)
  %% -- [r1 r2 err] = sel_res_ratio(ratio)
  %% -- [r1 r2 err] = sel_res_ratio(ratio, min_res)
  %% -- [r1 r2 err] = sel_res_ratio(ratio, min_res, series)
  %%
  %% Finds a pair of standard resistors that best matches the provided
  %% ratio (ratio = r1 / r2). Return the resistors values and the
  %% relative error of the match as a percentage relative to the
  %% desired ratio.
  %%
  %% The minimum resistance value is 1k by default and can be set by
  %% the min_res argument.
  %%
  %% The resistor series is set to 'E24' by default and can be changed
  %% by the series argument:
  %%
  %%   series = 'E6'  # tolerance 20%
  %%   series = 'E12' # tolerance 10%
  %%   series = 'E24' # tolerance 5% and 1%
  %%   series = 'E48' # tolerance 2%
  %%   series = 'E96' # tolerance 1%

  if nargin < 2
      min_res = 1000;
  end
  if nargin < 3
      series = 'E24';
  end
  
  if (strcmp(series, 'E6'))
	res_table = [1 1.5 2.2 3.3 4.7 6.8];
  elseif (strcmp(series, 'E12'))
	res_table = [1 1.2 1.5 1.8 2.2 2.7 3.3 3.9 4.7 5.6 6.8 8.2];
  elseif (strcmp(series, 'E24'))
	res_table = [1 1.1 1.2 1.3 1.5 1.6 1.8 2 2.2 2.4 2.7 3 ...
				   3.3 3.6 3.9 4.3 4.7 5.1 5.6 6.2 6.8 7.5 8.2 9.1];
  elseif (strcmp(series, 'E48'))
	res_table = [1 1.05 1.1 1.15 1.21 1.27 1.33 1.4 1.47 1.54 1.62 1.69 ...
				   1.78 1.87 1.96 2.05 2.15 2.26 2.37 2.49 2.61 2.74 2.87 3.01 ...
				   3.16 3.32 3.48 3.65 3.83 4.02 4.22 4.42 4.64 4.87 5.11 5.36 ...
				   5.62 5.9 6.19 6.49 6.81 7.15 7.5 7.87 8.25 8.66 9.09 9.53];
  elseif (strcmp(series, 'E96'))
	res_table = [1 1.02 1.05 1.07 1.1 1.13 1.15 1.18 1.21 1.24 1.27 1.3 ...
				   1.33 1.37 1.4 1.43 1.47 1.5 1.54 1.58 1.62 1.65 1.69 1.74 ...
				   1.78 1.82 1.87 1.91 1.96 2 2.05 2.1 2.15 2.21 2.26 2.32 ...
				   2.37 2.43 2.49 2.55 2.61 2.67 2.74 2.8 2.87 2.94 3.01 3.09 ...
				   3.16 3.24 3.32 3.4 3.48 3.57 3.65 3.74 3.83 3.92 4.02 4.12 ...
				   4.22 4.32 4.42 4.53 4.64 4.75 4.87 4.99 5.11 5.23 5.36 5.49 ...
				   5.62 5.76 5.9 6.04 6.19 6.34 6.49 6.65 6.81 6.98 7.15 7.32 ...
				   7.5 7.68 7.87 8.06 8.25 8.45 8.66 8.87 9.09 9.31 9.53 9.76];
  end

  res_table = [res_table 10*res_table];

  adj_factor = 1;

  while (ratio > (adj_factor * res_table(end)))
	adj_factor = adj_factor * 10;
  end

  while (ratio < (adj_factor / res_table(end)))
	adj_factor = adj_factor / 10;
  end

  best_ratio_diff = ratio * 256;

  for test_r1 = adj_factor * res_table(1:end)
	for test_r2 = res_table(1:end)
	  test_ratio = test_r1 / test_r2;
	  if (abs(test_ratio - ratio) < best_ratio_diff)
		best_ratio_diff = abs(test_ratio - ratio);
		r1 = test_r1;
		r2 = test_r2;
	  end
	end
  end

  while (r1 < min_res || r2 < min_res)
	r1 = r1 * 10;
	r2 = r2 * 10;
  end

  err = 100*((r1 / r2) - ratio) / ratio;
end
