function [trialData, trialHeaders] = combineGapTrialArrays(inData,summaryType)
%COMBINEGAPTRIALARRAYS Combine arrays of gap/baseline or overlap trials
%   inData as {Nx3} cell array input with 3 cells {BASELINE,GAP,OVERLAP}
    
   % Get baseline array and headers
   [baseArr,baseHeaders] = createGapTrialArray(inData(:,1),'BASELINE',summaryType);

   % Get Gap array and headers
   [gapArr,gapHeaders] = createGapTrialArray(inData(:,2),'GAP',summaryType);

   % Get overlap array and headers
   [overArr,overHeaders] = createGapTrialArray(inData(:,3),'OVERLAP',summaryType);

   % concatenate headers
   trialHeaders = horzcat(gapHeaders,baseHeaders,overHeaders);

   % concatenate data
   trialData = horzcat(gapArr,baseArr,overArr);
end