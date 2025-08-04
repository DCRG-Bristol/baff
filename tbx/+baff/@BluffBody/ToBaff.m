function ToBaff(obj,filepath,loc)
%TOBAFF Write a beam BAFF object to a HDF5 file.
%Args:
%   filepath (string): Path to file
%   loc (string): Location in file
N = length(obj);
h5writeatt(filepath,[loc,'/'],'Qty', N);
if N ~= 0
    % write default items
    ToBaff@baff.Element(obj,filepath,loc);
    % Bluff Body Specific
    Bstations = [obj.Stations];
    Bstations.ToBaff(filepath,loc);
    BNs = arrayfun(@(x)x.Stations.N,obj);
    h5writeatt(filepath,sprintf('%s/',loc),'BodyStationsIdx', BNs);
end
end