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
p.Tag = 'Body';
%plot Beam Stations
th = 0:pi/50:2*pi;
stDirs = obj.Stations.StationDir./vecnorm(obj.Stations.StationDir);
z = cross(obj.Stations.EtaDir./vecnorm(obj.Stations.EtaDir),stDirs);
perp = cross(stDirs,z);

for n = 1:obj.N
    A = [stDirs(:,n),cross(perp(:,n),stDirs(:,n)),perp(:,n)];
    X = A*[obj.Stations.Radius(n).*cos(th);obj.Stations.Radius(n).*sin(th);th*0];
    plt_obj = plot3(X(1,:),X(2,:),X(3,:),'-');
    plt_obj.Color = [0.4 0.4 0.4];
    plt_obj.Tag = 'Body';
    plt_objs(end+1) = plt_obj;
end

%plot children
optsCell = namedargs2cell(opts);
plt_obj = draw@baff.Element(obj,optsCell{:});
p = [p,plt_obj];
end