classdef EyeTrackSpatialFilter < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        x % 2D Gaze vector
        y % 2D Gaze vector
        fixationTimes
        fixationRows
        fixationIdx
        fixationStruct
        totalFixationDuration % Per subject across all AOIs
        timeToFirstFixate
        aoiList % Table headers for output (including not on AOI)
        aoiInOut % Boolean array whether in or out of AOI
        Image=EyeTrackImage
        Aoi=EyeTrackAOI
        FixationFilter=EyeTrackFixationFilter        
    end
    
    methods
        
        function getXY(obj)
            
            dataParsed = obj.FixationFilter.parseOn;
            
            % If parsed into fixations
            if dataParsed

                % Get durations and fixation events index
                timeMs = obj.FixationFilter.msFromOnset;
                [~,times,rows,idx] = getEventDurations(obj.fixationStruct,timeMs); 

                obj.fixationIdx = idx;
                obj.fixationRows = rows;
                obj.fixationTimes = times;

                % Get averaged 2D gaze point vectors
                % Subset by fixation rows
                averageX = obj.FixationFilter.gaze2dXAverage(rows);
                averageY = obj.FixationFilter.gaze2dYAverage(rows);

                % Get average by fixation
                averageX = grpstats(averageX,idx);
                averageY = grpstats(averageY,idx);                

                % Convert to pixel coordinates
                obj.x = averageX*obj.Image.screenWidthPixels;
                obj.y = averageY*obj.Image.screenHeightPixels;
                
            else
                
                % else data not parsed - average X/Y from fixation filter 
                averageX = obj.FixationFilter.gaze2dXAverage;
                averageY = obj.FixationFilter.gaze2dYAverage;
                
                % Convert to pixel coordinates
                obj.x = averageX*obj.Image.screenWidthPixels;
                obj.y = averageY*obj.Image.screenHeightPixels;
            end
            
            
        end
        
        function getFixations(obj)

            % Classifications and ms time from filter
            classifications = obj.FixationFilter.gazeEventType;
            timeMs = obj.FixationFilter.msFromOnset;

            % Get a list of details for each fixation in 
            EventStruct = getEventBlocks('F',0,classifications,timeMs);
            
            obj.fixationStruct = EventStruct;

        end
        
        function [lookTimes,noHits] = calculateLookingTimes(obj,byImage)
%         function [aoiCats,aoiIdx,lookTimes] = calculateLookingTimes(obj,byImage)
           
            % Get 2D X,Y gaze coordinates
            obj.getXY;
            
            % Get AOI hits for all AOIs in image or selected AOI only
            if byImage
                obj.getAoiHitsByImage;
            else
                obj.getAoiHits;
            end
            
            % Number of AOIs + 1 for not on AOI
            [nRows,nAois] = size(obj.aoiInOut);
            nAois = nAois + 1;

            % Not on AOI (where all AOIs are 0)
            notAoi = find(all(obj.aoiInOut == 0,2));
            % NaN rows
            nanRows = find(all(isnan(obj.aoiInOut(:,1:end)),2));
            % Add new empty column to aoiInOut array
            aoiArray = [obj.aoiInOut,zeros(nRows,1)];
            % NotOnAoi = 1 by index
            aoiArray(notAoi,end) = 1;
            % Add NaN rows (invalid sample)
            aoiArray(nanRows,end) = NaN;

            % All first values = 0
            aoiArray(1,:) = 0;


            % Storage array for total looking times
            aoiTimes = zeros(1,nAois);

            for iAoi = 1:nAois

                % AOI Column
                aoiData = aoiArray(:,iAoi);

