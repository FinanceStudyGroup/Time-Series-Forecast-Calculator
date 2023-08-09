function x = Forecast(x,interval,mode)

    % MATLAB Forecast calculator: A simple time series forecasting calculator
    % for making first-cut forecasts of accounting data.
    
    % x is a quarterly time series imported from Excel, interval is the number
    % of years into the future over which the initial forecast is to be made.
    
    % This combined version allows for the following modes:
    % 1 Additive
    % 2 Multiplicative
    % 3 min(Additive,Multiplicative)
    % 4 max(Additive,Multiplicative)
    % 5 average(Additive,Multiplicative)
    
    % Historical and Projected y values will consist of the time series data
    % Historical Time Series Data for the Graph
    Historicaly = x;
    Hlength = length(x);
    
    % Transpose to vertical if horizontal
    xsize = size(x);
    if xsize(2) > xsize(1)
        x = x.';
        h = true;
    elseif xsize(2) < xsize(1)
        h = false;
    end
    
    % -----------------------------------------------------------------------
    % The two functions from which these modes derive are defined here
    function x = Additive(x,interval)
    % Additive Forecast Function
    % Define the forecast matrix
    Qend = length(x)-floor(length(x)/4)*4;
    if Qend > 0
        flength = length(x)+interval*4+(4-Qend);
    elseif Qend == 0
        flength = length(x)+interval*4;
    end
    fmatrix = nan(flength, 12);
    
    % Add the index column
    fmatrix(:, 1) = 1:length(fmatrix);
    
    % Add the year numbers
    periods = 4;
    years = flength/4;
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
    
    % Quarterly stuff (The function could be generalized for monthly data)
    % Add the 4-quarter sum
    fmatrix(:,5) = movsum(fmatrix(:,4),4);
    fmatrix(1:2,5) = nan;
    
    % Add the 8-quarter sum
    % lagmatrix is a simple way of adding a lagged vector of elements
    fmatrix(:,6) = lagmatrix(movsum(fmatrix(:,5),2),-1);
    
    % Add the CMA (CMA = SUM(8Q)/8)
    fmatrix(:,7) = fmatrix(:,6)/8;
    
    % Add (Ts-T) or (Ts-CMA), the (Actual - Trend) term
    fmatrix(:,8) = fmatrix(:,4)-fmatrix(:,7);
    
    % Quarterly stuff
    % VLOOKUP analog for finding seasonalities
    Q1 = find(fmatrix(:,3)==1);
    Q1 = fmatrix(Q1,8);
    Q1 = mean(Q1,'omitnan');
    Q2 = find(fmatrix(:,3)==2);
    Q2 = fmatrix(Q2,8);
    Q2 = mean(Q2,'omitnan');
    Q3 = find(fmatrix(:,3)==3);
    Q3 = fmatrix(Q3,8);
    Q3 = mean(Q3,'omitnan');
    Q4 = find(fmatrix(:,3)==4);
    Q4 = fmatrix(Q4,8);
    Q4 = mean(Q4,'omitnan');
    % Define the seasonality matrix
    % This consists of quarter names and average variations so far
    qmatrix = nan(4,5);
    qmatrix(:, 1) = 1:length(qmatrix(:,1));
    qmatrix(1, 2) = Q1;
    qmatrix(2, 2) = Q2;
    qmatrix(3, 2) = Q3;
    qmatrix(4, 2) = Q4;
    % Add the total error term
    qmatrix(1,3)=sum(qmatrix(:,2));
    % Add the average error term
    qmatrix(1,4)=(qmatrix(1,3))/4;
    % Calculate the adjusted seasonalities
    qmatrix(:,5)=qmatrix(:, 2)-qmatrix(1,4);
    
    % Add the seasonality vector to fmatrix
    qmatrix = repmat(qmatrix,years);
    fmatrix(:,9) = qmatrix(:,5);
    
    % Trend matrix
    historicalCMA = fmatrix(~isnan(fmatrix(:,7)),7);
    tmatrix = nan(4,1);
    % Add the last value of the historical CMA
    tmatrix(1) = historicalCMA(end);
    % Add the first value of the CMA
    tmatrix(2) = historicalCMA(1);
    % Calculate the growth in historical CMA
    tmatrix(3) = tmatrix(1)-tmatrix(2);
    % Calculate the average quarterly growth in the historical CMA
    tmatrix(4) = tmatrix(3)/(length(historicalCMA)-1);
    
    % Historical and Projected CMA
    projected = length(x)+1;
    projectedCMA = projected-2;
    historical = repmat(tmatrix(4),(flength-(projectedCMA-1)));
    historical = historical(:,1);
    historical = cumsum(historical);
    fmatrix(projectedCMA:end,7) = historical+fmatrix((projectedCMA-1),7);
    
    % Add the Forecast term, (CMA+Variation)
    fmatrix(:,10) = (fmatrix(:,7)+fmatrix(:,9));
    
    % Historical and Projected Time Series Data
    fmatrix(1:length(x),11) = fmatrix(1:length(x),4);
    fmatrix(projected:end,11) = fmatrix(projected:end,10);
    
    % Here we output the Historical and Projected values as a vector
    x = fmatrix(:,11);
    
    % End of Additive Forecast Function
    end
    % -----------------------------------------------------------------------
    function x = Multiplicative(x,interval)
    % Multiplicative Forecast Function
    % Define the forecast matrix
    Qend = length(x)-floor(length(x)/4)*4;
    if Qend > 0
        flength = length(x)+interval*4+(4-Qend);
    elseif Qend == 0
        flength = length(x)+interval*4;
    end
    fmatrix = nan(flength, 12);
    
    % Add the index column
    fmatrix(:, 1) = 1:length(fmatrix);
    
    % Add the year numbers
    periods = 4;
    years = flength/4;
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
    
    % End of Multiplicative Forecast Function
    end
    % -----------------------------------------------------------------------
    
    % Default settings interval,mode
    if nargin==1
      % Default interval
      interval = 1;
      % Default mode
      mode = 1;
    elseif nargin==2
      % Default mode
      mode = 1;
    end
    
    % Instantiate a variable called "y" which is an empty matrix
    % This step is implied by the mention of "y" later on.
    % y = [];
    
    % Modes: Applied across all columns
    % "Column" is instantiated by implication here.
    for Column = 1:width(x)
      if mode==1
        % 1 Additive
        y(:,Column) = [Additive(x(:,Column),interval)];
      elseif mode==2
        % 2 Multiplicative
        y(:,Column) = [Multiplicative(x(:,Column),interval)];
      elseif mode==3
        % 3 min(Additive,Multiplicative)
        y(:,Column) = min([Additive(x(:,Column),interval)], [Multiplicative(x(:,Column),interval)]);
      elseif mode==4
        % 4 max(Additive,Multiplicative)
        y(:,Column) = max([Additive(x(:,Column),interval)], [Multiplicative(x(:,Column),interval)]);
      elseif mode==5
        % 5 average(Additive,Multiplicative)
        y(:,Column) = ( [Additive(x(:,Column),interval)] + [Multiplicative(x(:,Column),interval)] )/2;
      end
    end
    
    % Delete the "Column" variable
    clear Column;
    
    % Set x to the results determined in the loop
    x = y;
  
    % -----------------------------------------------------------------------
    function MultiPlot(x,Hlength,Historicaly)
  
      % If the width of "x" equals 1
      if width(x) == 1
          % Projected Time Series Data for the Graph
          Projectedy = x;
          Projectedy = Projectedy((Hlength+1):end);
  
          % These lengths help define the Historical and Projected x values
          Plength = length(Projectedy);
          TotalLength = Hlength+Plength;
  
          % Historical and Projected x values will consist of x-tick names
          Historicalx = (1:1:Hlength);
          Projectedx = (Historicalx(end)+1):1:TotalLength;
  
          % Plotted Summary of Results
          HistoricalChart = bar(Historicalx,Historicaly);
          hold on;
          ProjectedChart = bar(Projectedx,Projectedy);
          set(HistoricalChart,'FaceColor',[31/255 73/255 125/255],'EdgeColor','none');
          set(ProjectedChart,'FaceColor',[79/255 129/255 189/255],'EdgeColor','none');
      
      % If the width of "x" is greater than 1
      elseif width(x) > 1
          % Plot the data
          for Column = 1:width(x)
              plot(x(:,Column),'-o','MarkerSize',2,'LineWidth',2.0)
              hold on
          end
          % Get rid of the column variable
          clear Column;
      end
  
      % Define where historical data ends
      xline(Hlength+0.5);
      % Assign x-tick marks every fourth data point
      xticks(0:4:length(x));
      ax=gca;
      ax.YGrid='on';
  
      % If the width of "x" is greater than 1
      if width(x) > 1
          ax.XGrid='on';
      end
  
      % Get rid of scientific notation
      ax.YRuler.Exponent = 0;
      % Get rid of tick marks
      set(gca,'TickLength',[0,0]);
  
      % Include commas in the y-tick format
      ytickformat('%,4.4g');
  
      % Title and label the plot
      title('Historical and Projected Time Series Data');
      xlabel('Fiscal Quarter');
      ylabel('Time Series Data');
  
      end
    % -----------------------------------------------------------------------
  
    % Plot the data
    MultiPlot(x,Hlength,Historicaly)
  
    % Return only forecasted data
    x = x( (Hlength+1:length(x)), :);
  
    % Round to 3 decimal places: Used for corporate data stated in thousands
    x = round(x,3);
    
    % If x was originally horizontal, convert back to horizontal
    if h == true
        x = x.';
    end
  
    % Display the results to the terminal
    disp(x);
  
    % End of Forecast function
    end
