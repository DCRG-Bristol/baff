function obj = FromBaff(filepath,loc)
%FROMBAFF Summary of this function goes here
%   Detailed explanation goes here
Qty = h5readatt(filepath,[loc,'/BodyStations/'],'Qty');
obj = baff.station.Body.empty;
if Qty == 0    
    return;
end
%% create aerostations
etas = h5read(filepath,sprintf('%s/BodyStations/Eta',loc));
etaDirs = h5read(filepath,sprintf('%s/BodyStations/EtaDir',loc));
stationDirs = h5read(filepath,sprintf('%s/BodyStations/StationDir',loc));
Rs = h5read(filepath,sprintf('%s/BodyStations/Radius',loc));
As = h5read(filepath,sprintf('%s/BodyStations/A',loc));
Is = h5read(filepath,sprintf('%s/BodyStations/I',loc));
Js = h5read(filepath,sprintf('%s/BodyStations/J',loc));
taus = h5read(filepath,sprintf('%s/BodyStations/Tau',loc));
Es = h5read(filepath,sprintf('%s/BodyStations/E',loc));
rhos = h5read(filepath,sprintf('%s/BodyStations/rho',loc));
nus = h5read(filepath,sprintf('%s/BodyStations/nu',loc));

for i = 1:Qty
    mat = baff.Material(Es(i),nus(i),rhos(i));
    obj(i) = baff.station.Body(etas(i),"radius",Rs(i),"EtaDir",etaDirs(:,i),...
    "StationDir",stationDirs(:,i),"Mat",mat,"J",Js(i));
    obj(i).A = As(i);
    obj(i).I = reshape(Is(:,i),3,3);
    obj(i).tau = reshape(taus(:,i),3,3);
end
end

