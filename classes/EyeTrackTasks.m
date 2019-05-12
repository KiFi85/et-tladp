classdef EyeTrackTasks
    
    properties
        Items=EyeTrackTask
        
    end
    
    properties (Dependent, SetAccess=private)
        Count
    end
    
    methods
        
        function obj = EyeTrackTasks(TaskObj)
            %UNTITLED3 Construct an instance of this class
            %   Detailed explanation goes here
            
            if nargin == 1 && strcmpi(class(TaskObj),'EyeTrackTask')
                nextCol=obj.Count+1;
                obj.Items(nextCol) = TaskObj;
            elseif nargin == 1
                warning('Object must be of type EyeTrackTask');
                clear obj
            elseif nargin == 0
                
            end            

        end        
        
        function cnt=get.Count(obj)
            
            cnt=length(obj.Items);
            
            % if the Count is 1 but empty name in item 1 
            % initialised --> set Count to 0
            if cnt==1 && isempty(obj.Items(1).taskName)
                cnt=0;
            end
            
        end   
        
        function clear(obj)
            
            obj.Items = [];
            obj.Items=EyeTrackTask;
            obj.Count;
            
        end
        
        function obj = addTaskObject(obj,TaskObj)
            % Adds a new element to the collection, load an image, and
            % names it
            
            nextCol=obj.Count+1;
            
            if strcmpi(class(TaskObj),'EyeTrackTask')
                obj.Items(nextCol) = TaskObj;
            else
                warning('Object must be of type EyeTrackTask');
                clear obj
            end

        end
        
    end
    
end

