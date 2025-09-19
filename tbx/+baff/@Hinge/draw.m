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
%plot hinge
points = [obj.HingeVector,-obj.HingeVector]*obj.RefLength/2;
points = repmat(Origin,1,2) + Rot*points;
p = plot3(points(1,:),points(2,:),points(3,:),'--o');
p.Color = 'r';
p.Tag = 'Hinge';

K = [0,-obj.HingeVector(3),obj.HingeVector(2);...
    obj.HingeVector(3),0,-obj.HingeVector(1);...
    -obj.HingeVector(2),obj.HingeVector(1),0];
opts.A = opts.A * (eye(3)+sind(obj.Rotation)*K+(1-cosd(obj.Rotation))*K^2);
%plot children
optsCell = namedargs2cell(opts);
plt_obj = draw@baff.Element(obj,optsCell{:});
p = [p,plt_obj];
end