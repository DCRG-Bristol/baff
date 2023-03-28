classdef Body < baff.station.Beam  
    %BEAMSTATION Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Radius = 1;
    end
    methods (Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    methods
        function val = eq(obj1,obj2)
            if length(obj1)~= length(obj2) || ~isa(obj2,'baff.station.Body')
                val = false;
                return
            end
            val = eq@baff.station.Beam(obj1,obj2);
            for i = 1:length(obj1)
                val = val && obj1(i).Radius == obj2(i).Radius;
            end
        end
        function obj = Body(eta,opts)
            arguments
                eta
                opts.radius = 1;
                opts.Mat = baff.Material.Stiff;
                opts.A = 1;
                opts.I = eye(3);
                opts.EtaDir = [0;1;0];
            end
            obj = obj@baff.station.Beam(eta);
            obj.Eta = eta;
            obj.A = opts.A;
            obj.I = opts.I;
            obj.Mat = opts.Mat;
            obj.Radius = opts.radius;
            obj.EtaDir = opts.EtaDir;
        end
        function stations = interpolate(obj,etas)
            old_eta = [obj.Eta];
            As = interp1(old_eta,[obj.A],etas,"linear");
            EtaDirs = interp1(old_eta,[obj.EtaDir]',etas,"previous")';
            Is = interp1(old_eta,cell2mat(arrayfun(@(x)x.I(:),obj,'UniformOutput',false))',etas,"linear");
            taus = interp1(old_eta,cell2mat(arrayfun(@(x)x.tau(:),obj,'UniformOutput',false))',etas,"linear");
            Rs = interp1(old_eta,[obj.Radius],etas,"linear");
            stations = baff.station.Body.empty;
            for i = 1:length(etas)
                stations(i) = baff.station.Body(etas(i),"radius",Rs(i),"A",As(i));
                stations(i).I = reshape(Is(i,:),3,3);
                stations(i).tau = reshape(taus(i,:),3,3);
                stations(i).EtaDir = EtaDirs(:,i);
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

