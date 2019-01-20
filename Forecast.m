function x = Forecast(x,interval,period)

% MATLAB Forecast calculator: A simple time series forecasting calculator
% for making first-cut forecasts of accounting data.

% x is a quarterly time series imported from Excel, interval is the number
% of years into the future over which the initial forecast is to be made.

% Transpose to vertical if horizontal
xsize = size(x);
if xsize(2) > xsize(1)
    x = x.';
    h = true;
elseif xsize(2) < xsize(1)
    h = false;
end

if nargin==1
  % Default interval
  interval = 1;
  % Default period
  period = 4;
elseif nargin==2
  % Default period
  period = 4;
end

% Define the forecast matrix
Qend = length(x)-floor(length(x)/period)*period;
if Qend > 0
    flength = length(x)+interval*period+(period-Qend);
elseif Qend == 0
    flength = length(x)+interval*period;
end
fmatrix = nan(flength, 12);

% Add the index column
fmatrix(:, 1) = 1:length(fmatrix);

% Add the year numbers
periods = 4;
years = flength/period;
year = repmat(1:years,[periods 1]);
year = year(:)';
year = year';
fmatrix(:, 2) = year;

% Add the quarter numbers
quarter = repmat(1:periods,[1 years]);
quarter = quarter(:)';
quarter = quarter';
fmatrix(:, 3) = quarter;

% Add the time series data
fmatrix(1:length(x), 4) = x;

% Add the moving average
fmatrix(:, 5) = movmean(fmatrix(:,4),4);
fmatrix(1:2, 5) = nan;
fmatrix(end, 5) = nan;

% Add the centered moving average
CMA = movmean(fmatrix(:,5),2);
fmatrix(1:end-1, 6) = CMA(2:end);

% Add Y(t)/CMA
fmatrix(3:end-2, 7) = fmatrix(3:end-2, 4)./fmatrix(3:end-2, 6);

% Quarterly stuff
Q1 = find(fmatrix(:,3)==1);
Q1 = fmatrix(Q1,7);
Q1 = mean(Q1,'omitnan');
Q2 = find(fmatrix(:,3)==2);
Q2 = fmatrix(Q2,7);
Q2 = mean(Q2,'omitnan');
Q3 = find(fmatrix(:,3)==3);
Q3 = fmatrix(Q3,7);
Q3 = mean(Q3,'omitnan');
Q4 = find(fmatrix(:,3)==4);
Q4 = fmatrix(Q4,7);
Q4 = mean(Q4,'omitnan');
% Define the seasonality matrix
qmatrix = nan(4,2);
qmatrix(:, 1) = 1:length(qmatrix);
qmatrix(1, 2) = Q1;
qmatrix(2, 2) = Q2;
qmatrix(3, 2) = Q3;
qmatrix(4, 2) = Q4;

% Add S(t)
qmatrix = repmat(qmatrix,years);
fmatrix(:,8) = qmatrix(:,2);

% Add Y(t)/S(t)
fmatrix(:,9) = fmatrix(:, 4)./fmatrix(:, 8);

% Forecast terms
p = polyfit(fmatrix(1:length(x),1),fmatrix(1:length(x),9),1);
% Slope and intercept terms
m = p(1);
b = p(2);
% Add T(t)
fmatrix(:,10) = m*fmatrix(:,1)+b;

% Add the Forecast term, S(t)*T(t)
fmatrix(:,11) = (fmatrix(:,8)).*(fmatrix(:,10));

% Historical and Projected Time Series Data
fmatrix(1:length(x),12) = fmatrix(1:length(x),4);
projected = length(x)+1;
fmatrix(projected:end,12) = fmatrix(projected:end,11);

% Here we output the Historical and Projected values as a vector
x = fmatrix(:,12);

% If x was originally horizontal, convert back to horizontal
if h == true
    x = x.';
end
end