function idx = getNodeIndex(node)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    % Get all task nodes
    allNodes = node.Parent.Children;
    
    % Find which task item
    [~, idx] = ismember(node, allNodes);
end

