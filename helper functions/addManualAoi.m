function nAois = addManualAoi(app,t)
% %UNTITLED Summary of this function goes here
% %   Detailed explanation goes here


    aoiCtr = 0;

    for iRow = 1:height(t.Data)

        % Check name isn't empty
        aoiName = table2cell(t.Data(iRow,1));
        nameChk = aoiName{:}~="";

        % Check all position data is entered
        aoiPosition = table2array(t.Data(iRow,3:6));
        positionChk = all(aoiPosition);

        % complete if name and position data filled
        completeRow = and(nameChk,positionChk);

        % if complete row - add new aoi
        if completeRow

            aoiCtr = aoiCtr+1;

            aoi = EyeTrackAOI;

            % Add name and shape details
            aoi.aoiName = string(aoiName{1});
            aoi.shape = 'rectangle';

            % Create roi object and get vertices
            aoi.position = aoiPosition;
            h = images.roi.Rectangle('Position',aoiPosition);
            aoi.vertices = h.Vertices;

            % Add to start or end of new aoi(s)
            if isempty(app.NewAoi(1).aoiName)
                app.NewAoi = aoi;   
            else
                app.NewAoi = [app.NewAoi,aoi];
            end

        end

    end

nAois = aoiCtr;

end    

