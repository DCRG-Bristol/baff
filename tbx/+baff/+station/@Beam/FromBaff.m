function obj = FromBaff(filepath,loc)
%FROMBAFF Summary of this function goes here
%   Detailed explanation goes here
Qty = h5readatt(filepath,[loc,'/BeamStations/'],'Qty');

if Qty == 0
    obj = baff.station.Beam.Blank(0);
    return;
end
obj = baff.station.Beam.Blank(Qty);
%% create Mats
aIdx = h5readatt(filepath,[loc,'/'],'MatsIdx');
Mats = baff.Material.FromBaff(filepath,loc);
obj.Mat = Mats(aIdx);
%% create aerostations
obj.Eta = h5read(filepath,sprintf('%s/BeamStations/Eta',loc));
obj.EtaDir = h5read(filepath,sprintf('%s/BeamStations/EtaDir',loc));
obj.StationDir = h5read(filepath,sprintf('%s/BeamStations/StationDir',loc));
obj.A = h5read(filepath,sprintf('%s/BeamStations/A',loc));
obj.I = reshape(h5read(filepath,sprintf('%s/BeamStations/I',loc)),3,3,[]);
obj.J = h5read(filepath,sprintf('%s/BeamStations/J',loc));
obj.tau = reshape(h5read(filepath,sprintf('%s/BeamStations/Tau',loc)),3,3,[]);
end

