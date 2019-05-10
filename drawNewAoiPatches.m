function drawNewAoiPatches(app,fig)

    % Number of Aois to draw
    nAois = numel(app.NewAoi);

    % Empty cell array to fill
    [xData,yData] = deal(cell(1,nAois));
    
    % Create x,y vertices for patch
    for iAoi = 1:nAois

        % Get vertices from AOI
        xData{iAoi} = app.NewAoi(iAoi).vertices(:,1);
        yData{iAoi} = app.NewAoi(iAoi).vertices(:,2);

    end

    % Get largest number of vertices
    maxX = max(cellfun(@numel,xData));
    maxY = max(cellfun(@numel,yData));

    % Expand smaller arrays, fill with last value to end
    for iAoi = 1:nAois
        numX = numel(xData{iAoi});
        diff = maxX - numX;

        if diff
            xData{iAoi} = [xData{iAoi};nan(1,maxX-numX)'];
            xData{iAoi} = fillmissing(xData{iAoi},'previous');
        end

        numY = numel(yData{iAoi});
        diff = maxY - numY;

        if diff
            yData{iAoi} = [yData{iAoi};nan(1,maxY-numY)'];
            yData{iAoi} = fillmissing(yData{iAoi},'previous');
        end

    end

    % Create X and Y data arrays for patch
    xData = cell2mat(xData);
    yData = cell2mat(yData);

    % Create patches
    p1 = patch(xData,yData,'blue','visible','off','Parent',fig);
    p1.FaceAlpha=0.3;
    p1.LineStyle='none';
    p1.Visible='on';
end