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
    h5create(filepath,sprintf('%s/InertiaTensor',loc),[9 N]);
    h5create(filepath,sprintf('%s/Force',loc),[3 N]);
    h5create(filepath,sprintf('%s/Moment',loc),[3 N]);
    h5create(filepath,sprintf('%s/Mass',loc),[1 N]);
    %fill data
    h5write(filepath,sprintf('%s/InertiaTensor',loc),reshape([obj.InertiaTensor],9,[]));
    h5write(filepath,sprintf('%s/Force',loc),[obj.Force]);
    h5write(filepath,sprintf('%s/Moment',loc),[obj.Moment]);
    h5write(filepath,sprintf('%s/Mass',loc),[obj.mass]);

    h5writeatt(filepath,[loc,'/'],'Qty', length(obj));
end