function obj = FromBaff(filepath,loc)
%FROMBAFF build a beam BAFF object from a HDF5 file.
%Args:
%   filepath: path to the HDF5 file
%   loc: location in the HDF5 file where the beam data is stored
Qty = h5readatt(filepath,[loc,'/ControlSurface/'],'Qty');
obj = baff.ControlSurface.empty;
if Qty == 0    
    return;
end
%% create aerostations
names = h5read(filepath,sprintf('%s/ControlSurface/Names',loc));
etas = h5read(filepath,sprintf('%s/ControlSurface/Etas',loc));
cs = h5read(filepath,sprintf('%s/ControlSurface/pChords',loc));
for i = 1:Qty
    obj(i) = baff.ControlSurface(names(i),etas(:,i),cs(:,i));
end
end

