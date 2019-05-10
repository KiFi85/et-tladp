function out = getBufferPaths(gazePath)

% get list of files in path
d = dir(gazePath);

% Get index of filename
mainIdx = find(~cellfun(@isempty,regexp({d.name},'mainBuffer')));
timeIdx = find(~cellfun(@isempty,regexp({d.name},'timeBuffer')));
eventIdx = find(~cellfun(@isempty,regexp({d.name},'eventBuffer')));

if ~isempty(mainIdx) && ~isempty(timeIdx) && ~isempty(eventIdx)
    mainBuffer = fullfile(gazePath,d(mainIdx).name);
    timeBuffer = fullfile(gazePath,d(timeIdx).name);
    eventBuffer = fullfile(gazePath,d(eventIdx).name);
    out = {mainBuffer,timeBuffer,eventBuffer};
else
    out = 0;
end

end