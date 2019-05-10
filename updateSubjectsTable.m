function [ids,paths] = updateSubjectsTable(app)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    [ids,paths] = getSubjectIDs(app.txtSubjectPath.Value);
    
    nIds = numel(ids);

    if nIds > 1
        chks = true(nIds,1);
        tdata = table(chks,ids);
        app.tblSubjects.ColumnEditable = [true,false];
        app.tblSubjects.ForegroundColor = [0,0,0];
        app.tblSubjects.FontAngle = 'normal';

    else
        tdata = [{'N/A'} {'N/A'}];
        app.tblSubjects.ColumnEditable = [false,false];
        app.tblSubjects.ForegroundColor = [0.65 0.65 0.65];
        app.tblSubjects.FontAngle = 'italic';

    end

    app.tblSubjects.Data = tdata;

    % subjs = dat{find(dat{:,1}),2}

end

