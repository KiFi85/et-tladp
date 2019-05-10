function out = getEventBlocks(filterStep,valcodes,classifications,times,aoiInOut)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if iscell(filterStep)
    filterStep = filterStep{1};
end
    
% Set validity code or classifications to character array
% Get character for searching for event
switch filterStep
    case 'Gap'
        charArray = arrayfun(@(s)mat2str(s),valcodes)';
        eventType = {'2','3','4'}; % Invalid data
    case {'F','S'}
        charArray = arrayfun(@(s)s{1:end}(1),classifications)';
        eventType = filterStep; % Fixation or saccade events
    case 'Merge'
        charArray = arrayfun(@(s)s{1:end}(1),classifications)';
        charArray = replace(charArray,'U','S'); % For ease remove U
        eventType = 'S'; % Gaps between fixations        
    case 'Discard'
        charArray = arrayfun(@(s)s{1:end}(1),classifications)';
        eventType = 'F'; % Fixation events
    case 'AOI'
        charArray = sprintf('%d', aoiInOut);
        charArray = replace(charArray,'NaN','0');
        eventType = '1'; % In or Out of AOI
    otherwise
        fprintf('Error, no such event\n')
end

% order of unique elements,run length and index 
[order,run,idx] = RunLength(charArray);

% Get details about event of interest: 
% Gap in data (Fill-in), Gap between fixations (Merge), Fixation/Saccade
eventOccurrences = regexp(order,eventType); % Event index of unique events
if iscell(eventOccurrences)
    eventOccurrences=sort([eventOccurrences{:}]);
end
    
eventStart = idx(eventOccurrences); % Get start index for each event
eventDurations = run(eventOccurrences); % Duration of each each
eventEnd = eventDurations + eventStart - 1; % Start index + runs
nEvents = length(eventOccurrences); % Total number of events
startEnd = [eventStart',eventEnd']; % Start and end index (row) for each event

% If looking at gaps - remove 1st and last line
if strcmpi(filterStep,'Merge')
    startEnd(1,:) = [];
    nEvents = nEvents-1;
    eventDurations(1) = [];
end 

eventStruct = struct('eventStartEnd',startEnd,'eventDurations',eventDurations,...
    'nEvents',nEvents);
out = eventStruct;
end

