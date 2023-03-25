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
points = cell2mat(arrayfun(@(x)obj.GetPos(x),[obj.Stations.Eta],'UniformOutput',false));
% points = repmat(etas(2:end)-etas(1:end-1),3,1).*[obj.Stations(1:end-1).EtaDir];
points = repmat(Origin,1,N) + Rot*points;
p = plot3(points(1,:),points(2,:),points(3,:),'-');
p.Color = 'c';
p.Tag = 'Beam';
%plot Beam Stations
for i = 1:length(obj.Stations)
    obj.Stations(i).draw(Origin=points(:,i),A=Rot)
end
%plot children
optsCell = namedargs2cell(opts);
draw@baff.Element(obj,optsCell{:});
end