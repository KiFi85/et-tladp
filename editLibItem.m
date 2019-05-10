function NewTasks = editLibItem(selectedNode,Tasks,editDelete)
% Find out whether task, image or aoi
% If task, get parent, find node number and edit task name
% If image, get parent task, find node (child) number, edit image ID
% If AOI, get parent parent task, parent image, find node number, edit AOI
% name

    % User data type
    objType = selectedNode.UserData;
    
    % node Index (1=Task,2=Image,3=Aoi)
    if isa(objType,'EyeTrackTask')
        nodeIdx = 1;
    elseif isa(objType,'EyeTrackImage')
        nodeIdx = 2;
    elseif isa(objType,'EyeTrackAOI')
        nodeIdx = 3;
    end
    
    switch nodeIdx
        %% TASK NODE
        case 1
            % Get task item index
            taskIdx = getNodeIndex(selectedNode);

            if strcmp(editDelete,'EDIT')
                % Replace task name 
                Tasks.Items(taskIdx).taskName = selectedNode.Text;
            else
                % Delete Task
                Tasks.Items(taskIdx) = [];
            end
            
        %% IMAGE NODE
        case 2

            % Get task index
            taskIdx = getNodeIndex(selectedNode.Parent);

            % Get image index
            imageIdx = getNodeIndex(selectedNode);

            if strcmp(editDelete,'EDIT')
                % Replace image ID
                Tasks.Items(taskIdx).Images(imageIdx).imageID = selectedNode.Text;
            else
                % Delete Image
                Tasks.Items(taskIdx).Images(imageIdx) = [];
            end
            
        %% AOI NODE
        case 3
            % Get task index
            taskIdx = getNodeIndex(selectedNode.Parent.Parent);

            % Get image index
            imageIdx = getNodeIndex(selectedNode.Parent);

            % Get aoi index
            aoiIdx = getNodeIndex(selectedNode);

            if strcmp(editDelete,'EDIT')
                % Edit aoi name
                Tasks.Items(taskIdx).Images(imageIdx).Aois(aoiIdx).aoiName = selectedNode.Text;
            else
                % Delete aoi
                Tasks.Items(taskIdx).Images(imageIdx).Aois(aoiIdx) = [];
            end
    end
    
    % Replace Tasks Object
    NewTasks = Tasks;
end