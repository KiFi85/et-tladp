classdef EyeTrackData < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        subjectID
        subjectDirectory
        studyDirectory
        gazeDirectory
        gazeBuffer
        eventBuffer
        timeBuffer
        stimulusOnsetTime
        stimulusOffsetTime
        eventOnsetTime
        eventOffsetTime
        windowStart
        windowEnd
        taskData % Subsetted from gaze buffer by onset/offset times
        tFDData % Total fixation duration
        tTFFData % Time to First Fixate
        tFCData % Total Fixation Count
        tLTData % Total Looking Time
        runTTFF=1
        runTFD=1
        runTLT=0
        runTFC=0
        tfdHeaders
        ttffHeaders
        tfcHeaders
        tLTHeaders
        remoteTime
        msFromOnset
        saveData=false
        gapInfo
        gapTrialTypes={'BASELINE','GAP','OVERLAP'}
        dataLog % Cell array log details of n trials
        dataLogHeaders
        errorLog
        errorLogHeaders
        TaskObj=EyeTrackTask
        FixFilter=EyeTrackFixationFilter
        SpatialFilter=EyeTrackSpatialFilter
    end
    
    methods
        function obj = EyeTrackData(task,fixfilter,spatial)
            % Construct an instance of this class
            %   Construct the object, initialising with subject's ID
            if nargin == 3
                obj.TaskObj = task;
                obj.FixFilter = fixfilter;
                obj.SpatialFilter = spatial;
            else
                warning('Please enter a Task, Fixation Filter and Spatial Filter object');
                return                
            end
            
            % Create log files
            obj.dataLog = cell(1,4);            
            obj.dataLogHeaders = {...
                'subject','type','valid_trials','invalid_trials'};

            obj.errorLog = cell(1,4);
            obj.errorLogHeaders = {...
                'subject','type','trial_number','comment'};            
            
        end
        
        function loadData(obj)
            %loadData load Gaze/Event/Time/Gap/Moving data
            %   Load the buffer or data files from the subject/gaze directory 
            
            taskType = obj.TaskObj.taskType;
            % Get gaze directories
            gazePath = getGazeDirectory(obj.subjectDirectory); 
            obj.gazeDirectory = gazePath;
            
            if strcmpi(taskType,"STATIC") % If static - load buffers
                
                % Create data log headers
                obj.dataLogHeaders = {...
                'subject','task','images_found','images_not_found'};
                
                % Error log headers
                obj.errorLogHeaders = {...
                'subject','task','ID','comment'};            
                
                % Load buffer files
                obj.loadBuffers;
                
                
            elseif strcmpi(taskType,"GAZE_CONTINGENT")
                
                % Create data log headers
                obj.dataLogHeaders = {...
                'subject','type','valid_trials','invalid_trials'};
                
                % Error log headers
                obj.errorLogHeaders = {...
                'subject','type','trial_number','comment'};            
                
                % Load buffer files
                obj.loadBuffers;
                % Load gap_trial CSVs
                obj.loadGapTrial;
                
            end
        end
        
        function loadBuffers(obj)

            % Get paths to buffers as cell array {main,time,event} for
            % each gaze folder in subject folder
            bufferPaths = cellfun(@(x) getBufferPaths(x),... 
                obj.gazeDirectory,'UniformOutput',false);

            % Load all buffer files
            % Where multiple buffer files exist they are concatenated
            [mainB,timeB,eventB] = loadBufferFiles(bufferPaths);

            obj.gazeBuffer = mainB;
            obj.timeBuffer = timeB;
            obj.eventBuffer = eventB;                
            
        end
        
        function loadGapTrial(obj)
            
            % Get directory where output task files are stored
            csvDir = cellfun(@(x) fileparts(x), obj.gazeDirectory,'UniformOutput',false);
            
            % If multiple runs - combine the gap_trial2 CSVs
            nRuns = length(csvDir);
            
            % Check that gap_trial2.csv exists - if not recover
            if exist(fullfile(strcat(csvDir{nRuns},'\gap_trial2.csv')))
                csvDir = strcat(csvDir,'\gap_trial2.csv');
            else
