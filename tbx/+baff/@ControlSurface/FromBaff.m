function obj = FromBaff(filepath,loc)
%FROMBAFF Summary of this function goes here
%   Detailed explanation goes here
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

