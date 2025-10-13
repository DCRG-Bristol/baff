clear all
% make three identical wings
wing1 = baff.Wing.UniformWing(1,0.005,0.02,baff.Material.Aluminium,0.1,0.25,NStations=3,NAeroStations=3);
wing2 = baff.Wing.UniformWing(1,0.005,0.02,baff.Material.Aluminium,0.1,0.25,NStations=3,NAeroStations=3);
wing2.Offset = [0 -0.1 0]';
wing3 = baff.Wing.UniformWing(1,0.005,0.02,baff.Material.Aluminium,0.1,0.25,NStations=3,NAeroStations=3);
wing3.Offset = [0 0.1 0]';

md = baff.Model;
md.AddElement(wing1);
md.AddElement(wing2);
md.AddElement(wing3);

%sweep wings 2 and 3 by change the EtaDir
wing2.Stations.EtaDir = repmat([1;tand(-25);0],1,wing2.Stations.N);
wing3.Stations.EtaDir = repmat([1;tand(25);0],1,wing2.Stations.N);

% draw the model
f = figure(1); clf;
md.draw(f,Type="surf");
axis equal

%% Sweep check: Volume, Mass, Span and area
assert(isscalar(unique(md.Wing.GetMass)),'Mass Property Not the same for all three wings');
assert(isscalar(unique([md.Wing.PlanformArea])),'Planform Property Not the same for all three wings');
assert(isscalar(unique([md.Wing.Span])),'Span Property Not the same for all three wings');
assert(isscalar(unique(md.Wing.WettedArea)),'Wetted Area Property Not the same for all three wings');
assert(isscalar(unique(md.Wing.WingVolume)),'Wing Volume Property Not the same for all three wings');

%% Sweep Check: beam length longer for swept wings
assert(wing1.GetBeamLength < wing2.GetBeamLength)
assert(wing2.GetBeamLength == wing3.GetBeamLength)

%% Wetted area Check
assert(wing1.PlanformArea == 0.1)
assert(wing1.WettedArea>=2*wing1.PlanformArea)
assert(wing1.WettedArea<pi*0.1)