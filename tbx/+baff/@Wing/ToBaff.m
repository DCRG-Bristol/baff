function ToBaff(obj,filepath,loc)
%TOBAFF Write a beam BAFF object to a HDF5 file.
%Args:
%   filepath (string): Path to file
%   loc (string): Location in file
N = length(obj);
h5writeatt(filepath,[loc,'/'],'Qty', N);
if N ~= 0
    % write default items
    ToBaff@baff.Beam(obj,filepath,loc);
    %% sort out Aero stations
    Bstations = [obj.AeroStations];
    Bstations.ToBaff(filepath,loc);
    ANs = arrayfun(@(x)x.AeroStations.N,obj);
    h5writeatt(filepath,sprintf('%s/',loc),'AeroStationsIdx', ANs);

    %% sort out Control Surfaces
    cs = [obj.ControlSurfaces];
    cs.ToBaff(filepath,loc);
    cNs = arrayfun(@(x)length(x.ControlSurfaces),obj);
    h5writeatt(filepath,sprintf('%s/',loc),'ControlSurfacesIdx', cNs);
end
end