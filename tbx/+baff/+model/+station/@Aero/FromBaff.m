function obj = FromBaff(filepath,loc)
%FROMBAFF Summary of this function goes here
%   Detailed explanation goes here
Qty = h5readatt(filepath,[loc,'/AeroStations/'],'Qty');
obj = baff.model.station.Aero.empty;
if Qty == 0    
    return;
end
%% create aerostations
etas = h5read(filepath,sprintf('%s/AeroStations/Eta',loc));
etaDirs = h5read(filepath,sprintf('%s/AeroStations/EtaDir',loc));
chords = h5read(filepath,sprintf('%s/AeroStations/Chord',loc));
twists = h5read(filepath,sprintf('%s/AeroStations/Twist',loc));
beamlocs = h5read(filepath,sprintf('%s/AeroStations/BeamLoc',loc));
for i = 1:Qty
    obj(i) = baff.model.station.Aero(etas(i),chords(i),beamlocs(i),"Twist",twists(i),"EtaDir",etaDirs(:,i));
end
end

