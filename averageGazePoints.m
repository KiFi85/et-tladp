function [AvX,AvY] = averageGazePoints(x,y,eye)
%averageGazePoints average gaze coordinates for left and right eye
%   Calculate average gaze coordinates for left and/or right eye depending
%   on eye selection input parameter

% Replace off screen -1 with NaN
x(x == -1) = NaN;
y(y == -1) = NaN;

% average both eyes or just one if nan for one eye
if strcmpi(eye,'Left')
    AvX = nanmean(x(:,1),2);
    AvY = nanmean(y(:,1),2);
elseif strcmpi(eye,'Right')
    AvX = nanmean(x(:,2),2);
    AvY = nanmean(y(:,2),2);
else
    AvX = nanmean(x,2);
    AvY = nanmean(y,2);
end
    

end

