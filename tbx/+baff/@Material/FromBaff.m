function obj = FromBaff(filepath,loc)
% write default items
Qty = h5readatt(filepath,[loc,'/Materials/'],'Qty');
obj = baff.Material.empty;
if Qty == 0    
    return;
end
%create Material Cards
Names = h5read(filepath,sprintf('%s/Materials/Name',loc));
Es = h5read(filepath,sprintf('%s/Materials/E',loc));
Gs = h5read(filepath,sprintf('%s/Materials/G',loc));
rhos = h5read(filepath,sprintf('%s/Materials/rho',loc));
nus = h5read(filepath,sprintf('%s/Materials/nu',loc));
for i = 1:Qty
    obj(i) = baff.Material(Es(i),nus(i),rhos(i),Names(i),G=Gs(i));
end
end

