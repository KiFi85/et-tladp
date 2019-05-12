classdef EyeTrackImage
    
    properties
        % all measurements in pixels or normalised (0,1)
        imageName
        imageID
        width 
        height
        aspectRatio % as H/W
        displayWidth
        displayWidthNormalised
        displayHeight
        displayHeightNormalised
        xFromLeft % x1
        xFromLeftNormalised
        yFromTop % y1
        yFromTopNormalised
        screenWidthPixels
        screenHeightPixels
        Aois=EyeTrackAOI
                    
    end
    
    properties (SetAccess=private, GetAccess=public)
        path
        fileName
        extension
    end
    
    properties (Dependent, SetAccess=private)
        Count
    end    
    
    methods
        
        function obj = EyeTrackImage(id)
            
            if nargin == 1
                obj.imageID = id;
            end            
        end
        
        function cnt=get.Count(obj)
            
            cnt=length(obj.Aois);
            
            % if the count is 1 but empty name in item 1 
            % initialised --> set count to 0
            if cnt==1 && isempty(obj.Aois(1).aoiName)
                cnt=0;
            end
            
        end       
        
        function obj = loadImageDetails(obj,fullname,id)
            
                try
                    % get image info, and assign metadata to fields
                    
                    [filePath, name, fileExtension]=fileparts(fullname);
                    imageFileName = strcat(name,fileExtension);
                    
                    % image metadata
                    imginfo = imfinfo(fullname);

                    obj.width = imginfo.Width;
                    obj.height = imginfo.Height;                    
                    obj.aspectRatio=obj.width/obj.height;
                    
                    obj.path = filePath;
                    obj.extension = fileExtension;
                    obj.fileName = fullname;
                    
                    obj.imageName = imageFileName;
                    % if a name was supplied, name the image (otherwise it
                    % gets the filename)
                    if nargin==3 && isempty(obj.imageID)
                        obj.imageID=id;
                    elseif isempty(obj.imageID)
                        obj.imageID = name;
                    end
                    
                catch ERR
                    % report error if the file couldn't be loaded
                    disp(strcat(ERR.message,{' -- '} ,imageFileName,' is possibly not an image.'))
                    return
                end
        end
        
        function obj = addAOIObject(obj,AoiObj)

            if nargin == 2 && strcmpi(class(AoiObj),'EyeTrackAOI')
                nextCol=obj.Count+1;
                AoiObj = AoiObj.calculateDisplayPosition(obj);
                obj.Aois(nextCol) = AoiObj;                
            elseif nargin == 2
                warning('Object must be of type EyeTrackTask');
            end            
     
        end        
        
        function obj = addAOIDetails(obj,name,pos,shape)
            
            if nargin < 4 
                warning('Please input AOI name, position and shape');
            else
                nextAOI = obj.Count+1;
                [Aoi,added] = EyeTrackAOI(name,pos,shape);
                Aoi = Aoi.calculateDisplayPosition(obj);
                
                obj.Aois(nextAOI) = Aoi;
                
                if added == 0 && nextAOI > 1
                    obj.Aois(nextAOI) = [];
                elseif added == 0
                    obj.Aois(nextAOI) = EyeTrackAOI;
                end
            end
            
        end
        
        function obj = calculateDisplaySize(obj,screen)
           
            if nargin < 2 || ~strcmpi(class(screen),'EyeTrackScreen')
                warning('Please include a valid EyeTrackScreen object')
            end
            
            obj.screenHeightPixels = screen.heightPixels; 
            obj.screenWidthPixels = screen.widthPixels;
            
            % Determine whether image is stretched to fit width or height
            % If aspect ratio of image is bigger than screen - fit to
            % height
            if obj.aspectRatio > screen.aspectRatio
                
                % Image height is just height of screen
                obj.displayHeight = screen.heightPixels;
                obj.displayHeightNormalised = 1;
                
                % Get ratio of new height to old height
                fitRatio = obj.displayHeight / obj.height;
                % New width
                obj.displayWidth = obj.width * fitRatio;
                obj.displayWidthNormalised = ...
                    obj.displayWidth / screen.widthPixels;
                
                % If stretched to height - calculate the edge of the image
                % from left of screen
                screenCentre = screen.widthPixels * 0.5;
                imageCentre = obj.displayWidth * 0.5;
                
                % x from left of screen
                obj.xFromLeft = screenCentre - imageCentre;
                obj.xFromLeftNormalised = ... 
                    obj.xFromLeft / screen.widthPixels;
                
                % y from bottom of screen
                obj.yFromTop = 0;
                obj.yFromTopNormalised = 0;
                
            else
                
                % Image width is just width of screen
                obj.displayWidth = screen.widthPixels;
                obj.displayWidthNormalised = 1;
                
                % Get ratio of new width to old width
                fitRatio = obj.displayWidth / obj.width;
                % New height
                obj.displayHeight = obj.height * fitRatio;
                obj.displayHeightNormalised = ...
                    obj.displayHeight / screen.heightPixels;
                
                % If stretched to width - calculate the edge of the image
                % from bottom of screen
                screenCentre = screen.heightPixels * 0.5;
                imageCentre = obj.displayHeight * 0.5;
                
                % y from bottom of screen
                obj.yFromTop = screenCentre - imageCentre;
                obj.yFromTopNormalised = ... 
                    obj.yFromTop / screen.heightPixels;
                
                % x from left of screen
                obj.xFromLeft = 0;
                obj.xFromLeft = 0;

            end
                
            % Calculate 
            
            
            
            
        end
        
        
    end
        
end

