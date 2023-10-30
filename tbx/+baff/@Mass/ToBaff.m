function ToBaff(obj,filepath,loc)
N = length(obj);
h5writeatt(filepath,[loc,'/'],'Qty', N);
if N ~= 0
    %call super
    ToBaff@baff.Point(obj,filepath,loc);

    h5write(filepath,sprintf('%s/InertiaTensor',loc),reshape([obj.InertiaTensor],9,[]),[1,1],[9,N]);
    h5write(filepath,sprintf('%s/Mass',loc),[obj.mass],[1,1],[1,N]);
end
end