%                 recoverData(fullfile(csvDir{nRuns}));
%                 csvDir = strcat(csvDir,'\gap_trial2.csv');
                
                obj.addErrorToLog(...
                    {obj.subjectID,...
                    'N/A',...
                    'N/A',...
                    'no output data found'});

            end
            
            % Assign gapinfo as gap_trial2.csv
            obj.gapInfo = importGapTrial(csvDir{nRuns},2,100);
            
        end
        
        function processData(obj)
            %processData - Process ET data based on particular task
            %   Determine which task has been selected and whether a fixation
            %   filter has been applied or not
            
            taskType = obj.TaskObj.taskType;
            
            if strcmpi(taskType,"STATIC")                
                obj.processStaticImages;
            elseif strcmpi(taskType,"GAZE_CONTINGENT")                
                obj.processGazeContingent;
            end
            
        end
        
        function processStaticImages(obj)
            % PROCESSSTATICIMAGES - Process static image tasks
            %   Function to process tasks that contain static images.
            %   Images will be looped through, and event times collected
            %   gazeBuffer is subsetted based on event times and filtered
            %   if required before determining AOI times and outputting
            
            % Get list of images found and rows within gaze buffer file
            [imageDetails,imagesFound] = obj.getImageRows(obj.TaskObj);
            
                % Loop through images and get event times
                for jImage = imagesFound
%                 for jImage = 9

                    imageIdx = imageDetails{jImage,1};
                    img = obj.TaskObj.Images(imageIdx);% Set EyeTrackImage object
                    
                    % Subset data based on onset/offset times
                    rows = {imageDetails{jImage,3},imageDetails{jImage,4}};
                    obj.subsetData(rows);
                    
                    % Filter static image data
                    obj.runFixationFilter;
                    
                    % Write filtered data to file
                    if obj.saveData
                        obj.writeFilteredData(img); 
                    end
                    
                    % Assign image to spatial filter
                    obj.SpatialFilter.Image = img;
                    
                    % Run spatial filter
                    obj.runStaticSpatialFilter(img);
                    
                end % Loop images end
            
        end 
        
        function processGazeContingent(obj)

            % Check gap validity and remove invalid rows
            validTrials = obj.checkTrialValidity;
            
            % Get list of condition numbers and trial index
            [conditions,trialIdx] = obj.getTrialconditions;
            
            % List of Left/Right ps 
            trialSide = obj.gapInfo.Side;

            if ~isempty(conditions)
                
                for iTrial = 1:length(conditions)
