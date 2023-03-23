function obj = FromBaff(filepath,loc)
% write default items
Qty = h5readatt(filepath,[loc,'/'],'Qty');
if Qty == 0
    obj = baff.Mass.empty;
    return;
end
%create hinges
Is = h5read(filepath,sprintf('%s/InertiaTensor',loc));
Fs = h5read(filepath,sprintf('%s/Force',loc));
Ms = h5read(filepath,sprintf('%s/Moment',loc));
ms = h5read(filepath,sprintf('%s/Mass',loc));
for i = 1:Qty
    obj(i) = baff.Mass(ms(i));
    obj(i).InertiaTensor = reshape(Is(:,i),3,3);
    obj(i).Force = Fs(i);
    obj(i).Moment = Ms(i);
end
BaffToProp(obj,filepath,loc);
end

