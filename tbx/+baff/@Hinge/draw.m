function p = draw(obj,opts)
arguments
    obj
    opts.Origin (3,1) double = [0,0,0];
    opts.A (3,3) double = eye(3);
end
Origin = opts.Origin + opts.A*(obj.Offset);
Rot = opts.A*obj.A;
%plot hinge
points = [obj.HingeVector,-obj.HingeVector]*obj.RefLength/2;
points = repmat(Origin,1,2) + Rot*points;
p = plot3(points(1,:),points(2,:),points(3,:),'--o');
p.Color = 'r';
p.Tag = 'Hinge';

%plot children
Origin = opts.Origin + opts.A*obj.Offset;
Rot = opts.A*obj.A*baff.util.Rodrigues(obj.HingeVector,obj.Rotation);
for i =  1:length(obj.Children)
    eta_vector = [0;obj.Children(i).Eta;0]*obj.EtaLength;
    plt_obj = obj.Children(i).draw(Origin=(Origin+Rot*eta_vector),A=Rot);
    p = [p,plt_obj];
end
end