function ToBaff(obj,filepath,loc)
    % write default items
    PropToBaff(obj,filepath,loc);
    %% write mass specific items
    N = length(obj);
    if N == 0
        h5writeatt(filepath,[loc,'/'],'Qty', 0);
        return
    end

    %fill data
    h5write(filepath,sprintf('%s/InertiaTensor',loc),reshape([obj.InertiaTensor],9,[]),[1,1],[9,N]);
    h5write(filepath,sprintf('%s/Force',loc),[obj.Force],[1,1],[3,N]);
    h5write(filepath,sprintf('%s/Moment',loc),[obj.Moment],[1,1],[3,N]);
    h5write(filepath,sprintf('%s/Mass',loc),[obj.mass],[1,1],[1,N]);

    h5writeatt(filepath,[loc,'/'],'Qty', length(obj));
end