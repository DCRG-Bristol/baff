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
etas = [obj.Stations.Eta].*obj.EtaLength;
p = repmat(etas(2:end)-etas(1:end-1),3,1).*[obj.Stations(1:end-1).EtaDir];
p = cumsum([zeros(3,1),p],2);
points = repmat(Origin,1,N) + Rot*p;
p = plot3(points(1,:),points(2,:),points(3,:),'-');
p.Color = 'c';
p.Tag = 'Beam';
%plot Beam Stations
for i = 1:length(obj.Stations)
    plt_obj = obj.Stations(i).draw(Origin=points(:,i),A=Rot);
    p = [p,plt_obj];
end
%plot children
optsCell = namedargs2cell(opts);
plt_obj = draw@baff.Element(obj,optsCell{:});
p = [p,plt_obj];
end