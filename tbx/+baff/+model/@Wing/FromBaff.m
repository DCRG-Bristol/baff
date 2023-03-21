function obj = FromBaff(filepath,loc)
%FROMBAFF Summary of this function goes here
%   Detailed explanation goes here
Qty = h5readatt(filepath,[loc,'/'],'Qty');
if Qty == 0
    obj = baff.model.Wing.empty;
    return;
end
%% create aerostations
aQty = h5readatt(filepath,[loc,'/AeroStations/'],'Qty');
aStations = baff.model.AeroStation.empty;
etas = h5read(filepath,sprintf('%s/AeroStations/eta',loc));
chords = h5read(filepath,sprintf('%s/AeroStations/Chord',loc));
twists = h5read(filepath,sprintf('%s/AeroStations/Twist',loc));
beamlocs = h5read(filepath,sprintf('%s/AeroStations/BeamLoc',loc));
for i = 1:aQty
    aStations(i) = baff.model.AeroStation(etas(i),chords(i),beamlocs(i),"Twist",twists(i));
end
%% create beamstations
bQty = h5readatt(filepath,[loc,'/Stations/'],'Qty');
bs = baff.model.BeamStation.empty;
etas = h5read(filepath,sprintf('%s/Stations/eta',loc));
As = h5read(filepath,sprintf('%s/Stations/A',loc));
Ixxs = h5read(filepath,sprintf('%s/Stations/Ixx',loc));
Izzs = h5read(filepath,sprintf('%s/Stations/Izz',loc));
Es = h5read(filepath,sprintf('%s/Stations/E',loc));
rhos = h5read(filepath,sprintf('%s/Stations/rho',loc));
nus = h5read(filepath,sprintf('%s/Stations/nu',loc));
for i = 1:bQty
    mat = baff.model.Material(Es(i),nus(i),rhos(i));
    bs(i) = baff.model.BeamStation(etas(i),A=As(i),Ixx=Ixxs(i),Izz=Izzs(i),Mat=mat);
end
%%create wings
aBNs = h5readatt(filepath,[loc,'/AeroStations/'],'Idx');
aBN_idx = [0,cumsum(aBNs)'];
aNs = h5readatt(filepath,[loc,'/Stations/'],'Idx');
aN_idx = [0,cumsum(aNs)'];
for i = 1:Qty
    obj(i) = baff.model.Wing(aStations((aBN_idx(i)+1):(aBN_idx(i)+aBNs(i))));
    obj(i).Stations = bs((aN_idx(i)+1):(aN_idx(i)+aNs(i)));
end
BaffToProp(obj,filepath,loc);    
end