%                 % Index where in AOI
%                 inAoiIdx = find(aoiData==1);
%                 % Replace 1 with name of AOI
%                 aoiNo(inAoiIdx) = iAoi;

                % Get details of event start and end and number of events
                % Event is 'In AOI'
                AoiStruct = getEventBlocks('AOI',[],[],[],aoiData);
                
                % Number of blocks of sample hits in AOI
                nEvents = AoiStruct.nEvents;

                % Get event times (Looking Time)
                timeMs = obj.FixationFilter.msFromOnset;
                [durations,~,~,~] = getEventDurations(AoiStruct,timeMs);
                
                % Get total looking times
                if nEvents
                    aoiTimes(iAoi) = sum(durations);
                else
                    aoiTimes(iAoi) = NaN;
                end

            end

            % Get NaN rows
            invalidRowIdx = find(isnan(aoiTimes));
            
            % Convert to cell array, replace NaN with descriptor
            aoiTimes = num2cell(aoiTimes);
            
            if invalidRowIdx
                aoiTimes(:,invalidRowIdx) = {'No AOI hits'};
                noHits = invalidRowIdx;
            else
                noHits = 0;
            end
            
            % Output
            lookTimes = aoiTimes;            
            
        end
        
        function [tFD,noHits,noFixations] = calculateTfd(obj,byImage)
            
            dataParsed = obj.FixationFilter.parseOn;

            % If unparsed data - exit
            if ~dataParsed
                warning('Cannot calculate TFD if unparsed data');
                return
            end            
            
            % Get Fixation Details
            obj.getFixations;
            nFixations = obj.fixationStruct.nEvents;

            % If no fixations exit
            if ~nFixations
%                 warning('No fixations found');
                tFD = {'No fixations found'};
                noFixations = 1;
                noHits = 0;
                
                return
            end
            
            % Get XY coordinates in pixels
            obj.getXY;
            
            % Determine whether fixations are in/out of AOI
            if byImage
                obj.getAoiHitsByImage; 
            else
                obj.getAoiHits;
            end
            
            [fDIn,fDOut] = obj.getAoiFixationDurations;
            
            % If total fixation duration = 0, replace with NaN
            fDIn(fDIn==0)=NaN;
            fDOut(fDOut==0)=NaN;
            
            % Combine all inAoi and not-on-Aoi arrays
            totalFD = [fDIn,fDOut];
            
            % Get NaN rows
            invalidRowIdx = find(isnan(totalFD));
            
            % Convert to cell array, replace NaN with descriptor
            totalFD = num2cell(totalFD);
            
            if invalidRowIdx
                totalFD(:,invalidRowIdx) = {'No AOI hits'};
                noHits = invalidRowIdx;
                noFixations = 0;
            else
                noHits = 0;
                noFixations = 0;
            end
            
            % Output
            tFD=totalFD;             


%             obj.totalFixationDuration(1,cols) = totalFD;
        end
       
        function [fDIn,fDOut] = getAoiFixationDurations(obj)
            
            % Reference in/out against the fixation duration and sum
            % Out of AOI will be where all AOIs return a 0

            % First row of each fixation event
            [~,timeRows,~] = unique(obj.fixationIdx);
            % Fixation durations for each fixation event
            fixationDurations = obj.fixationTimes(timeRows);

            % Returns times for inAOI and 0 for outAOI
            aoiInTimes = fixationDurations.*obj.aoiInOut;
            % Get rows for which all AOIs are 'out' - not in any AOI - all 0 rows
            aoiOutRows = find(all(aoiInTimes == 0,2));
            % Return not in aoi times based on all zero rows
            if isempty(aoiOutRows)
                aoiOutTimes = 0;
            else
                aoiOutTimes = fixationDurations(aoiOutRows);
            end

            % Create output for total fixation durations
            if length(fixationDurations) > 1                
                fDIn = sum(aoiInTimes);
                fDOut = sum(aoiOutTimes);
            else
                fDIn = aoiInTimes;
                fDOut = aoiOutTimes;
            end
            
            
        end
        
        function [ttff,noHits,noFixations] = calculateTTFF(obj,onset,byImage)

            dataParsed = obj.FixationFilter.parseOn;
            
            if nargin <3
                warning('Please enter onset time and logical byImage');
                return
            end

            % If unparsed data - exit
            if ~dataParsed
                warning('Cannot calculate TTFF if unparsed data');
                return
            end            
            
            % Get Fixation Details
            obj.getFixations;
            nFixations = obj.fixationStruct.nEvents;
            
            if ~nFixations