%                 for iTrial = 3

                    condition = conditions(iTrial);
                    trialNo = trialIdx(iTrial);

                    % Check if valid trial
                    if ismember(iTrial,validTrials)
                    
                        % Get onset/offset rows for trial
                        psOnset = obj.gapInfo.PeriOnsetTimeRemote(iTrial);
                        trialOffset = obj.gapInfo.TrialOffsetRemoteTime(iTrial);

                        % Subset data
                        loaded = obj.subsetData([],psOnset,trialOffset);
                        
                        % If rows have been found between onset/offset
                        if loaded

                            % Run fixation filter on subsetted data
                            obj.runFixationFilter;                    

                            % Get aoi Left/Right
                            psSide = trialSide(iTrial);
                            Image = obj.TaskObj.Images(1);
                            psAoi = Image.Aois(psSide);
                            
                            % Assign image and AOI
                            obj.SpatialFilter.Image = Image;
                            obj.SpatialFilter.Aoi = psAoi;
                            
                            % Apply spatial filter
                            obj.runGazeSpatialFilter(...
                                condition,trialNo,psSide);
                            
                        else
                            % If no data found between event times
                            obj.addErrorToLog({...
                                obj.subjectID,...
                                obj.gapTrialTypes{condition},...
                                trialIdx,...
                                'no data found between onset and offset times'});
                            
                        end
                        
                    end
                end
                
            end
            
        end 
        
        function processUnparsedData(obj)
           
            obj.SpatialFilter.calculateLookingTimes(1);
            
            
        end
        
        function validrows = checkTrialValidity(obj)
            
            % trial type
            conditions = obj.gapInfo.Condition;
            
            % loop through trials, get total and total excluded
            trials = obj.gapTrialTypes;
            nTrialsCell = {[],[],[]};

            for trial = 1:length(trials)

                % Subset by trial
                trialName = trials{trial};
                trialData = obj.gapInfo(...
                    strcmp(string(conditions),trialName),...
                    {'ValidGazeOnCS'});

                % Number of trials 
                nTrials = height(trialData);

                % Create empty array to store trials
                nTrialsCell{trial} = cell(1,nTrials);

                % Invalid trials to store as NaN
                invalidTrials = find(trialData.ValidGazeOnCS==0);
                nInvalidTrials = length(invalidTrials);
                nValidTrials = nTrials - nInvalidTrials;

                % NaN invalid trials in cell
                % - 99 will be replaced with 'IV'
                nTrialsCell{trial}(invalidTrials) = {'Invalid Trial'};

                % Create data log message
                msg = {...
                    obj.subjectID,...
                    trialName,...
                    nValidTrials,...
                    nInvalidTrials};
                
                % Update data log
                obj.addDataToLog(msg);
                
                % Create error message
                msg = repmat({...
                    obj.subjectID,...
                    trialName,'','invalid trial'},nInvalidTrials,1);
                msg(:,3) = num2cell(invalidTrials);

                % Update error log
                obj.addErrorToLog(msg);
                
            end
            
            % Return valid rows
            validrows = find(obj.gapInfo.ValidGazeOnCS==1);
