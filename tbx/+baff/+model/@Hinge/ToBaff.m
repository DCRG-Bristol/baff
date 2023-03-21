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
    h5create(filepath,sprintf('%s/HingeVector',loc),[3 N]);
    h5create(filepath,sprintf('%s/Rotation',loc),[1 N]);
    h5create(filepath,sprintf('%s/K',loc),[1 N]);
    h5create(filepath,sprintf('%s/C',loc),[1 N]);
    h5create(filepath,sprintf('%s/isLocked',loc),[1 N]);
    %fill data
    h5write(filepath,sprintf('%s/HingeVector',loc),[obj.HingeVector]);
    h5write(filepath,sprintf('%s/Rotation',loc),[obj.Rotation]);
    h5write(filepath,sprintf('%s/K',loc),[obj.K]);
    h5write(filepath,sprintf('%s/C',loc),[obj.C]);
    h5write(filepath,sprintf('%s/isLocked',loc),[obj.isLocked]);

    h5writeatt(filepath,[loc,'/'],'Qty', length(obj));
end