function p = draw(obj,opts)
arguments
    obj
    opts.Origin (3,1) double = [0,0,0];
    opts.A (3,3) double = eye(3);
end
Origin = opts.Origin + opts.A*(obj.Offset);
Rot = opts.A*obj.A;
%plot beam
N = length(obj.Stations);
points = cell2mat(arrayfun(@(x)obj.GetPos(x),[obj.Stations.Eta],'UniformOutput',false));
points = repmat(Origin,1,N) + Rot*points;
p = plot3(points(1,:),points(2,:),points(3,:),'-');
p.Color = 'c';
p.Tag = 'Beam';
%plot Beam Stations
for i = 1:length(obj.Stations)
    plt_obj = obj.Stations(i).draw(Origin=points(:,i),A=Rot);
    p = [p,plt_obj];
end
%plot Aero Stations
for i = 1:length(obj.AeroStations)
    eta_vector = obj.Stations.GetPos(obj.AeroStations(i).Eta).*obj.EtaLength;
    plt_obj = obj.AeroStations(i).draw(Origin=(Origin+Rot*eta_vector),A=Rot);
    p = [p,plt_obj];
end
% plot control Surfaces
plt_obj = obj.ControlSurfaces.draw(obj,Origin=Origin,A=Rot);
p = [p,plt_obj];

%plot children
optsCell = namedargs2cell(opts);
plt_obj = draw@baff.Element(obj,optsCell{:});
p = [p,plt_obj];
end