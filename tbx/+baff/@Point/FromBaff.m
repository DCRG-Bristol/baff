function obj = FromBaff(filepath,loc)
%FROMBAFF build a beam BAFF object from a HDF5 file.
%Args:
%   filepath: path to the HDF5 file
%   loc: location in the HDF5 file where the beam data is stored
Qty = h5readatt(filepath,[loc,'/'],'Qty');
if Qty == 0
    obj = baff.Point.empty;
    return;
end
%create hinges
Fs = h5read(filepath,sprintf('%s/Force',loc));
Ms = h5read(filepath,sprintf('%s/Moment',loc));
for i = 1:Qty
    obj(i) = baff.Point();
    obj(i).Force = Fs(:,i);
    obj(i).Moment = Ms(:,i);
end
BaffToProp(obj,filepath,loc);
end

