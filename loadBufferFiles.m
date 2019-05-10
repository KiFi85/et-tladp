function [gazeBuffer,timeBuffer,eventBuffer] = loadBufferFiles(bufferPaths)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Empty buffers struct
buffers = struct([]);

% Loop through gaze folders in cell array
for iBuffer = 1:length(bufferPaths)
    
    % Load buffer files for each gaze folder
    temp = cellfun(@load,bufferPaths{iBuffer}, 'UniformOutput',false);
    % Save buffer files to struct fields
    buffers(iBuffer).mainBuffer = temp{1}.mainBuffer;    
    buffers(iBuffer).timeBuffer = temp{2}.timeBuffer;    
    buffers(iBuffer).eventBuffer = temp{3}.eventBuffer;    
end

% Where multiple buffer files have been obtained (after crash for example)
% combine to one
gazeBuffer = vertcat(buffers.mainBuffer);
timeBuffer = vertcat(buffers.timeBuffer);
eventBuffer = vertcat(buffers.eventBuffer);

buffersOut = {gazeBuffer,timeBuffer,eventBuffer};

end

