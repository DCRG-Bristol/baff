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
p = plot3(points(1,:),points(2,:),points(3,:),'-o');
p.Color = 'c';
p.MarkerFaceColor = 'c';
p.Tag = 'Beam';

%plot Aero Stations
N = obj.AeroStations.N;
etas = obj.AeroStations.Eta;
beamPos = obj.Stations.GetPos(etas).*obj.EtaLength;
LeVec = obj.AeroStations.GetPos(etas,0);
TeVec = obj.AeroStations.GetPos(etas,1);
for i = 1:N
    ps = beamPos(:,[i i]) + [LeVec(:,i),TeVec(:,i)];
    plt_obj = plot3(ps(1,:),ps(2,:),ps(3,:),'-o');
    plt_obj.Color = 'k';
    plt_obj.Tag = 'WingSection';
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