function out = getValidGaps(GapStruct,valcodes,times,maxLength)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

nRows = length(valcodes);
% Confirm gaps are flanked by valid data
gapIdx = [1:GapStruct.nEvents]';
startEnd = [GapStruct.eventStartEnd,gapIdx]; % get gap start and end rows

if isempty(startEnd)
    out = 0;
else
    % Subset by excluding gaps starting at first or ending at last row
    includeGaps = intersect(find(startEnd(:,1)>1),find(startEnd(:,2)<nRows));
    startEnd = startEnd(includeGaps,:);

    beforeGap = startEnd(:,1)-1; % Sample before gap
    afterGap = startEnd(:,2)+1; % Sample after gap, indexed

    beforeValCode = valcodes(beforeGap); % Validity code for previous sample
    afterValCode = valcodes(afterGap); % Validity code for subsequent sample

    % Subset gaps by including only those flanked by valid samples
    gapsToCheckLengthIdx = intersect(find(beforeValCode<2),find(afterValCode<2));
    startEnd = startEnd(gapsToCheckLengthIdx,1:2);

    % Get gap durations
    timeStartEnd = times([startEnd(:,1)-1,startEnd(:,2)]);
    timeGapDiff = diff(timeStartEnd,1,2); 

    % Check which gaps are 'valid' gaps - i.e. with gap lengths < max gap
    % length
    validGapRows = startEnd(timeGapDiff<maxLength,:);

    out = validGapRows;
end
end

