function ToBaff(obj,filepath,loc)
    % write default items
    PropToBaff(obj,filepath,loc);
    %% write mass specific items
    N = length(obj);
    h5writeatt(filepath,[loc,'/'],'Qty', N);
    if N == 0
        return
    end
    
    %% sort out beam stations
    Bstations = [obj.Stations];
    Bstations.ToBaff(filepath,loc);
    BNs = arrayfun(@(x)length(x.Stations),obj);
    h5writeatt(filepath,sprintf('%s/',loc),'BeamStationsIdx', BNs);
end