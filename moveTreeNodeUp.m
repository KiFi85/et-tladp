function [node1,node2] = moveTreeNodeUp(selectedNode)    

    % Get all children (AOI) nodes
    childNodes = selectedNode.Parent.Children;
    % Get all node names (all AOIs for particular image)
    nodeNames = {childNodes.Text};
    % Find the position of the selected node
    pos = find(strcmp(nodeNames,selectedNode.Text));
    
    % If in first position, can't move AOI up
    if pos == 1
        msgbox("Can't move up as first AOI")
    else
        node1 = childNodes(pos);
        node2 = childNodes(pos-1);
        move(node1,node2,'before');
    end
end