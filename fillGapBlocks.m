function out = fillGapBlocks(dataToFill,timeinMs)
%FILLGAPBLOCKS Interpolate data with gap between first and low row
%   Data with a valid gap is filled in by interpolating between the first
%   and last data row. 

[nRows,~] = size(dataToFill);
% Gap starts from second row
gapStart = 2;
% Gap ends last but one row
gapEnd = nRows-1;

% Start and end data to interpolate between
x1 = timeinMs(1);
y1 = dataToFill(1,:);
x2 = timeinMs(nRows);
y2 = dataToFill(nRows,:);

% Interpolate between points
x = [x1;x2];
y = [y1;y2];
xi = [timeinMs(gapStart:1:gapEnd)];
newValues = interp1q(x,y,xi);

% Return interpolated values
out = newValues;
end

