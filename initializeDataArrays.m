function [ttff,tfd,tlt] = initializeDataArrays(Task,SubjectData,nIds)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    taskType = Task.taskType;
    
    % If gaze contingent, will depend on imported data so size of arrays in
    % each cell will be determined at run time
    if strcmpi(taskType,"GAZE_CONTINGENT")
        
        if SubjectData.runTFD
            tfd = cell(nIds,3);
        else
            tfd = 0;
        end
        
        if SubjectData.runTTFF
            ttff = cell(nIds,3);
        else
            ttff = 0;
        end
        
        if SubjectData.runTLT
            tlt = cell(nIds,3);
        else
            tlt = 0;
        end
        return
    end

    % Total Fixation Duration
    if SubjectData.runTFD
        % Create table headers
        SubjectData.tfdHeaders = aoiTableHeaders(Task,1,'TFD');
        % Number of columns for creating empty array
        nTFDCols = length(SubjectData.tfdHeaders);
        % Return empty array
        tfd = cell(nIds,nTFDCols);
        % Single row of empty array for individual subject's data
        SubjectData.tFDData = cell(1,nTFDCols);
    else
        tfd = 0;
    end
    
    % Time to First Fixation
    if SubjectData.runTTFF
        SubjectData.ttffHeaders = aoiTableHeaders(Task,0,'TTFF');
        nTTFFCols = length(SubjectData.ttffHeaders);
        ttff = cell(nIds,nTTFFCols);
        SubjectData.tTFFData = cell(1,nTTFFCols);
    else
        ttff = 0;
    end
       
    % Total Looking Time
    if SubjectData.runTLT
        SubjectData.tLTHeaders = aoiTableHeaders(Task,1,'TLT');
        nTLTCols = length(SubjectData.tLTHeaders);
        tlt = cell(nIds,nTLTCols);
        SubjectData.tLTData = cell(1,nTLTCols);
    else
        tlt = 0;
    end
        
end

