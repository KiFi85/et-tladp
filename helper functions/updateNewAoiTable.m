function updateNewAoiTable(app)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% app = EyeTrackEditTasks;


nAois = length(app.NewAoi);

tableCell = cell(nAois,6);

for iAoi = 1:nAois
    aoi = app.NewAoi(iAoi);
    name = aoi.aoiName;
    shape = aoi.shape;
    
    if strcmpi(aoi.shape,'freehand')
        xy = aoi.position;
        position = zeros(1,4);
        position(1) = min(xy(:,1));
        position(2) = min(xy(:,2));
        position(3) = max(xy(:,1)) - position(1);
        position(4) = max(xy(:,2)) - position(2);
        
    else
        position = aoi.position;
    end

    
    tableCell{iAoi,1} = name;
    tableCell{iAoi,2} = shape;
    tableCell(iAoi,3:6) = num2cell(position);

end

tdata = cell2table(tableCell);
app.tblNewAOIs.Data = tdata;

end

