function obj = FromBaff(filepath,loc)
%FROMBAFF Summary of this function goes here
%   Detailed explanation goes here
Qty = h5readatt(filepath,[loc,'/'],'Qty');
if Qty == 0
    obj = baff.Wing.empty;
    return;
end
%% create aerostations
aIdx = h5readatt(filepath,[loc,'/'],'AeroStationsIdx');
aStations = baff.station.Aero.FromBaff(filepath,loc);

%% create beamstations
bIdx = h5readatt(filepath,[loc,'/'],'BeamStationsIdx');
bStations = baff.station.Beam.FromBaff(filepath,loc);

%% create controlsurfaces
cIdx = h5readatt(filepath,[loc,'/'],'ControlSurfacesIdx');
ControlSurfs = baff.ControlSurface.FromBaff(filepath,loc);

%%create wings
aSum = [0,cumsum(aIdx)'];
bSum = [0,cumsum(bIdx)'];
cSum = [0,cumsum(cIdx)'];
for i = 1:Qty
    obj(i) = baff.Wing(aStations((aSum(i)+1):(aSum(i)+aIdx(i))));
    obj(i).Stations = bStations((bSum(i)+1):(bSum(i)+bIdx(i)));
    obj(i).ControlSurfaces = ControlSurfs((cSum(i)+1):(cSum(i)+cIdx(i)));
end
BaffToProp(obj,filepath,loc);    
end

