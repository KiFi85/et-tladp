function colNo = getColumnNoByRef(findCols,refCols)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% findvars = varnames; % Variable cell array to find
% refvars = varmaster; % Cell array of all variables for searching

[varRows,varCols] = size(findCols); % Number of variables to look up
colNo = cell(varRows,varCols); % Empty cell array for col indices

for iVar = 1:varRows
    [~,idx] = intersect(refCols,findCols{iVar,1},'stable'); % Find col index
    colNo(iVar,1) = {idx};
end

end





