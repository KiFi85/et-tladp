function valid = checkValidSample(valCodes,eye)
%checkValidSample Check the validity of the two samples based on eye
%selection
%   A boolean value is returned; for left eye selection, a valid sample is 
%   obtained when the left eye is detected for both samples; for right eye 
%   selection, a valid sample is obtained when the right eye is detected 
%   for both samples; for average, at least one eye must be detected for 
%   either sample; for strict average both eyes must be detected 

if strcmpi(eye,'Left') == 1
    validSample1 = valCodes(1,1) < 2;
    validSample2 = valCodes(2,1) < 2; % Both left eye samples valid
elseif strcmpi(eye,'Right') == 1
    validSample1 = valCodes(1,2) < 2;
    validSample2 = valCodes(2,2) < 2; % Both right eye samples valid
elseif strcmpi(eye,'StrictAverage') == 1
    validSample1 = valCodes(1,1) < 2 && valCodes(1,2) < 2; 
    validSample2 = valCodes(2,1) < 2 && valCodes(2,2) < 2; % Two eyes detected for both samples   
else
    validSample1 = valCodes(1,1) < 2 || valCodes(1,2) < 2; 
    validSample2 = valCodes(2,1) < 2 || valCodes(2,2) < 2; % At least one eye detected for both samples
end

if validSample1 == 0 || validSample2 == 0 % Either sample is invalid
    valid = 0;
else
    valid = 1;
end

end

