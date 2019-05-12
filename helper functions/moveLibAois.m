function NewTasks = moveLibAois(node1,node2,Tasks)
% 2 AOI nodes entered to be indexed and moved in library

    % Get 2 aoi objects
    aoi1 = node1.UserData;
    aoi2 = node2.UserData;
    
    % Get task index
    taskIdx = getNodeIndex(node1.Parent.Parent);

    % Get image index
    imageIdx = getNodeIndex(node1.Parent);

    % Get aoi index
    aoiIdx1 = getNodeIndex(node1);
    aoiIdx2 = getNodeIndex(node2);
    
    % Move aoi 2 to aoi 1
    Tasks.Items(taskIdx).Images(imageIdx).Aois(aoiIdx1) = aoi1;
    % Move aoi 1 to aoi 2
    Tasks.Items(taskIdx).Images(imageIdx).Aois(aoiIdx2) = aoi2;
    
    
    % Replace Tasks Object
    NewTasks = Tasks;
end