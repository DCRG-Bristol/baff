function obj = FromBaff(filepath,loc)
%FROMBAFF Summary of this function goes here
%   Detailed explanation goes here
Qty = h5readatt(filepath,[loc,'/BodyStations/'],'Qty');

if Qty == 0    
    obj = baff.station.Body.Blank(0);
    return;
end
%% create Body Stations
obj = baff.station.Body.Blank(Qty);
%% create Mats
aIdx = h5readatt(filepath,[loc,'/'],'MatsIdx');
Mats = baff.Material.FromBaff(filepath,loc);
obj.Mat = Mats(aIdx);
%% create stations
obj.Eta = h5read(filepath,sprintf('%s/BodyStations/Eta',loc));
obj.EtaDir = h5read(filepath,sprintf('%s/BodyStations/EtaDir',loc));
obj.StationDir = h5read(filepath,sprintf('%s/BodyStations/StationDir',loc));
obj.A = h5read(filepath,sprintf('%s/BodyStations/A',loc));
obj.I = reshape(h5read(filepath,sprintf('%s/BodyStations/I',loc)),3,3,[]);
obj.J = h5read(filepath,sprintf('%s/BodyStations/J',loc));
obj.tau = reshape(h5read(filepath,sprintf('%s/BodyStations/Tau',loc)),3,3,[]);
obj.Radius = h5read(filepath,sprintf('%s/BodyStations/Radius',loc));
end

