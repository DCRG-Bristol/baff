function obj = FromBaff(filepath,loc)
%FROMBAFF build a beam BAFF object from a HDF5 file.
%Args:
%   filepath: path to the HDF5 file
%   loc: location in the HDF5 file where the beam data is stored
Qty = h5readatt(filepath,[loc,'/'],'Qty');
if Qty == 0
    obj = baff.Payload.empty;
    return;
end
%create fuel
for i = 1:Qty
    obj(i) = baff.Payload(0);
end
BaffToProp(obj,filepath,loc);
end

