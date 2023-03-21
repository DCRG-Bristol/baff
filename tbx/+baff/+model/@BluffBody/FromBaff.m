function obj = FromBaff(filepath,loc)
%FROMBAFF Summary of this function goes here
%   Detailed explanation goes here
Qty = h5readatt(filepath,[loc,'/'],'Qty');
if Qty == 0
    obj = baff.model.BluffBody.empty;
    return;
end
%% create beamstations
bQty = h5readatt(filepath,[loc,'/Stations/'],'Qty');
bs = baff.model.BodyStation.empty;
etas = h5read(filepath,sprintf('%s/Stations/eta',loc));
As = h5read(filepath,sprintf('%s/Stations/A',loc));
Rs = h5read(filepath,sprintf('%s/Stations/Radius',loc));
Ixxs = h5read(filepath,sprintf('%s/Stations/Ixx',loc));
Izzs = h5read(filepath,sprintf('%s/Stations/Izz',loc));
Es = h5read(filepath,sprintf('%s/Stations/E',loc));
rhos = h5read(filepath,sprintf('%s/Stations/rho',loc));
nus = h5read(filepath,sprintf('%s/Stations/nu',loc));
for i = 1:bQty
    mat = baff.model.Material(Es(i),nus(i),rhos(i));
    bs(i) = baff.model.BodyStation(etas(i),radius=Rs(i),A=As(i),Ixx=Ixxs(i),Izz=Izzs(i),Mat=mat);
end
%%create beams
aNs = h5readatt(filepath,[loc,'/Stations/'],'Idx');
aN_idx = [0,cumsum(aNs)'];
for i = 1:Qty
    obj(i) = baff.model.BluffBody();
    obj(i).Stations = bs((aN_idx(i)+1):(aN_idx(i)+aNs(i)));
end
BaffToProp(obj,filepath,loc);    
end

