function ToBaff(obj,filepath,loc)
N = length(obj);
h5writeatt(filepath,[loc,'/'],'Qty', N);
if N ~= 0
    % write default items
    ToBaff@baff.Element(obj,filepath,loc);
    h5write(filepath,sprintf('%s/ComponentNums',loc),[obj.ComponentNums],[1,1],[1,N]);
end
end