%                 ttff = NaN;
                ttff = {'No fixations found'};
                noFixations = 1;
                noHits = 0;
                return;
            end
            
            % Get XY coordinates in pixels
            obj.getXY;
            
            % Get AOI hits for all AOIs in image or selected AOI only
            if byImage
                obj.getAoiHitsByImage;
            else
                obj.getAoiHits;
            end
            
            % Get index of first fixations for each AOI
            rowIdx = obj.getFirstFixations;
            
            % Get non-NaN and NaN rows
            % Either Aoi hits or no Aoi hits
            validRowIdx = find(~isnan(rowIdx));
            invalidRowIdx = find(isnan(rowIdx));
            
            % Find times corresponding to AOIs with fixations
            validTimes = obj.FixationFilter.remoteTime(...
                rowIdx(validRowIdx));
            
            % Replace index values with fixation times
            timeArray = rowIdx;
            timeArray(validRowIdx)=validTimes;
            
            % Calculate time to first fixate for valid measurements
            timeArray(validRowIdx) =...
                    (timeArray(validRowIdx)-double(onset))/1000;
                
            % Convert to cell array, replace NaN with descriptor
            timeArray = num2cell(timeArray);
            
            if invalidRowIdx
                timeArray(:,invalidRowIdx) = {'No AOI hits'};
                noHits = invalidRowIdx;
                noFixations = 0;
            else
                noHits = 0;
                noFixations = 0;
            end
            
            % Output
            ttff=timeArray; 

        end
        
        function out = getFirstFixations(obj)
            
            % Get start times of each fixation
            fixationStart = obj.fixationStruct.eventStartEnd(:,1)';

            % Get fixations that are located in AOI
            rowArray = [fixationStart'.*obj.aoiInOut]+1;
            rowArray(rowArray==1)=NaN;
            % Return first fixation for each AOI
            out = min(rowArray);

        end
        
        function getAoiHitsByImage(obj)

            
            % Number of aois per image
            nAois = obj.Image.Count;
            
            % Storage array
            dataParsed = obj.FixationFilter.parseOn;
            
            if dataParsed
                
                nFixations = obj.fixationStruct.nEvents;
                % Array by fixation
                obj.aoiInOut = zeros(nFixations,nAois);
                validRows = 1:nFixations;
                
            else
                % Array by all samples
                obj.aoiInOut = zeros(length(obj.x),nAois);
                
                % Input NaN
                nanRows = find(all(isnan([obj.x,obj.y]),2));
                validRows = find(all(~isnan([obj.x,obj.y]),2));
                obj.aoiInOut(nanRows,:) = NaN;               
                

            end

                for iAoi = 1:nAois

                    % New aoi object
                    obj.Aoi = obj.Image.Aois(iAoi);
                    % Position as displayed on screen
                    aoiPosition = obj.Aoi.displayPosition;
                    % Shape    
                    aoiShape = obj.Aoi.shape;
                    rotAngle = obj.Aoi.rotationAngle;

                    % Set MATLAB ROI object
                    if strcmpi(aoiShape,'rectangle')
                        h = images.roi.Rectangle('Position',aoiPosition);
                    elseif strcmpi(aoiShape,'ellipse')
                        h = images.roi.Ellipse(...
                            'Center',aoiPosition(1:2),...
                            'SemiAxes',aoiPosition(3:4),...
                            'RotationAngle',rotAngle);
                    elseif strcmpi(aoiShape,'freehand')
                        h = images.roi.Freehand('Position',aoiPosition);

                    end

                    % Get boolean vector of in/out for each fixation
                    if ~isempty(validRows)
                        obj.aoiInOut(validRows,iAoi) = inROI(...
                        h,...
                            obj.x(validRows),...
                            obj.y(validRows));
                    end
                end             
            
        end
        
        function getAoiHits(obj)

            % Storage array
            dataParsed = obj.FixationFilter.parseOn;

            if dataParsed
                
                nFixations = obj.fixationStruct.nEvents;
                % Array by fixation
                obj.aoiInOut = zeros(nFixations);
                
            else
                % Array by all samples
                obj.aoiInOut = zeros(length(obj.x));

            end
            
                % Position as displayed on screen
                aoiPosition = obj.Aoi.displayPosition;
                % Shape    
                aoiShape = obj.Aoi.shape;

                % Set MATLAB ROI object
                if strcmpi(aoiShape,'rectangle')
                    h = images.roi.Rectangle('Position',aoiPosition);
                end

                % Get boolean vector of in/out for each sample/fixation
                obj.aoiInOut = inROI(h, obj.x, obj.y);
            
        end
        
 
    end
end

