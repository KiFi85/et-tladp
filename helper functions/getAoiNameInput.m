function aoiName=getAoiNameInput

    % Dialog box
    prompt = {'Enter AOI Name:'};
    title = 'AOI Name Input';
    dims = [1 75];
    definput = {''};
    answer = inputdlg(prompt,title,dims,definput);

    % If no name is given, run function again
    if isempty(answer)
        return
    elseif isempty(answer{1})
        
        msg = 'Please enter a name for the new AOI';
        uiwait(warndlg(msg,'Empty AOI Name'));
        aoiName = getAoiNameInput; 
    else
        aoiName = answer;
    end

end

% disp(answer)
