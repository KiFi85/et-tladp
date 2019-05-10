function rows = returnRowsToMerge(gazeData,positionData,gapRows,maxAngle,eye)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here

beforeGap = gapRows(:,1)-1; % Last fixation before gap
afterGap = gapRows(:,2)+1; % First fixation after gap, indexed

[nGaps,~] = size(gapRows);
rowData = zeros(nGaps,2);

for iGap = 1:nGaps

    prevRow = beforeGap(iGap); % Last fixation before gap
    afterRow = afterGap(iGap); % First fixation after gap
    
    % Get gaze vectors
    [vec1,vec2] = getGazeVectors(...
        gazeData([prevRow afterRow],:),positionData([prevRow afterRow],:),...
        eye,1);

    % Calculate degrees between samples
    [degrees,~] = calculateAngularVelocity(vec1,vec2);
    
    % If degrees less than the max angle property, add row
    if degrees <=maxAngle
        rowData(iGap,:) = gapRows(iGap,:);
    end
    
end

rows = rowData(rowData(:,1)>0,:);
end

