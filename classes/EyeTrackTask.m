classdef EyeTrackTask
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        taskName
        taskType % 'STATIC' 'TIMED' 'GAZE_CONTINGENT' or 'MOVING'
        Images=EyeTrackImage
        Display=EyeTrackScreen
    end
    
    properties (Dependent, SetAccess=private)
        Count
    end    
    
    methods

        function obj = EyeTrackTask(name,ttype,ImageObj)% optional EyeTrackImage
            if nargin >= 1
                nameIsString = (ischar(name) == 1 || isstring(name) == 1);
                
                if nargin ~= 0 && nameIsString
                    obj.taskName = name;
                else
                    warning('Please add name as string or character');
                    clear obj
                end            
            end
            
            if nargin >= 2
                typeIsValid = ["STATIC" "TIMED" "GAZE_CONTINGENT" "MOVING"];
            end
           
            % If task type added, make sure valid before adding
            if nargin >=2 && ismember(string(ttype),typeIsValid)
                obj.taskType = ttype;               
            elseif nargin >= 2
                warning("Task type must be STATIC, TIMED, GAZE_CONTINGENT or MOVING");
                clear obj
            end
            
            % Check valid images object
            if nargin == 3 && strcmpi(class(ImageObj),'EyeTrackImage')
                obj.addImageObject(ImageObj);
            elseif nargin == 3
                warning('Object must be of type EyeTrackImage');
                clear obj
            end
                
        end
        
        function obj = addImageObject(obj,ImageObj)

            if strcmpi(class(ImageObj),'EyeTrackImage')
                nextCol = obj.Count+1;
                ImageObj = ImageObj.calculateDisplaySize(obj.Display);
                obj.Images(nextCol) = ImageObj;
            else
                warning('Object must be of type EyeTrackImage');
                clear obj
            end
            
        end
        
        function obj = loadImageFromFolder(obj,path)
            % Allows user to select folder containing images
            % Add all images in folder to Images collection
            
            % Get next available space in collection
            nextCol=obj.Count+1;

            % Get list of files from folder directory
            f=dir(path);
            
            % loop through files
            for iImage=1:length(f)
                
                % Try and load image file
                try

                    % Check that it isn't a directory (i.e. a file)
                    if ~f(iImage).isdir

                        % if file --> full path and filename
                        filename = f(iImage).name;
                        fullname=fullfile(path,filename);
                            
                        % Get image info - if not an image will throw exception    
                        imginfo = imfinfo(fullname);
                        
                        % New EyeTrackImage
                        imageObj = EyeTrackImage;
                        imageObj = imageObj.loadImageDetails(fullname);
                        imageObj = imageObj.calculateDisplaySize(obj.Display);
                        % Load image details and add to collection
                        obj.Images(nextCol)=imageObj;

                        nextCol=nextCol+1;
                            
                    end

                catch ERR
                    % report error if the file couldn't be loaded
                    disp(strcat(ERR.message,{' -- '} ,f(iImage).name,' is possibly not an image.'))
                end

            end

        end        
        
%         function obj = set.Images(obj) % EyeTrackImage object
% %             nextCol=obj.Count+1;
% %             obj.Images(nextCol)=ImageObj;
%         end
        
        function cnt=get.Count(obj)
            
            cnt=length(obj.Images);
            
            % if the Count is 1 but empty name in item 1 
            % initialised --> set Count to 0
            if cnt==1 && isempty(obj.Images(1).imageName)
                cnt=0;
            end
            
        end   
        
        
    end
end

