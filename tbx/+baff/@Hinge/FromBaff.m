function obj = FromBaff(filepath,loc)
% write default items
Qty = h5readatt(filepath,[loc,'/'],'Qty');
if Qty == 0
    obj = baff.Hinge.empty;
    return;
end
%create hinges
vs = h5read(filepath,sprintf('%s/HingeVector',loc));
rs = h5read(filepath,sprintf('%s/Rotation',loc));
ks = h5read(filepath,sprintf('%s/K',loc));
cs = h5read(filepath,sprintf('%s/C',loc));
ils = h5read(filepath,sprintf('%s/isLocked',loc));
for i = 1:Qty
    obj(i) = baff.Hinge();
    obj(i).HingeVector = vs(:,i);
    obj(i).Rotation = rs(i);
    obj(i).K = ks(i);
    obj(i).C = cs(i);
    obj(i).isLocked = ils(i);
end
BaffToProp(obj,filepath,loc);
end

