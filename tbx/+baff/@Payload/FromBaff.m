function obj = FromBaff(filepath,loc)
% write default items
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

