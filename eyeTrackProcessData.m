function eyeTrackProcessData(SubjectData,ids,paths)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

nIds = length(ids);

%% EMPTY STORAGE ARRAYS

[tTFF,tFD,tLT] = initializeDataArrays(SubjectData.TaskObj,SubjectData,nIds);

% Loop through files/folders (loop through subjects)
for iSubj = 1:nIds
% for iSubj = 1
    % Subject ID
    id = ids{iSubj};
    SubjectData.subjectID = id;
    
    % Path to subject folder
    path = paths{iSubj};
    SubjectData.subjectDirectory = path;

    % Load data based on task type
    SubjectData.loadData;
    
    % Process Data
    SubjectData.processData;

    % Add Data to array
    if SubjectData.runTFD
        tFD(iSubj,:) = SubjectData.tFDData;
    end
    
    if SubjectData.runTTFF
        tTFF(iSubj,:) = SubjectData.tTFFData;
    end

    if SubjectData.runTLT
        tLT(iSubj,:) = SubjectData.tLTData;
    end
    
end

if SubjectData.runTFD
    SubjectData.writeTFD(ids,tFD);
end

if SubjectData.runTTFF
    SubjectData.writeTTFF(ids,tTFF);
end

if SubjectData.runTLT
    SubjectData.writeTLT(ids,tLT);
end

SubjectData.writeErrorLogFile;
SubjectData.writeDataLogFile;

msgbox('Done!');
end

