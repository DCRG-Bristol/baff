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

    %% sort out Aero stations
    Bstations = [obj.AeroStations];
    Bstations.ToBaff(filepath,loc);
    ANs = arrayfun(@(x)length(x.AeroStations),obj);
    h5writeatt(filepath,sprintf('%s/',loc),'AeroStationsIdx', ANs);

    %% sort out Control Surfaces
    cs = [obj.ControlSurfaces];
    cs.ToBaff(filepath,loc);
    cNs = arrayfun(@(x)length(x.ControlSurfaces),obj);
    h5writeatt(filepath,sprintf('%s/',loc),'ControlSurfacesIdx', cNs);
end