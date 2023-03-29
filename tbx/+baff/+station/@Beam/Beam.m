classdef Beam < baff.station.Base
    %BEAMSTATION Summary of this class goes here
    %   Detailed explanation goes here

    properties
        A = 1;        % cross sectional area
        I = eye(3);   % moment of inertia tensor
        tau = eye(3); % elongation tensor
        Mat = baff.Material.Stiff;
    end
    methods (Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    methods
        function val = eq(obj1,obj2)
            if length(obj1)~= length(obj2) || ~isa(obj2,'baff.station.Beam')
                val = false;
                return
            end
            val = eq@baff.station.Base(obj1,obj2);
            for i = 1:length(obj1)
                val = val && obj1(i).A == obj2(i).A;
                val = val && all(obj1(i).I == obj2(i).I,'all');
                val = val && all(obj1(i).tau == obj2(i).tau,'all');
                val = val && obj1(i).Mat == obj2(i).Mat;
            end
        end
        function obj = Beam(eta,opts)
            arguments
                eta
                opts.EtaDir = [1;0;0]
                opts.StationDir = [0;1;0];
                opts.Mat = baff.Material.Stiff;
                opts.A = 1;
                opts.I = eye(3);
                opts.tau = eye(3);
            end
            obj.Eta = eta;
            obj.EtaDir = opts.EtaDir;
            obj.StationDir = opts.StationDir;
            obj.A = opts.A;
            obj.I = opts.I;
            obj.tau = opts.tau;
            obj.Mat = opts.Mat;
        end
        function stations = interpolate(obj,etas)
            old_eta = [obj.Eta];
            As = interp1(old_eta,[obj.A],etas,"linear");
            EtaDirs = interp1(old_eta,[obj.EtaDir]',etas,"previous")';
            Is = interp1(old_eta,cell2mat(arrayfun(@(x)x.I(:),obj,'UniformOutput',false))',etas,"linear");
            taus = interp1(old_eta,cell2mat(arrayfun(@(x)x.tau(:),obj,'UniformOutput',false))',etas,"linear");
            stations = baff.station.Beam.empty;
            for i = 1:length(etas)
                stations(i) = baff.station.Beam(etas(i),"A",As(i));
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
        function p = draw(obj,opts)
            arguments
                obj
                opts.Origin (3,1) double = [0,0,0];
                opts.A (3,3) double = eye(3);
            end
            p = plot3(opts.Origin(1,:),opts.Origin(2,:),opts.Origin(3,:),'o');
            p.MarkerFaceColor = 'c';
            p.Color = 'c';
            p.Tag = 'Beam';
        end
    end
    methods(Static)
        function obj = Bar(eta,height,width,opts)
            arguments
                eta
                height
                width
                opts.Mat = baff.Material.Stiff;
            end
            Ixx = height^3*width/12;
            Izz = width^3*height/12;
            Iyy = Ixx + Izz;
            I = diag([Ixx,Iyy,Izz]);
            obj = baff.station.Beam(eta, I=I, A=height*width, Mat=opts.Mat);
        end
    end
end

