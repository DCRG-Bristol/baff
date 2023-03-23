classdef Body < baff.model.station.Base  
    %BEAMSTATION Summary of this class goes here
    %   Detailed explanation goes here

    properties
        A = 1;
        Radius = 1;
        Ixx = 0;
        Izz = 0;
        Mat = baff.model.Material.Stiff;
    end
    methods (Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    methods
        function obj = Body(eta,opts)
            arguments
                eta
                opts.radius = 1;
                opts.Mat = baff.model.Material.Stiff;
                opts.A = 1;
                opts.Ixx = 1;
                opts.Izz = 1;
                opts.EtaDir = [0;1;0];
            end
            obj.Eta = eta;
            obj.A = opts.A;
            obj.Ixx = opts.Ixx;
            obj.Izz = opts.Izz;
            obj.Mat = opts.Mat;
            obj.Radius = opts.radius;
            obj.EtaDir = opts.EtaDir;
        end
        function stations = interpolate(obj,etas)
            old_eta = [obj.Eta];
            As = interp1(old_eta,[obj.A],etas,"linear");
            Ixxs = interp1(old_eta,[obj.Ixx],etas,"linear");
            Izzs = interp1(old_eta,[obj.Izz],etas,"linear");
            Rs = interp1(old_eta,[obj.Radius],etas,"linear");
            stations = baff.model.stations.Body.empty;
            for i = 1:length(etas)
                stations(i) = baff.model.stations.Body(etas(i),"radius",Rs(i),...
                    "A",As(i),"Ixx",Ixxs(i),"Izz",Izzs(i));
                if i == length(etas)
                    stations(i).Mat = obj(end).Mat;
                else
                    idx = find(etas(i)>=old_eta,1);
                    stations(i).Mat = obj(idx).Mat;
                end
            end
        end
        function draw(obj,opts)
            arguments
                obj
                opts.Origin (3,1) double = [0,0,0];
                opts.A (3,3) double = eye(3);
            end
            if obj.Radius>0
                th = 0:pi/50:2*pi;
                N = length(th);
                positions = obj.Radius*[cos(th);zeros(1,N);sin(th)];
                pos = repmat(opts.Origin,1,N) + opts.A*positions;
                p = plot3(pos(1,:),pos(2,:),pos(3,:),'-');
                p.Color = [0.4 0.4 0.4];
                p.Tag = 'Body';
            end
            p = plot3(opts.Origin(1,:),opts.Origin(2,:),opts.Origin(3,:),'o');
            p.MarkerFaceColor = [0.4 0.4 0.4];
            p.Color = [0.4 0.4 0.4];
            p.Tag = 'Body';
        end
    end
    methods(Static)
    end
end

