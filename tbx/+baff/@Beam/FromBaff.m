function obj = FromBaff(filepath,loc)
%FROMBAFF Summary of this function goes here
%   Detailed explanation goes here
Qty = h5readatt(filepath,[loc,'/'],'Qty');
if Qty == 0
    obj = baff.Beam.empty;
    return;
end
%% create beamstations
bIdx = h5readatt(filepath,[loc,'/'],'BeamStationsIdx');
bStations = baff.station.Beam.FromBaff(filepath,loc);

%%create beams
bSum = [0,cumsum(bIdx)'];
for i = 1:Qty
    obj(i) = baff.Beam();
    obj(i).Stations = bStations((bSum(i)+1):(bSum(i)+bIdx(i)));
end
BaffToProp(obj,filepath,loc);    
end

