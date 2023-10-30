function ToBaff(obj,filepath,loc)
    N = length(obj);
    h5writeatt(filepath,[loc,'/'],'Qty', N);
    if N ~= 0
        % write default items
        ToBaff@baff.Element(obj,filepath,loc);
        %fill data
        h5write(filepath,sprintf('%s/Force',loc),[obj.Force],[1,1],[3,N]);
        h5write(filepath,sprintf('%s/Moment',loc),[obj.Moment],[1,1],[3,N]);
    end   
end