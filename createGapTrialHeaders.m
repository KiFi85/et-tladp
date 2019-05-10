function headers = createGapTrialHeaders(trialType,summaryType,maxTrials)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

    % Empty cell array
    trialHeaders = cell(1,maxTrials);
    
    if strcmpi(summaryType,'TTFF')
        
        % Loop through trials, index and append TTFF
        for iTrial = 1:maxTrials

            % Create header in style 'GAP_TRIAL_1_LEFT'
            trialHeaders(1,iTrial) = {strcat(trialType,'_TRIAL_',int2str(iTrial),'_',summaryType)};

        end

        % Add mean header to end
        headers = [...
                trialHeaders,{strcat(...
                        'MEAN_',...
                        trialType,...
                        '_',summaryType,'_',...
                        'PS')}];   
            
    elseif strcmpi(summaryType,'TFD') || strcmpi(summaryType,'TLT')
        
        ctr = 0;
        
        % Loop through ps 
        for iTrial = 1:2:maxTrials-1
            
            ctr = ctr+1;
            % Create header in style 'GAP_TRIAL_1_LEFT'
            trialHeaders(1,iTrial) = {strcat(...
                trialType,...
                '_TRIAL_',...
                int2str(ctr),...
                '_',...
                summaryType,...
                '_OnPs')};

        end
        
        ctr = 0;
        
        % Loop through not on ps 
        for iTrial = 2:2:maxTrials
            
            ctr = ctr+1;
            % Create header in style 'GAP_TRIAL_1_LEFT'
            trialHeaders(1,iTrial) = {strcat(...
                trialType,...
                '_TRIAL_',...
                int2str(ctr),...
                '_',...
                summaryType,...
                '_NotOnPs')};

        end
        
        
        % Add mean header to end
        headers = [...
                trialHeaders,...
                {strcat('MEAN_',trialType,'_',summaryType,'_OnPs')},...
                {strcat('MEAN_',trialType,'_',summaryType,'_NotOnPs')}];   
        
        
    end
end

