function p = draw(obj,opts)
%Draw draw an element in 3D Space
%Args:
%   opts.Origin: Origin of the beam element in 3D space
%   opts.A: Rotation matrix to beam coordinate system
%   opts.Type: plot type
arguments
    obj
    opts.Origin (3,1) double = [0,0,0];
    opts.A (3,3) double = eye(3);
    opts.Type string {mustBeMember(opts.Type,["stick","surf","mesh"])} = "stick";
end
Origin = opts.Origin + opts.A*(obj.Offset);
Rot = opts.A*obj.A;
%plot beam
N = obj.Stations.N;
etas = obj.Stations.Eta.*obj.EtaLength;
p = repmat(etas(2:end)-etas(1:end-1),3,1).*obj.Stations.EtaDir(:,1:end-1);
p = cumsum([zeros(3,1),p],2);
points = repmat(Origin,1,N) + Rot*p;
p = plot3(points(1,:),points(2,:),points(3,:),'-o');
p.Color = 'c';
p.Tag = 'Beam';
p.MarkerFaceColor = 'c';

%plot children
optsCell = namedargs2cell(opts);
plt_obj = draw@baff.Element(obj,optsCell{:});
p = [p,plt_obj];
end