function [deg,vel] = calculateAngularVelocity(u,v,timeDiffMs)
%CALCULATEANGULARVELOCITY Calculate the angular velocity between two
%vectors
%   The angular velocity between two gaze vector samples is calculated by 
%   dividing the degrees between the normalised vectors by the difference
%   in time between the samples (in seconds) to give degrees/second

vectorDegrees = atan2d(norm(cross(u,v)),dot(u,v));
if nargin == 3
    angularvelocity = vectorDegrees/timeDiffMs*1000;
    vel = angularvelocity;
else
    vel = 0;
end

deg = vectorDegrees;

end