%             obj.gapInfo(invalid,:) = [];
            
            % Assign empty ttff storage array 
            if obj.runTTFF
                obj.tTFFData = nTrialsCell;
            end
            
            if obj.runTFD || obj.runTLT
               
               % If running TFD, each will contain in/out AOI so repeat
               % elements
               baseline = repelem(nTrialsCell{1},2);
               gap = repelem(nTrialsCell{2},2);
               overlap = repelem(nTrialsCell{3},2);
               
               if obj.runTFD
                   obj.tFDData = {baseline,gap,overlap};
               elseif obj.runTLT
                   obj.tLTData = {baseline,gap,overlap};
               end
               
            end
        end
        
        function success = subsetData(obj,rowInfo,onsetTime,offsetTime)
        %SUBSETDATA subset gaze buffer by event onset/offset
            % rowInfo should be {onset,offset}
            
            if nargin < 3
                % Get rows corresponding to event
                onset = rowInfo{1};
                offset = rowInfo{2};

                % Get times from event rows
                onsetTime = cell2mat(obj.eventBuffer(onset,2));
                offsetTime = cell2mat(obj.eventBuffer(offset,2));

            end
            
            % Onset time as peripheral onset 
            obj.eventOnsetTime = onsetTime;
            obj.eventOffsetTime = offsetTime;

            % Subset gap trial data based on times
            rows = find(obj.timeBuffer>=onsetTime...
            & obj.timeBuffer<=offsetTime);

            obj.taskData = obj.gazeBuffer(rows,:);  
            obj.remoteTime = double(obj.timeBuffer(rows));
            obj.msFromOnset = (obj.remoteTime...
                - double(obj.eventOnsetTime))/1000; % time in ms  
            
            if rows
                success = 1;
            else
                success = 0;
            end
        end
        
        function [trialType,idx] = getTrialconditions(obj)
            
            % Get trial conditions baseline/gap/overlap
            conditions = obj.gapInfo.Condition;
            
            % Convert trial condition to number
            trialType = double(conditions);
            % Create empty array to store index values
            trialIdx = zeros(length(trialType),1);
            
            % Index by condition
            for iTrial = 1:3
                
                % Find instances of condition
                idx = find(trialType==iTrial);
                % Create index values
                trialNumber = [1:length(idx)]';
                % Add index values to array
                trialIdx(idx) = trialNumber;

            end
            
            idx = trialIdx;

        end
        
        function runFixationFilter(obj)

            % Filter gaze data
            obj.FixFilter.gazeData = obj.taskData;
            obj.FixFilter.msFromOnset = obj.msFromOnset;
            obj.FixFilter.remoteTime = obj.remoteTime;
            obj.FixFilter.runFilter;
            obj.taskData = obj.FixFilter.gazeData;
            
        end
        
        function [details,found] = getImageRows(obj,Task)
            % getImageRows - Find relevant rows of gaze data for static image
            %   Function will search for onset and offset times for static
            %   image and return rows to subset gazeBuffer 
            
            % Number of static images in task
            nImages = obj.TaskObj.Count;
            
            % Create empty cell array for image name and rows
            imageDetails = cell(nImages,4);            
            
            for iImage = 1:nImages
                
                imageName = Task.Images(iImage).imageName;

                lookupWhat = imageName; % Image name to search
                lookupWhere = obj.eventBuffer(:,3); % EventData column

                % Get image onset/offset times
                rowOnsetOffset = find(cellfun(@(c) any(strcmpi(c, lookupWhat)), lookupWhere));
                
                if ~isempty(rowOnsetOffset)
                    
                    rowOn = rowOnsetOffset(1);
                    rowOff = rowOnsetOffset(2);
                    
                    % Input data
                    imageDetails(iImage,:) = {iImage,imageName,rowOn,rowOff};
                end
            
            end
            
            details = imageDetails;
            % Get rows of images found for task
            found = find(~all(cellfun('isempty',imageDetails),2))';
            
            % Get rows of images not found for task
            imagesMissing = find(all(cellfun('isempty',imageDetails),2))';
            % Get names of missing images
            imageNamesMissing = {obj.TaskObj.Images(imagesMissing).imageID};
            
            % Input image data as missing (image not found)
            % TFD Data if running
            if obj.runTFD
                missingAOICols = find(contains(obj.tfdHeaders,imageNamesMissing));
                obj.tFDData(missingAOICols) = {'No image data'};
            end
            
            % Input AOI data as missing            
            % TTFF Data if running
            if obj.runTTFF
                missingAOICols = find(contains(obj.ttffHeaders,imageNamesMissing));
                obj.tTFFData(missingAOICols) = {'No image data'};
            end
            
            % Input AOI data as missing            
            % TLT Data if running
            if obj.runTLT
                missingAOICols = find(contains(obj.tLTHeaders,imageNamesMissing));
                obj.tLTData(missingAOICols) = {'No image data'};
            end
            
            % Write missing image names to error log
            msg = repmat({...
                obj.subjectID,...
                 obj.TaskObj.taskName,...
                 '',...
                 'no image data found'},...
                 length(imageNamesMissing),1);
            msg(:,3) = imageNamesMissing;
            obj.addErrorToLog(msg);
            
            % Write number of images found/not found to data log
            obj.addDataToLog({...
                obj.subjectID,...
                obj.TaskObj.taskName,...
                length(found),...
                length(imagesMissing)});
            
            

        end
        
        function gapOut = getGapRows(obj)
                
                lookupWhat = {'GAP_TRIAL_ONSET','GAP_TRIAL_OFFSET','GAP_PS_ONSET'}; % Event name to search
                lookupWhere = obj.eventBuffer(:,3); % EventData column

                % Get trial onset/offset rows
                trialOnRows = find(cellfun(@(c) any(strcmpi(c, lookupWhat{1})), lookupWhere));
                trialOffRows = find(cellfun(@(c) any(strcmpi(c, lookupWhat{2})), lookupWhere));
                psOnRows = find(cellfun(@(c) any(strcmpi(c, lookupWhat{3})), lookupWhere));
                
                gapOut = {trialOnRows,trialOffRows,psOnRows};                
                                
                
        end
        
        function runGazeSpatialFilter(obj,trialIdx,trialNo,side)
            
            % Aoi names for Image
            Image = obj.SpatialFilter.Image;
            aoiNames = [Image.Aois.aoiName,'NotOnAoi'];
            % Image name
            imageName = Image.imageID;
            
            %% Total Looking Time for unparsed data
            if ~obj.FixFilter.parseOn                
                obj.calcTotalLookingTime(trialIdx,side,[],0);
                return
            end
            
            %% Run TTFF
            if obj.runTTFF
                obj.calcTimeToFirstFixate(trialIdx,[],0)
            else
                timeToFirstFixate = 0;
            end
            
            %% RUN TFD FOR GAZE CONTINGENT
            if obj.runTFD
                obj.calcTotalFixationDuration(...
                    0,[],trialIdx,side)                                
            else
                totalFixationDuration = 0;
            end
            
