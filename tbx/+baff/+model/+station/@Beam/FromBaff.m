function obj = FromBaff(filepath,loc)
%FROMBAFF Summary of this function goes here
%   Detailed explanation goes here
Qty = h5readatt(filepath,[loc,'/BeamStations/'],'Qty');
obj = baff.model.station.Beam.empty;
if Qty == 0    
    return;
end
%% create aerostations
etas = h5read(filepath,sprintf('%s/BeamStations/Eta',loc));
etaDirs = h5read(filepath,sprintf('%s/BeamStations/EtaDir',loc));
As = h5read(filepath,sprintf('%s/BeamStations/A',loc));
Ixxs = h5read(filepath,sprintf('%s/BeamStations/Ixx',loc));
Izzs = h5read(filepath,sprintf('%s/BeamStations/Izz',loc));
Es = h5read(filepath,sprintf('%s/BeamStations/E',loc));
rhos = h5read(filepath,sprintf('%s/BeamStations/rho',loc));
nus = h5read(filepath,sprintf('%s/BeamStations/nu',loc));
for i = 1:Qty
    mat = baff.model.Material(Es(i),nus(i),rhos(i));
    obj(i) = baff.model.station.Beam(etas(i),"EtaDir",etaDirs(:,i),"Mat",mat);
    obj(i).A = As(i);
    obj(i).Ixx = Ixxs(i);
    obj(i).Izz = Izzs(i);
end
end

