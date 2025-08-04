function obj = FromBaff(filepath,loc)
%FROMBAFF build a beam BAFF object from a HDF5 file.
%Args:
%   filepath: path to the HDF5 file
%   loc: location in the HDF5 file where the beam data is stored
Qty = h5readatt(filepath,[loc,'/'],'Qty');
if Qty == 0
    obj = baff.BluffBody.empty;
    return;
end
%% create bodystations
bIdx = h5readatt(filepath,[loc,'/'],'BodyStationsIdx');
bStations = baff.station.Body.FromBaff(filepath,loc);

%%create Bodies
bSum = [0,cumsum(bIdx)'];
for i = 1:Qty
    obj(i) = baff.BluffBody();
    obj(i).Stations = bStations.GetIndex((bSum(i)+1):(bSum(i)+bIdx(i)));
end
BaffToProp(obj,filepath,loc);    
end

