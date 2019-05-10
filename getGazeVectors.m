function [u1,u2] = getGazeVectors(gazeDat,posDat,eye,merge)
%GETGAZEVECTORS Calculate gaze vectors based on 3D gaze and eye position data
%   gazeDat is 3d gaze point for left and right eye. posDat is the 3D eye
%   position for both eyes. eye is left/right or average. merge is a
%   boolean used only when merging adjacent fixations as the eye position
%   data for sample 1 and 2 is averaged

if strcmpi(eye,'Left')
    gazePointSample1 = gazeDat(1,1:3); % 3D Gaze point for sample 1 (left eye)
    gazePointSample2 = gazeDat(2,1:3); % 3D Gaze point for sample 2 (left eye)
    eyePositionSample1 = posDat(1,1:3); % 3D Eye position for sample 2 (left eye)
    eyePositionSample2 = posDat(2,1:3); % 3D Eye position for sample 2 (left eye)
    
elseif strcmpi(eye,'Right')
    gazePointSample1 = gazeDat(1,4:6); % 3D Gaze point for sample 1 (right eye)
    gazePointSample2 = gazeDat(2,4:6); % 3D Gaze point for sample 2 (right eye)
    eyePositionSample1 = posDat(1,4:6); % 3D Eye position for sample 2 (right eye)
    eyePositionSample2 = posDat(2,4:6); % 3D Eye position for sample 2 (right eye)
    
else
    gazePointSample1 = mean([gazeDat(1,1:3);gazeDat(1,4:6)]);
    gazePointSample2 = mean([gazeDat(2,1:3);gazeDat(2,4:6)]);
    eyePositionSample1 = mean([posDat(1,1:3);posDat(1,4:6)]);
    eyePositionSample2 = mean([posDat(2,1:3);posDat(2,4:6)]);
end
    
if merge
    eyePosition = nanmean([eyePositionSample1; eyePositionSample2]); 
else
    eyePosition = eyePositionSample2;
end

% Vector from current eye position to previous gaze point
u1 = [eyePosition - gazePointSample1]; 
% Vector from current eye position to current gaze point
u2 = [eyePosition - gazePointSample2]; 


    
    
% % Use both eyes
% if valcode(1) <2 && valcode(2) <2
%     gaze = mean([gazeDat(1,1:3);gazeDat(1,4:6)]);
%     eye = mean([posDat(1,1:3);posDat(1,4:6)]);
%     eyeSelection = 'Both';
% 
% % Use left eye
% elseif valcode(1) < 2 && valcode(2) >=2
%     gaze = gazeDat(1,1:3);
%     eye = posDat(1,1:3);
%     eyeSelection = 'Left';
% % Use right eye    
% elseif valcode(1) >= 2 && valcode(2) < 2
%     gaze = gazeDat(1,4:6);
%     eye = posDat(1,4:6);
%     eyeSelection = 'Right';
% end

end

