function draw(obj,opts)
arguments
    obj
    opts.Origin (3,1) double = [0,0,0];
    opts.A (3,3) double = eye(3);
end
Origin = opts.Origin + opts.A*(obj.Offset);
Rot = opts.A*obj.A;
%plot beam
N = length(obj.Stations);
points = repmat([obj.Stations.eta],3,1).*repmat([0;obj.EtaLength;0],1,N);
points = repmat(Origin,1,N) + Rot*points;
p = plot3(points(1,:),points(2,:),points(3,:),'-');
p.Color = 'c';
p.Tag = 'Beam';
%plot Beam Stations
for i = 1:length(obj.Stations)
    obj.Stations(i).draw(Origin=points(:,i),A=Rot)
end
%plot Aero Stations
for i = 1:length(obj.AeroStations)
    eta_vector = [0;obj.AeroStations(i).eta;0]*obj.EtaLength;
    obj.AeroStations(i).draw(Origin=(Origin+Rot*eta_vector),A=Rot)
end
%plot children
optsCell = namedargs2cell(opts);
draw@baff.model.Element(obj,optsCell{:});
end