%             % If there is an error for ttff then will be the same as tfd -
%             % write error
%             if exist('ttffErr')
%                 
%                     obj.addErrorToLog({...
%                         obj.subjectID,...
%                         obj.gapTrialTypes{trialIdx},...
%                         trialNo,...
%                         ttffErr});
%                     
%             % else if tfd error exists - write to log
%             elseif exist('tfdErr')
%                 
%                 % Write subject ID, task name, image ID and error
%                 % repeat cell rows based on number of errors (1 for no
%                 % fixations but potentially >1 for no AOI hits
%                 nErr = numel(tfdErr);
%                 
%                 msg = repmat({...
%                     obj.subjectID,...
%                     obj.gapTrialTypes{trialIdx},...
%                     trialNo,''},...
%                     nErr,1);
%                 
%                 % If no fixations, input error message
%                 % Else if no aoihits - build error rows based on AOI Name
%                 if noFixs
%                     
%                     msg(:,4) = tfdErr;
%                     
%                 elseif noHitsSide
%                     
%                     for iErr = 1:nErr    
%                         aoiIdx = noHitsSide(iErr);    
%                         msg{iErr,4} = strcat(...
%                             tfdErr{iErr},'_',aoiNames{aoiIdx});
%                     end
%                     
%                 end
% 
%                 % Update error log
%                 obj.addErrorToLog(msg);
                
%             end        
            
        end
            
        function runStaticSpatialFilter(obj,Image)

            % Aoi names for Image
            aoiNames = [Image.Aois.aoiName,'NotOnAoi'];
            
            % If no parsing calculate looking times
            if ~obj.FixFilter.parseOn
                obj.calcTotalLookingTime([],[],Image.imageID,1);
                return
            end
            
            %% Run TTFF for static images
            if obj.runTTFF
                obj.calcTimeToFirstFixate([],Image.imageID,1)                
            else
                timeToFirstFixate = 0;
            end      
            
            %% Run TFD for static images
            if obj.runTFD
                
                obj.calcTotalFixationDuration(...
                    1,Image.imageID,[],[])
%                 % If no hits for one/more AOIs of no fixations
%                 if noHits
%                     tfdErr = totalFixationDuration(noHits);
%                 elseif noFixs
%                     tfdErr = totalFixationDuration;
%                 end
                

            else
                totalFixationDuration = 0;
            end
            
            % If there is an error for ttff then will be the same as tfd -
            % write error
            if exist('ttffErr')
                
                obj.addErrorToLog({...
                obj.subjectID,...
                obj.TaskObj.taskName,...
                Image.imageID,...
                ttffErr});
    
            % else if tfd error exists - write to log
            elseif exist('tfdErr')
                
                % Write subject ID, task name, image ID and error
                % repeat cell rows based on number of errors (1 for no
                % fixations but potentially >1 for no AOI hits
                nErr = numel(tfdErr);
                
                msg = repmat({...
                    obj.subjectID,...
                    obj.TaskObj.taskName,...
                    Image.imageID,''},...
                    nErr,1);
                
                % If no fixations, input error message
                % Else if no aoihits - build error rows based on AOI Name
                if noFixs
                    
                    msg(:,4) = tfdErr;
                    
                elseif noHits
                    
                    for iErr = 1:nErr    
                        aoiIdx = noHits(iErr);    
                        msg{iErr,4} = strcat(...
                            tfdErr{iErr},'_',aoiNames{aoiIdx});
                    end
                    
                end

                % Update error log
                obj.addErrorToLog(msg);
                
            end              
            
                      
        end
        
        function calcTotalLookingTime(obj,trialIdx,side,imgID,taskIdx)
            
            % Get Looking Times
            lookingTimes = ...
                obj.SpatialFilter.calculateLookingTimes(1);

            % Type of task 
            taskType = obj.TaskObj.taskType;
            
            % Fill data based on task Type
            if strcmpi(taskType,"STATIC")                
                
                % Get column index to input data
                colIdx = obj.getDataColumns(...
                    taskIdx,[],imgID,obj.tLTHeaders);
                
                % Fill Data
                obj.tLTData(1,colIdx) = lookingTimes;
            
            elseif strcmpi(taskType,"GAZE_CONTINGENT")                

                colIdx = obj.getDataColumns(...
                    taskIdx,trialIdx,[],obj.tLTData);
                % Fill Data
                % aoiIdx refers to left/right side and not on AOI
                aoiIdx = [side,3];

                obj.tLTData{trialIdx}(colIdx:colIdx+1) =...
                    lookingTimes(aoiIdx);
                
            end

        end
        
        function calcTimeToFirstFixate(obj,trialIdx,imageID,taskIdx)
            
            % Get time to first fixate by AOI only (0) or all AOIs (1)
            % taskIdx --> static = 1, gaze contingent = 0
            [timeToFirstFixate,noHits,noFixs] =...
                obj.SpatialFilter.calculateTTFF(obj.eventOnsetTime,taskIdx);
            
            % If no hits for one/more AOIs or no fixations
            if noHits
                ttffErr = timeToFirstFixate(noHits);
            elseif noFixs
                ttffErr = timeToFirstFixate;
            end
            

            %% GAZE CONTINGENT INPUT
            if taskIdx == 0 
               
                % Get column index for input
                colIdx = obj.getDataColumns(...
                    taskIdx,trialIdx,[],obj.tTFFData);                
                % Input time to first fixate
                obj.tTFFData{trialIdx}(colIdx) = timeToFirstFixate;
            
            %% STATIC IMAGE INPUT
            elseif taskIdx == 1

                % Get columns to input aoi details
                colIdx = obj.getDataColumns(...
                    taskIdx,[],imageID,obj.ttffHeaders) ;               
                % Input time to first fixate
                obj.tTFFData(1,colIdx) = timeToFirstFixate;
                
            end
             
        end
        
        function calcTotalFixationDuration(obj,taskIdx,imageID,trialIdx,side)
           
                % Get total fixation duration by AOI
                [totalFixationDuration,noHits,noFixs] = ...
                    obj.SpatialFilter.calculateTfd(1);

                %% STATIC
                if taskIdx == 1
                    
                    colIdx = obj.getDataColumns(...
                        taskIdx,[],imageID,obj.tfdHeaders);
                    
                    % Input total fixation duration
                    obj.tFDData(1,colIdx) = totalFixationDuration;
                
                %% GAZE CONTINGENT
                elseif taskIdx == 0
                    
                    % Get column index for input
                    colIdx = obj.getDataColumns(...
                        taskIdx,trialIdx,[],obj.tFDData);                
                    
                    % Get left/right side and not on aoi
                    aoiIdx = [side,3];

    %                 % Two columns for each trial in/out AOI
    %                 colIdx = colIdx*2-1;

                    % If no hits for one/more AOIs or no fixations
                    if find(ismember(noHits,aoiIdx))
                        % Find no hits as member of aoiIdx
                        % (Include the side PS displayed and NotOnAoi)
                        noHitsSide = find(ismember(noHits,aoiIdx));
                        tfdErr = totalFixationDuration(noHitsSide);
                    elseif noFixs
                        % If no fixations - create 1x2 cell array
                        tfdErr = totalFixationDuration;
                        aoiIdx = [1 2];
                        totalFixationDuration = ...
                            repmat(totalFixationDuration,1,2);
                    end

                    % Input total fixation duration
                    obj.tFDData{trialIdx}...
                        (colIdx:colIdx+1) = totalFixationDuration(aoiIdx);


                end
                
        end
        
        function idx = getDataColumns(obj,taskIdx,trialIdx,imgID,dataFind)
            
            % If static image and Total Looking Time
            if taskIdx == 1

                % Get columns to input aoi details
                colString = strcat(imgID,'_');
                idx = find(contains(dataFind,colString));
            
            % else if gaze contingent and Total Looking Time
            elseif taskIdx == 0
                
                idx = find(...
                    cellfun('isempty',dataFind{trialIdx}),1);
                    
            end
            

        end
        
        function createErrorMessage(obj,err)
           
            
        end
        
        function writeFilteredData(obj,image)
           
           saveName = strcat(image.imageID,'_filteredData.csv');
           filepath = fullfile(obj.subjectDirectory,saveName);
           
           % Get headers
           timeHeaders = {'RemoteTime','msFromOnset'};
           eventHeaders = {'EventType','EventIndex','EventDuration'};
           gazeHeaders = obj.FixFilter.gazeBufferVars;
           headers = [timeHeaders,eventHeaders,gazeHeaders];
           
           % Convert arrays to table
           gazeData = obj.taskData;
           timeData = [obj.remoteTime,obj.msFromOnset];
           if sum(cell2mat(strfind(obj.FixFilter.gazeEventType,'Unclassified'))) == length(obj.FixFilter.gazeEventType)
              obj.FixFilter.gazeEventIndex = NaN(size(obj.FixFilter.gazeEventType));
              obj.FixFilter.gazeEventDuration = NaN(size(obj.FixFilter.gazeEventType));
           end
           eventData = [obj.FixFilter.gazeEventType,...
               obj.FixFilter.gazeEventIndex,...
               obj.FixFilter.gazeEventDuration];
           dataArray = [timeData,eventData,gazeData];
           filteredData = array2table(dataArray,...
               'VariableNames',headers);
           
           % Write table to file
           writetable(filteredData,filepath,'Delimiter',',');
           
           
        end
        
        function writeTFD(obj,ids,tFD)
            
            task = obj.TaskObj;
            taskName = task.taskName;
            taskType = task.taskType;
            
            if strcmpi(taskType,'GAZE_CONTINGENT')
                
                % Get data array and headers for gap trial
                [tFD, headers] = combineGapTrialArrays(tFD,'TFD');
                
            elseif strcmpi(taskType,'STATIC')
                headers = obj.tfdHeaders;
            end
        
            saveName = strcat(taskName,'_TFD.CSV');
            headers = strrep(headers,'-','');
            aoiTable = array2table(tFD,'VariableNames',headers);
            subjectTable = cell2table(ids,'VariableNames',{'SubjectID'});
            aoiTable = [subjectTable,aoiTable];

            writetable(aoiTable,fullfile(obj.studyDirectory,saveName));
            
        end

        function writeTTFF(obj,ids,tTFF)
            
            task = obj.TaskObj;
            taskName = task.taskName;
            taskType = task.taskType;
            
            if strcmpi(taskType,'GAZE_CONTINGENT')
                
                % Get data array and headers for gap trial
                [Data, headers] = combineGapTrialArrays(tTFF,'TTFF');
            elseif strcmpi(taskType,'STATIC')
                headers = obj.ttffHeaders;
                Data = tTFF;
            end
            
            % Save to file
            saveName = strcat(taskName,'_TTFF Table.CSV');
            aoiTable = array2table(Data,'VariableNames',headers);
            subjectTable = cell2table(ids,'VariableNames',{'PARTICIPANT_CODE'});
            aoiTable = [subjectTable,aoiTable];

            writetable(aoiTable,fullfile(obj.studyDirectory,saveName));
            
        end

        function writeTLT(obj,ids,tLT)
            
            task = obj.TaskObj;
            taskName = task.taskName;
            taskType = task.taskType;
            
            if strcmpi(taskType,'GAZE_CONTINGENT')
                
                % Get data array and headers for gap trial
                [Data, headers] = combineGapTrialArrays(tLT,'TLT');
            elseif strcmpi(taskType,'STATIC')
                headers = obj.tLTHeaders;
                Data = tLT;
            end
            
            % Save to file
            saveName = strcat(taskName,'_TLT Table.CSV');
            aoiTable = array2table(Data,'VariableNames',headers);
            subjectTable = cell2table(ids,'VariableNames',{'PARTICIPANT_CODE'});
            aoiTable = [subjectTable,aoiTable];

            writetable(aoiTable,fullfile(obj.studyDirectory,saveName));
            
        end
        
        function writeDataLogFile(obj)
        %UNTITLED3 Summary of this function goes here
        %   Detailed explanation goes here

            % Filename
            taskName = obj.TaskObj.taskName;

            saveName=[...
                'datalog_',...            
                taskName,...
                ' ',...
                datestr(now,7),...
                datestr(now,3),...
                ' ',...
                replace(datestr(now,15),':','.'),...
                '.txt'];
            
            % file path
            fileName = fullfile(obj.studyDirectory,saveName);
            
            % Create cell array with headers
            outCell = [obj.dataLogHeaders;obj.dataLog];
            % Convert to dataset
            outDat = cell2dataset(outCell);
            % Export
            export(outDat,'File',fileName,'Delimiter',',')
        end        
        
        function writeErrorLogFile(obj)
        %UNTITLED3 Summary of this function goes here
        %   Detailed explanation goes here

            % Filename
            taskName = obj.TaskObj.taskName;

            saveName=[...
                'errorlog_',...            
                taskName,...
                ' ',...
                datestr(now,7),...
                datestr(now,3),...
                ' ',...
                replace(datestr(now,15),':','.'),...
                '.txt'];
            
            % file path
            fileName = fullfile(obj.studyDirectory,saveName);
            
            % Create cell array with headers
            outCell = [obj.errorLogHeaders;obj.errorLog];
            % Convert to dataset
            outDat = cell2dataset(outCell);
            % Export
            export(outDat,'File',fileName,'Delimiter',',')

        end    
        
        function addErrorToLog(obj,msgCell)

            % nRows in msg
            [msgRows,~] = size(msgCell);
            
            % get first empty row
            if isempty(obj.errorLog{1})
                nextRow = 1;
            else
                [nRows,~] = size(obj.errorLog); 
                nextRow = nRows + 1;
            end

            % Get end row
            endRow = nextRow+(msgRows-1);
            
            % Add message to error log
            obj.errorLog(nextRow:endRow,:) = [...
                msgCell(:,1),...
                msgCell(:,2),...
                msgCell(:,3),...
                msgCell(:,4)];
            
        end
        
        function addDataToLog(obj,msgCell)

            % nRows in msg
            [msgRows,~] = size(msgCell);
            
            % get first empty row
            if isempty(obj.dataLog{1})
                nextRow = 1;
            else
                [nRows,~] = size(obj.dataLog); 
                nextRow = nRows + 1;
            end

            % Get end row
            endRow = nextRow+(msgRows-1);
            
            % Add message to data log
            obj.dataLog(nextRow:endRow,:) = [...
                msgCell(:,1),...
                msgCell(:,2),...
                msgCell(:,3 ),...
                msgCell(:,4)];
            
        end  
        
    end
end

