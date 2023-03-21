function obj = FromBaff(filepath,loc)
%FROMBAFF Summary of this function goes here
%   Detailed explanation goes here
Qty = h5readatt(filepath,[loc,'/'],'Qty');
if Qty == 0
    obj = baff.model.Constraint.empty;
    return;
end
ComponentNums = h5read(filepath,sprintf('%s/ComponentNums',loc));
for i = 1:Qty
    obj(i) = baff.model.Constraint("ComponentNums",ComponentNums(i));
end
BaffToProp(obj,filepath,loc);  
end

