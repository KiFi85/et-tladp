classdef EyeTrackFixationFilter < handle
    
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Filter properties
        parseOn=1
        gapFill=1
        maxGapLength=75
        eyeSelection='Average'
        windowLength=20
        velocityThreshold=30
        merge=1
        maxMergeTime=75
        maxMergeAngle=0.5
        discard=1
        minFixationLength=60
        mergeBeforeDiscard=1;
        % Data
        gazeData
        msFromOnset
        remoteTime
        velocities
        gazeEventType
        gazeEventDuration
        gazeEventIndex
        gaze2dXAverage
        gaze2dYAverage
        
        % Gaze data variables
        gazeBufferVars = {...
            'Left3DUCSx','Left3DUCSy','Left3DUCSz',...
            'Left3DRELx','Left3DRELy','Left3DRELz',...
            'Leftx','Lefty',...
            'Left3Dx','Left3Dy','Left3Dz',...
            'LeftDiameter','LeftValidity',...
            'Right3DUCSx','Right3DUCSy','Right3DUCSz',...
            'Right3DRELx','Right3DRELy','Right3DRELz',...
            'Rightx','Righty',...
            'Right3Dx','Right3Dy','Right3Dz',...
            'RightDiameter','RightValidity'}

        eyeVars = {...
            'Left3DUCSx','Left3DUCSy','Left3DUCSz',...
            'Right3DUCSx','Right3DUCSy','Right3DUCSz'};
        leftEyeVars = {...
            'Left3DUCSx','Left3DUCSy','Left3DUCSz',...
            'Leftx','Lefty',...
            'Left3Dx','Left3Dy','Left3Dz'}
        rightEyeVars = {...
            'Right3DUCSx','Right3DUCSy','Right3DUCSz',...
            'Rightx','Righty',...
            'Right3Dx','Right3Dy','Right3Dz'}
        gazeVars = {'Left3Dx','Left3Dy','Left3Dz',...
                'Right3Dx','Right3Dy','Right3Dz'};
        gazeVars2DX = {'Leftx','Rightx'};
        gazeVars2DY = {'Lefty','Righty'};

        
        
    end
    
    methods
        
        function runFilter(obj,type)
            %RUNFILTER Run fixation filter methods sequentially
            %   Relevant methods will be run in sequence dependent on the 
            %   properties set by the user:
            %   Gap Fill-in -> Fixation classifier -> Merge adjacent
            %   saccades -> Discard short fixations
            
            % If unparsed, just get average of 2D gaze coordinates based on
            % eye selection
            if obj.parseOn == 0
                obj.subsetData;
                return
            end
            
            if obj.gapFill
                obj.fillValidGaps; % Fill gaps if required
                obj.classifyFixations; % Classify fixations
            end
            
            if obj.mergeBeforeDiscard                
                if obj.merge % merge adjacent fixations if selected
                    obj.mergeAdjacentFixations;
                end
                
                if obj.discard % discard short fixations if selected
                    obj.discardShortFixations;
                end
            else
                if obj.discard % discard short fixations if selected
                    obj.discardShortFixations;
                end                
                
                if obj.merge % merge adjacent fixations if selected
                    obj.mergeAdjacentFixations;
                end                
            end
                
            obj.getGazeEvents; % Get gaze event index and durations
            
        end
        
        function fillValidGaps(obj)
            %FILLGAPS Fill in gaps between data samples 
            %   Gaps in the data will be filled in by interpolating between
            %   valid measurements. Gaps will only be filled in if the time
            %   between valid samples is <= the maximum gap length
            %   (typically 75ms)

            % Decide which eyes to use (loop through 1,2 or 1 (left) and 2 (right)
            if strcmp(obj.eyeSelection,'Left') == 1
                eyeIndex = 1;
            elseif strcmp(obj.eyeSelection,'Right') == 1
                eyeIndex = 2;
            else
                eyeIndex = (1:2);
            end

            % Loop through eyes
            for iEye = eyeIndex

                if iEye == 1
                    % Get variable column numbers for left eye
                    vars = {'LeftValidity';obj.leftEyeVars};
                else
                    % Get variable column numbers for right eye
                    vars = {'RightValidity';obj.rightEyeVars};
                end
                
                % Subset gaze and validity code data by left/right eye
                varsIdx = getColumnNoByRef(vars,obj.gazeBufferVars);
                valCode = obj.gazeData(:,varsIdx{1}); % Validity
                gazeEyeData = obj.gazeData(:,varsIdx{2}); % Subset gaze data
                
                % Get details of order,runs and indices of events
                eventStruct = getEventBlocks(...
                    'Gap',valCode,[],...
                    obj.msFromOnset);                

                % Get valid gap rows
                gapsToFill = getValidGaps(eventStruct,valCode,...
                    obj.msFromOnset,obj.maxGapLength);
                
                % Interpolate gaps < max length
                [nGaps,~] = size(gapsToFill);
                
                if nGaps > 1
                    % Loop through gaps and fill in missing data
                    for iGap = 1:nGaps
                        % gap location
                        gapRows = [gapsToFill(iGap,1):gapsToFill(iGap,2)];
                        % gaze data rows including data row either side
                        inputRows = [gapsToFill(iGap,1)-1:gapsToFill(iGap,2)+1];
                        inputData = gazeEyeData(inputRows,:);
                        timeData = obj.msFromOnset(inputRows,:);

                        % Get interpolated values
                        filledData = fillGapBlocks(inputData,timeData);
                        % Fill data
                        gazeEyeData(gapRows,:) = filledData;
                        % New validity code
                        valCode(gapRows) = 0;

                    end % End loop gaps

                    % Update gazeData with filled data and new val codes
                    obj.gazeData(:,varsIdx{2}) = gazeEyeData;   
                    obj.gazeData(:,varsIdx{1}) = valCode;
                    
                end % End if gaps
                
            end % End loop eye
            
        end
        
        function classifyFixations(obj)
            %CLASSIFYFIXATIONS Classify samples as fixation or saccades
            %   A sample will be classified as a fixation if the angular
            %   velocity between current sample and previous sample is less
            %   than the threshold (typically <30deg/s) otherwise it will
            %   be classified as a saccade or unclassified if no valid
            %   point is detected
            
            [eyePosLR,gazeLR,valCodes] = obj.subsetData;
            
            % get number of rows in dataset
            [nRows,~] = size(obj.gazeData);
            % new data
            classifications=strings(nRows,1);
            velocity=zeros(nRows,1);
            
            % Initialise gaze point and fixations for first row
            classifications(1) = 'Unclassified';
            
            % Loop through rows            
            for iRow = 2:nRows

                % Check for eye validity based on eye selection property
                currRow = iRow;
                prevRow = iRow-1;
                
                validSample = checkValidSample(...
                    valCodes(prevRow:currRow,:),obj.eyeSelection);
                
                if validSample == 0 % if no valid sample - unclassified
                    classifications(iRow) = 'Unclassified';
                    
                % else if at least one eye has been picked up from two time points -
                % calculate velocity
                else
                    
                    [vec1,vec2] = getGazeVectors(...
                        gazeLR(prevRow:currRow,:),eyePosLR(prevRow:currRow,:),...
                        obj.eyeSelection,0);
                    
                    % Calculate angular velocity between two gaze vectors
                    timeDiffMs = obj.msFromOnset(currRow)-obj.msFromOnset(prevRow);
                    [~,velocity(currRow)] = calculateAngularVelocity(vec1,vec2,timeDiffMs);

                    % Assign fixation, saccade or unclassified based on
                    % velocity
                    if velocity(currRow) <= obj.velocityThreshold
                        classifications(currRow) = 'Fixation';
                    elseif velocity(currRow) > obj.velocityThreshold
                        classifications(currRow) = 'Saccade';
                    elseif velocity(currRow) <= 0
                        classifications(currRow) = 'Unclassified';
                    end

                end

            end % row loop end
            
            % Save classifications and velocities to object properties
            obj.gazeEventType = classifications;
            obj.velocities = velocity;
            
        end

        function mergeAdjacentFixations(obj)
            
            classifications = string(obj.gazeEventType);
            % Get details of order,runs and indices of events
            eventStruct = getEventBlocks(...
                'Merge',[],classifications,obj.msFromOnset);

            if eventStruct.nEvents
                % Get durations of gaps between fixations
                [durations,~,~,~] = getEventDurations(eventStruct,...
                    obj.msFromOnset);
                % Get rows where gap durations < max length 
                startEnd = eventStruct.eventStartEnd(...
                    durations<obj.maxMergeTime,:);
                % Get rows where gap includes last row
                nRows = length(classifications);
                startEnd = startEnd(find(startEnd(:,2)<nRows),:);

                % Get gaze and eye position columns
                vars = {obj.eyeVars;obj.gazeVars};
                varsIdx = getColumnNoByRef(vars,obj.gazeBufferVars);
                % Subset gazeBuffer
                eyePosLR = obj.gazeData(:,varsIdx{1}); 
                gazeLR = obj.gazeData(:,varsIdx{2});

                % Get vector angle between adjacent fixations
                rowsToMerge = returnRowsToMerge(gazeLR,eyePosLR,...
                    startEnd,obj.maxMergeAngle,'Average');

                classifications(rowsToMerge) = "Fixation";
                % Return new classification array
                obj.gazeEventType = classifications;
            end
        end
        
        function discardShortFixations(obj)
            
            classifications = obj.gazeEventType;
            minLength = obj.minFixationLength;
            
            % Get details of order,runs and indices of events
            eventStruct = getEventBlocks(...
                'Discard',[],classifications,obj.msFromOnset);

            if eventStruct.nEvents            
                % Get durations of fixations
                [durations,~,~,~] = getEventDurations(eventStruct,...
                    obj.msFromOnset);

                % Get rows where fixation duration < minimum Length            
                startEnd = eventStruct.eventStartEnd;
                nEvents = eventStruct.nEvents;

                startEndCell = mat2cell(startEnd,repelem(1,nEvents));
                eventRows = cellfun(@(x)x(1):x(2),startEndCell,'UniformOutput',false);

                rows = eventRows(find(durations<minLength));
                rowsToDiscard = [rows{:}];  

    %             rowsToDiscard = intersect(...
    %                 find(classifications=="Fixation"),find(durations<minLength));

                % Replace short fixations with unclassified eye movement
                classifications(rowsToDiscard) = "Unclassified";

                % Return new classifications
                obj.gazeEventType = classifications;
            end
        end
        
        function getGazeEvents(obj)
            
            classifications = obj.gazeEventType;
            timeMs = obj.msFromOnset;
            
            % Initialise data arrays
            nRows = length(classifications);
            [eventIdx,eventTimes] = deal(zeros(nRows,1)); 
            
            % get event index and durations for fixations and saccades
            for gaze = {'F','S'}
                EventStruct = getEventBlocks(gaze,[],classifications,timeMs);

                if EventStruct.nEvents > 0

                    % Get durations and fixation events index
                    [~,times,rows,idx] = getEventDurations(EventStruct,timeMs);
                    % Index fixation events
                    eventIdx(rows) = idx;
                    eventTimes(rows) = times;

                    % Assign properties
                    eventTimes(eventTimes==0) = NaN;
                    obj.gazeEventDuration = eventTimes;
                    eventIdx(eventIdx==0) = NaN;
                    obj.gazeEventIndex = eventIdx;
                    
                end
                
            end           
        end
        
        function [eyeData,gazeData,valData] = subsetData(obj)

            % LR 3D Eye Pos; LR 3D Gaze Pts; 2D GazeX; 2D GazeY; Validity 
            vars = {obj.eyeVars;obj.gazeVars;...
                obj.gazeVars2DX;obj.gazeVars2DY;'LeftValidity';'RightValidity'};
            varsIdx = getColumnNoByRef(vars,obj.gazeBufferVars);
            % Subset gazeBuffer
            eyeData = obj.gazeData(:,varsIdx{1}); 
            gazeData = obj.gazeData(:,varsIdx{2});
            x = obj.gazeData(:,varsIdx{3});
            y = obj.gazeData(:,varsIdx{4});
            valData = [obj.gazeData(:,varsIdx{5}),obj.gazeData(:,varsIdx{6})];
            
            % Get averaged 2D gaze points
            [Average2dX,Average2dY] = averageGazePoints(x,y,obj.eyeSelection);
            obj.gaze2dXAverage = Average2dX;
            obj.gaze2dYAverage = Average2dY;
            
        end
            
    end
end

