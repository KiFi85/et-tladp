classdef EyeTrackScreen
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        diagonalCm
        widthCm
        heightCm
        widthPixels
        heightPixels
        pixelsPerCm
        cmPerPixel
        aspectRatio
    end
    
    methods
        function obj = EyeTrackScreen(diagonal,resolution,aspectRatio)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            
            if nargin >= 1 && diagonal < 43
                warning('Monitor size needs to be at least 43.18cm (17")')
                clear obj
            elseif nargin >= 2 && length(resolution) ~= 2
                warning('Screen resolution needs to be in form [w h]')
                clear obj
            elseif nargin == 3 && length(aspectRatio) ~= 2
                warning('Aspect ratio needs to be in form [w h]')
                clear obj
            elseif nargin == 1
                obj.diagonalCm = diagonal;
            elseif nargin == 2
                obj.diagonalCm = diagonal;
                obj.widthPixels = resolution(1);
                obj.heightPixels = resolution(2);
            elseif nargin == 3
                obj.diagonalCm = diagonal;
                obj.widthPixels = resolution(1);
                obj.heightPixels = resolution(2);
                obj.aspectRatio = aspectRatio(2)/aspectRatio(1);
            end
            
            obj = obj.calculateDimensions;
            
        end
        
        function obj = calculateDimensions(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            % Get pixel diagonal
            pixelsDiagonal = hypot(obj.widthPixels,obj.heightPixels);
            % Calculate pixels per cm from known diagonals
            obj.pixelsPerCm = pixelsDiagonal/obj.diagonalCm;
            obj.cmPerPixel = obj.diagonalCm/pixelsDiagonal;
            
            % Calculate screen width
            obj.widthCm = obj.cmPerPixel*obj.widthPixels;
            obj.heightCm = obj.cmPerPixel*obj.heightPixels;
            
        end

    end
end

