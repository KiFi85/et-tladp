function [timeEventDiff,timeEventRuns,...
    eventRows,eventIndexRuns] = getEventDurations(eStruct,times)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

startEnd = eStruct.eventStartEnd;
nEvents = eStruct.nEvents;
eventDurations = eStruct.eventDurations;

startEndCell = mat2cell(startEnd,repelem(1,nEvents));
eventRows = cellfun(@(x)x(1):x(2),startEndCell,'UniformOutput',false);
% Rows in event vector where event occurs
eventRows = [eventRows{:}]; 

if ~isempty(eventRows)
    
    if nEvents > 1
        timeStartEnd = times([startEnd(:,1)-1,startEnd(:,2)]);
        timeEventDiff = diff(timeStartEnd,1,2); % Get event duration

    else
        startTime = times(startEnd(:,1)-1);
        endTime = times(startEnd(:,2));
        timeEventDiff = endTime - startTime;
    end

    timeEventRuns = repelem(timeEventDiff,eventDurations);

    % Get event numbers to add to indexed rows, based on runs
    eventIndexRuns = repelem(1:nEvents,eventDurations);
    
else
    
timeEventDiff=0;
timeEventRuns=0;
eventRows=0;
eventIndexRuns=0;
end

end

