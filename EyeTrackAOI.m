classdef EyeTrackAOI
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        aoiName
        position % [xmin, ymin, width, height] (pixels)
        positionNormalised % (0,1)
        vertices
        verticesNormalised
        rotationAngle
        displayPosition % Within the screen (pixels)
        displayPositionNormalised % Within the screen (0,1)
        shape
        ImageContainer
    end
    
    methods
        
        function [obj,success] = EyeTrackAOI(name,pos,shape)

            if nargin == 1 && (ischar(name) == 1 || isstring(name) == 1) 
                obj.aoiName = name;
            elseif nargin == 2
                if (ischar(name) == 1 || isstring(name) == 1)
                    obj.aoiName = name;
                else
                    warning('Please enter a name as a string')
                    success = 0;
                end
                if length(pos) == 4
                    obj.position = pos;
                    calcNormalise(obj);
                else
                    warning('Position has to be of length 4');
                    success = 0;
                end
            elseif nargin == 3 
                if (ischar(name) == 1 || isstring(name) == 1)
                    obj.aoiName = name;
                else
                    warning('Please enter a name as a string')
                    success = 0;
                end
                if length(pos) == 4
                    obj.position = pos;
%                     calcNormalise(obj);
                else
                    warning('pixel position has to be of length 4')
                    success = 0;
                end
                if find(strcmpi(shape,{'rectangle','ellipse','freehand'}))
                    obj.shape = shape;
                else
                    warning('Please enter a shape name')
                    success = 0;
                end
                
            end
            
            if ~exist('success','var')
                success = 1;
            end
                
            
        end
        
        function obj = calculateDisplayPosition(obj,ImageObj)
            % Get details of image size and position in screen
            obj.ImageContainer=ImageObj;
            
            if strcmpi(obj.shape,'rectangle')
                obj = obj.calcRectDisplayPosition;
            elseif strcmpi(obj.shape,'ellipse')
                obj = obj.calcEllipseDisplayPosition;                
            elseif strcmpi(obj.shape,'freehand')
                obj = obj.calcFreehandDisplayPosition;
            end
            

        end
        
        function obj = calcRectDisplayPosition(obj)

            % Get Image container
            ImageObj = obj.ImageContainer;
            
            % First normalise the coordinates within the original image
            % position[1,3] = [x,width] / image width
            % position[2,4] = [y,height] / image height
            w = ImageObj.width;
            h = ImageObj.height;
            
            obj.positionNormalised = obj.position ./ [w h w h];
            
            % Get display position (pixels) as on screen
            % Display coordinates of stretched image: 
            % width,height,distance from left of screen
            dispW = ImageObj.displayWidth;
            dispH = ImageObj.displayHeight;
            dispX = ImageObj.xFromLeft;
            dispY = ImageObj.yFromTop;
            
            % New AOI positions in pixels for stretched image 
            % x = ratio of stretched image width to original image width *
            % AOI x position + pixel distance from left of screen to edge
            % of stretched image
            aoiX = obj.position(1);
            newX = ((dispW/w)*aoiX)+dispX;
            
            % New y position calculated in same way
            aoiY = obj.position(2);
            newY = ((dispH/h)*aoiY)+dispY;
            
            % Display width and height from ratio of original image to
            % stretched image
            aoiW = obj.position(3);
            newW = dispW / w * aoiW;
            
            aoiH = obj.position(4);
            newH = dispH / h * aoiH;
            
            % Save to property
            obj.displayPosition = [newX newY newW newH];
            
            % Normalise new display position relative to screen pixels
            % Screen width and screen height
            sW = ImageObj.screenWidthPixels;
            sH = ImageObj.screenHeightPixels;
            
            obj.displayPositionNormalised =...
                obj.displayPosition ./ [sW sH sW sH];            
        end
        
        function obj = calcEllipseDisplayPosition(obj)
            
            % Get Image container
            ImageObj = obj.ImageContainer;
            
            % First normalise the coordinates within the original image
            % position[1,3] = [x,width] / image width
            % position[2,4] = [y,height] / image height
            w = ImageObj.width;
            h = ImageObj.height;
            
            obj.positionNormalised = obj.position ./ [w h w h];
            
            % Get display position (pixels) as on screen
            % Display coordinates of stretched image: 
            % width,height,distance from left of screen
            dispW = ImageObj.displayWidth;
            dispH = ImageObj.displayHeight;
            dispX = ImageObj.xFromLeft;
            dispY = ImageObj.yFromTop;
            
            % New AOI positions in pixels for stretched image 
            % xCenter = ratio of stretched image width to original image width *
            % AOI x position + pixel distance from left of screen to edge
            % of stretched image
            aoiXCenter = obj.position(1);
            newXCenter = ((dispW/w)*aoiXCenter)+dispX;
            
            % New y center position calculated in same way
            aoiYCenter = obj.position(2);
            newYCenter = ((dispH/h)*aoiYCenter)+dispY;
            
            % Display semi axes width and height from ratio of original image to
            % stretched image
            aoiSemiX = obj.position(3);
            newSemiX = dispW / w * aoiSemiX;
            
            aoiSEmiY = obj.position(4);
            newSemiY = dispH / h * aoiSEmiY;
            
            % Save to property
            obj.displayPosition = [newXCenter newYCenter newSemiX newSemiY];
            
            % Normalise new display position relative to screen pixels
            % Screen width and screen height
            sW = ImageObj.screenWidthPixels;
            sH = ImageObj.screenHeightPixels;
            
            obj.displayPositionNormalised =...
                obj.displayPosition ./ [sW sH sW sH];             
            
        end
        
        function obj = calcFreehandDisplayPosition(obj)
            
            % Get Image container
            ImageObj = obj.ImageContainer;
            
            % First normalise the coordinates within the original image
            % position[1] = [x] / image width
            % position[2] = [y] / image height
            w = ImageObj.width;
            h = ImageObj.height;
            
            obj.positionNormalised = obj.position ./ [w h];
            
            % Get display position (pixels) as on screen
            % Display coordinates of stretched image: 
            % width,height,distance from left of screen
            dispW = ImageObj.displayWidth;
            dispH = ImageObj.displayHeight;
            dispX = ImageObj.xFromLeft;
            dispY = ImageObj.yFromTop;
%             
%             % New AOI positions in pixels for stretched image 
%             % x = ratio of stretched image width to original image width *
%             % AOI x position + pixel distance from left of screen to edge
%             % of stretched image
            aoiX = obj.position(:,1);
            newX = ((dispW/w)*aoiX)+dispX;
%             
%             % New y position calculated in same way
            aoiY = obj.position(:,2);
            newY = ((dispH/h)*aoiY)+dispY;
             
            % Save to property
            obj.displayPosition = [newX newY];
            
            % Normalise new display position relative to screen pixels
            % Screen width and screen height
            sW = ImageObj.screenWidthPixels;
            sH = ImageObj.screenHeightPixels;
             
            obj.displayPositionNormalised =...
                obj.displayPosition ./ [sW sH];            
            
        end
        
    end
end

