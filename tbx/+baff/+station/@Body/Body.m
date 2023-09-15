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
                opts.J = 1;
                opts.EtaDir = [1;0;0];
                opts.StationDir = [0;1;0];
            end
            obj = obj@baff.station.Beam(eta);
            obj.Eta = eta;
            obj.A = opts.A;
            obj.I = opts.I;
            obj.J = opts.J;
            obj.Mat = opts.Mat;
            obj.Radius = opts.radius;
            obj.EtaDir = opts.EtaDir;
            obj.StationDir = opts.StationDir;
        end
        function Vol = NormVolume(obj,etaLim)
            arguments
                obj
                etaLim = [0,1]
            end 
            etas = [obj.Eta];
            Rs = [obj.Radius];
            idx = etas>=etaLim(1) & etas<=etaLim(2);
            Rs = [interp1(etas,Rs,etaLim(1)),Rs(idx),interp1(etas,Rs,etaLim(2))];
            etas = [etaLim(1),etas(idx),etaLim(2)];
            
            Vol = 0;
            for i=2:length(etas)
                span = etas(i)-etas(i-1);
                Vol = Vol + 1/3*span*pi*(Rs(i-1)^2+Rs(i-1)*Rs(i)+Rs(i)^2);
            end
        end
        function Area = NormWettedArea(obj)
            etas = [obj.Eta];
            Rs = [obj.Radius];
            Area = 0;
            for i=2:length(etas)
                span = etas(i)-etas(i-1);
                Area = Area + span*pi*(Rs(i-1)+Rs(i));
                if i==1
                    Area = Area + span*pi*Rs(i-1);
                elseif i==length(etas)
                    Area = Area + span*pi*Rs(i);
                end
            end
        end
        function stations = interpolate(obj,etas)
            old_eta = [obj.Eta];
            As = interp1(old_eta,[obj.A],etas,"linear");
            EtaDirs = interp1(old_eta,[obj.EtaDir]',etas,"previous")';
            StationDirs = interp1(old_eta,[obj.StationDir]',etas,"previous")';
            Is = interp1(old_eta,cell2mat(arrayfun(@(x)x.I(:),obj,'UniformOutput',false))',etas,"linear");
            Js = interp1(old_eta,[obj.J],etas,"linear");
            taus = interp1(old_eta,cell2mat(arrayfun(@(x)x.tau(:),obj,'UniformOutput',false))',etas,"linear");
            Rs = interp1(old_eta,[obj.Radius],etas,"linear");
            stations = baff.station.Body.empty;
            for i = 1:length(etas)
                stations(i) = baff.station.Body(etas(i),"radius",Rs(i),"A",As(i),"J",Js(i));
                stations(i).I = reshape(Is(i,:),3,3);
                stations(i).tau = reshape(taus(i,:),3,3);
                stations(i).EtaDir = EtaDirs(:,i);
                stations(i).StationDir = StationDirs(:,i);
                if i == length(etas)
                    stations(i).Mat = obj(end).Mat;
                else
                    idx = find(etas(i)>=old_eta,1);
                    stations(i).Mat = obj(idx).Mat;
                end
            end
        end
        function plt_obj = draw(obj,opts)
            arguments
                obj
                opts.Origin (3,1) double = [0,0,0];
                opts.A (3,3) double = eye(3);
            end
            if obj.Radius>0
                th = 0:pi/50:2*pi;
                N = length(th);
                stDir = obj.StationDir./norm(obj.StationDir);
                z = cross(obj.EtaDir./norm(obj.EtaDir),stDir);
                perp = cross(stDir,z);
                R = obj.StationDir./norm(obj.StationDir)*obj.Radius;
                pos = zeros(3,N);
                for i = 1:N
                    pos(:,i) = baff.util.Rodrigues(perp,th(i))*R;
                end
                pos = repmat(opts.Origin,1,N) + opts.A*pos;
                plt_obj = plot3(pos(1,:),pos(2,:),pos(3,:),'-');
                plt_obj.Color = [0.4 0.4 0.4];
                plt_obj.Tag = 'Body';
            else
                plt_obj = [];
            end
            p = plot3(opts.Origin(1,:),opts.Origin(2,:),opts.Origin(3,:),'o');
            p.MarkerFaceColor = [0.4 0.4 0.4];
            p.Color = [0.4 0.4 0.4];
            p.Tag = 'Body';
            plt_obj = [p,plt_obj];
        end
        function vol = GetNormVolume(obj)
            vol = sum(obj.GetNormVolmes);
        end
        function vols = GetNormVolumes(obj)
            if length(obj)<2
                vols = 0;
                return
            end
            vols = zeros(1,length(obj)-1);
            for i = 1:length(obj)-1
                span = (obj(i+1).Eta - obj(i).Eta);
                A1 = pi*obj(i).Radius.^2;
                A2 = pi*obj(i+1).Radius.^2;
                vols(i) = 1/3*span*(A1+A2+sqrt(A1*A2));
            end
        end
    end
    methods(Static)
    end
end

