function obj = FromBaff(filepath,loc)
%FROMBAFF Summary of this function goes here
%   Detailed explanation goes here
Qty = h5readatt(filepath,[loc,'/BodyStations/'],'Qty');
obj = baff.model.station.Body.empty;
if Qty == 0    
    return;
end
%% create aerostations
etas = h5read(filepath,sprintf('%s/BodyStations/Eta',loc));
etaDirs = h5read(filepath,sprintf('%s/BodyStations/EtaDir',loc));
Rs = h5read(filepath,sprintf('%s/BodyStations/Radius',loc));
As = h5read(filepath,sprintf('%s/BodyStations/A',loc));
Ixxs = h5read(filepath,sprintf('%s/BodyStations/Ixx',loc));
Izzs = h5read(filepath,sprintf('%s/BodyStations/Izz',loc));
Es = h5read(filepath,sprintf('%s/BodyStations/E',loc));
rhos = h5read(filepath,sprintf('%s/BodyStations/rho',loc));
nus = h5read(filepath,sprintf('%s/BodyStations/nu',loc));

for i = 1:Qty
    mat = baff.model.Material(Es(i),nus(i),rhos(i));
    obj(i) = baff.model.station.Body(etas(i),"radius",Rs(i),"EtaDir",etaDirs(:,i),"Mat",mat);
    obj(i).A = As(i);
    obj(i).Ixx = Ixxs(i);
    obj(i).Izz = Izzs(i);
end
end

