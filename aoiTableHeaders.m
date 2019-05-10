function out = aoiTableHeaders(Task,notOnAoiHeader,descriptor)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

    taskType = Task.taskType;
    
    if isempty(descriptor)
        descriptor = '_';
    else
        descriptor = strcat('_',descriptor,'_');
    end

    if strcmpi(taskType,"STATIC")

            Images = Task.Images;

            aoiCounts = {Images.Count};
            Aois = {Images.Aois};

            % TOtal number of AOIs + not on AOIs
            nAois = sum([aoiCounts{:}]) + length(aoiCounts);

            imageNames = {Task.Images.imageID};

            aoiCtr = 0;

            for iImage = 1:length(Images)
                imageName = imageNames{iImage};
                
                if notOnAoiHeader
                    aoiNames = {Aois{iImage}.aoiName,'NotOnAoi'}';
                else
                    aoiNames = {Aois{iImage}.aoiName}';
                end
                
                aoiNames = cellfun(@(x) char(x),aoiNames,'UniformOutput',false);

                imageName = repmat({imageName},1,length(aoiNames))';
                
%                 if notOnAoiHeader
%                     headStr = strcat(imageName, {'_TFD_'}, aoiNames)';
%                 else
%                     headStr = strcat(imageName, {'_TTFF_'}, aoiNames)';
%                 end
                
                headStr = strcat(imageName, {descriptor}, aoiNames)';

                if iImage == 1
                    headers = headStr;
                else
                    headers = [headers,headStr];
                end

            end

    elseif strcmpi(taskType,"GAZE_CONTINGENT")

            [baseline,gap,overlap] = deal(cell(1,12));

            for iTrial = 1:12

                baseline(1,iTrial) = {strcat('BASELINE_TRIAL_',int2str(iTrial))};
                gap(1,iTrial) = {strcat('GAP_TRIAL_',int2str(iTrial))};
                overlap(1,iTrial) = {strcat('OVERLAP_TRIAL_',int2str(iTrial))};

            end

            headers = [...
                    baseline,...
                    {'MEAN_BASELINE_TTFF_PERIPHERAL'},...
                    gap,...
                    {'MEAN_GAP_TTFF_PERIPHERAL'},...
                    overlap,...
                    {'MEAN_OVERLAP_TTFF_PERIPHERAL'}...
                    ];    

    end
    out = headers;

end

