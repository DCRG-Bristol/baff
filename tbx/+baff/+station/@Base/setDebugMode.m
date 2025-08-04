function setDebugMode(enable)
    % Get the path to the @Base folder
    classPath = fileparts(which('baff.station.Base'));
    subsrefPath = fullfile(classPath, 'subsref.m');
    if enable
        % Create subsref.m if it doesn't exist
        if ~exist(subsrefPath, 'file')
            content = [...
                "function varargout = subsref(obj, S)" ...
                "    if strcmp(S(1).type, '()')" ...
                "        warning(['Indexing is indicative of an old BAFF format in which stations were stored as arrays of station instances. ' ..." ...
                "            'BAFF v0.2 reimplements stations to have all values stored in a single class instance. Ensure your code is suitable for the new stations!']);" ...
                "    end" ...
                "    [varargout{1:nargout}] = builtin('subsref', obj, S);" ...
                "end"];
            
            % Write the file
            writelines(content, subsrefPath);
            clear('baff.station.Base'); % Force MATLAB to reload the class
        end
    else
        % Delete subsref.m if it exists
        if exist(subsrefPath, 'file')
            delete(subsrefPath);
            clear('baff.station.Base'); % Force MATLAB to reload the class
        end
    end
end