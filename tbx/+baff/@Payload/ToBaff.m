function ToBaff(obj,filepath,loc)
    N = length(obj);
    h5writeatt(filepath,[loc,'/'],'Qty', N);
    if N ~= 0
        % write default items
        ToBaff@baff.Mass(obj,filepath,loc);
        % write fuel data
        h5write(filepath,sprintf('%s/FillingLevel',loc),[obj.FillingLevel],[1,1],[1,N]);
    end
end