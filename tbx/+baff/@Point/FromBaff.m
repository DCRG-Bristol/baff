function obj = FromBaff(filepath,loc)
% write default items
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

