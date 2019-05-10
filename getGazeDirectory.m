function out = getGazeDirectory(subjPath)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

ctr = 0;
% files and folders in subject directory
mainFolder = dir(subjPath);
% folders in subject directory
subFolders=mainFolder([mainFolder(:).isdir]);
% Remove '.' and '..'
subFolders(ismember( {subFolders.name}, {'.', '..'})) = [];

% Loop through folders and check for gaze subfolder
% If exists - add to list
for iDir = 1:numel(subFolders)
    dataFolder = subFolders(iDir).name;
    gazePathCheck = fullfile(subFolders(iDir).folder,dataFolder,'gaze');
    
    if exist(gazePathCheck)
        ctr = ctr + 1;
        gazePath{ctr,1} = gazePathCheck;        
    end
end

if exist('gazePath','var')
    out = gazePath;
else
    out = {};
end
end

