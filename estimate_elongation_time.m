clear
close all

addpath(genpath('./utilities'));

% attempt to estimate elongation time from autocorrelatio signal
load('./out/spot_struct.mat')

max_time = max([spot_struct.timeInterp]);
timeGrid = 0:30:max_time;
max_len = length(timeGrid);

% parameters
n_lags = 20;
bootstrap = 1;
trace_weights = ones(size(spot_struct));
n_boots = 100;

% initialize array to store traces
trace_array = zeros(max_len,length(spot_struct));

for i = 1:length(spot_struct)
    ft = ismember(timeGrid,spot_struct(i).timeInterp);
    trace_array(ft,i) = spot_struct(i).fluoInterp;
end    

% run autocorr
[wt_autocorr, a_boot_errors, wt_dd, dd_boot_errors, wt_ddd, ddd_boot_errors] = ...
    weighted_autocorrelation(trace_array, n_lags, bootstrap,n_boots,trace_weights);