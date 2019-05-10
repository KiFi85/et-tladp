function [obj] = createSubjectData(app)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    % Create objects to pass to main function
    SpatialFilter = EyeTrackSpatialFilter;
    SpatialFilter.FixationFilter = app.Filter;

    % Main Data Class
    SubjectData = EyeTrackData(...
        app.RunTask,...
        app.Filter,...
        SpatialFilter);

    % Temporal Filter
    SubjectData.windowStart = app.txtWindowStart;
    SubjectData.windowEnd = app.txtWindowEnd;

    % Study folder
    SubjectData.studyDirectory = app.studyPath;

    % Output variables
    SubjectData.runTLT = app.cbxTotalLookingTime.Value;
    SubjectData.runTFD = app.cbxTotalFixationDuration.Value;
    SubjectData.runTTFF = app.cbxTimeToFirstFixate.Value;  
    SubjectData.saveData = app.cbxRawFilter.Value;
    
    obj = SubjectData;

end

