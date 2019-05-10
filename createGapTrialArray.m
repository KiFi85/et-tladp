function [arrOut,headers] = createGapTrialArray(inData,trialType,summaryType)
%CREATEGAPTRIALARRAY Create array of gap/baseline or overlap trials
%   inData as cell array input, determine max trials create array,
%   calculate mean per row, create headers. summaryType = TTFF,TFD or TLT

    %% CREATE ARRAY
    
    % Determine max gap trials across subjects
    maxTrials = max(cellfun(@numel,inData));
    
    % Expand cell array to size of largest number of trials
    % fill empty spaces with 0
    filledData = cellfun(@(x) [x, repmat({'No Trial'},1,maxTrials-numel(x))], inData, 'UniformOutput', false);
    
    % Create cell array
    trialArray = vertcat(filledData{:});
    
    % Create copy of trialArray
    % Replace any character values with NaN
    
    nanCell = trialArray;
    nanIdx = cellfun(@ischar,trialArray);
    nanCell(nanIdx) = {NaN};

    % Convert to numeric array
    % Calculate mean
    numArr = cell2mat(nanCell);
    
    if strcmpi(summaryType,'TTFF')
        % Calculate mean by row
        rowMeans = nanmean(numArr,2); 
        % Add mean column to array
        trialArray(:,maxTrials+1) = num2cell(rowMeans);

    elseif strcmpi(summaryType,'TFD') || strcmpi(summaryType,'TLT')
        % Get means for AOI Hit On Ps
        numArrPs = numArr(:,1:2:end-1);
        rowMeansPs = nanmean(numArrPs,2);
        
        % Get means for AOI hit Not On Ps
        numArrNotOnPs = numArr(:,2:2:end);
        rowMeansNotOnPs = nanmean(numArrNotOnPs,2);
        
        % Add mean columns (ps/not on ps) to array
        rowMeans = [rowMeansPs,rowMeansNotOnPs];
        trialArray(:,maxTrials+1:maxTrials+2) = num2cell(rowMeans);

    end

    arrOut = trialArray;
    
    %% CREATE HEADERS
    headers = createGapTrialHeaders(trialType,summaryType,maxTrials);
    
end

