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
    h5write(filepath,sprintf('%s/HingeVector',loc),[obj.HingeVector],[1,1],[3,N]);
    h5write(filepath,sprintf('%s/Rotation',loc),[obj.Rotation],[1,1],[1,N]);
    h5write(filepath,sprintf('%s/K',loc),[obj.K],[1,1],[1,N]);
    h5write(filepath,sprintf('%s/C',loc),[obj.C],[1,1],[1,N]);
    h5write(filepath,sprintf('%s/isLocked',loc),double([obj.isLocked]),[1,1],[1,N]);

    h5writeatt(filepath,[loc,'/'],'Qty', length(obj));
end