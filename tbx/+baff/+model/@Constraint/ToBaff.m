function ToBaff(obj,filepath,loc)
    % write default items
    PropToBaff(obj,filepath,loc);
    %% write mass specific items
    N = length(obj);
    if N == 0
        h5writeatt(filepath,[loc,'/'],'Qty', 0);
        return
    end
    %create place holders
    h5create(filepath,sprintf('%s/ComponentNums',loc),[1 N]);
    %fill data
    h5write(filepath,sprintf('%s/ComponentNums',loc),[obj.ComponentNums]);

    h5writeatt(filepath,[loc,'/'],'Qty', length(obj));
end