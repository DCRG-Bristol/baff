function ToBaff(obj,filepath,loc)
N = length(obj);
h5writeatt(filepath,[loc,'/'],'Qty', N);
if N ~= 0
    % write default items
    ToBaff@baff.Beam(obj,filepath,loc);
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
end