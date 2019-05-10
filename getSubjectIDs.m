function [ids,paths] = getSubjectIDs(studyPath)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% files and folders in subject directory
mainFolder = dir(studyPath);
% folders in subject directory
subFolders=mainFolder([mainFolder(:).isdir]);
% Remove '.' and '..'
subFolders(ismember( {subFolders.name}, {'.', '..'})) = [];

ids = {subFolders(:).name}';
paths = {subFolders(:).folder}';
paths = fullfile(paths,ids);

% Check that subject folders contain a gaze directory
validSubjects = cellfun(@(x) getGazeDirectory(x),paths,...
    'UniformOutput',false);

% Subset ids and paths to contain only those with a valid gaze folder
ids=ids(find(~cellfun(@isempty,validSubjects)));
paths=paths(find(~cellfun(@isempty,validSubjects)));
end

