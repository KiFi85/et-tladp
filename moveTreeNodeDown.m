function [node1,node2] = moveTreeNodeDown(selectedNode)    

    % Get all children (AOI) nodes
    childNodes = selectedNode.Parent.Children;
    % Get all node names (all AOIs for particular image)
    nodeNames = {childNodes.Text};
    % Number of AOIs
    nNodes = numel(childNodes);
    % Find the position of the selected node
    pos = find(strcmp(nodeNames,selectedNode.Text));

    % If pos = n can't move down
    if pos == nNodes
        msgbox("Can't move down as last AOI")
    else
        % Move nodes
        node1 = childNodes(pos);
        node2 = childNodes(pos+1);
        move(node1,node2,'after');
        
    end

end