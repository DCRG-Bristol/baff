classdef Beam < baff.station.Base
    %BEAMSTATION Summary of this class goes here
    %   Detailed explanation goes here

    properties
        A = 1;
        Ixx = 0;
        Izz = 0;
        Mat = baff.Material.Stiff;
    end
    methods (Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    methods
        function obj = Beam(eta,opts)
            arguments
                eta
                opts.EtaDir = [0;1;0]
                opts.Mat = baff.Material.Stiff;
                opts.A = 1;
                opts.Ixx = 1;
                opts.Izz = 1;
            end
            obj.Eta = eta;
            obj.EtaDir = opts.EtaDir;
            obj.A = opts.A;
            obj.Ixx = opts.Ixx;
            obj.Izz = opts.Izz;
            obj.Mat = opts.Mat;
        end
        function stations = interpolate(obj,etas)
            old_eta = [obj.Eta];
            As = interp1(old_eta,[obj.A],etas,"linear");
            Ixxs = interp1(old_eta,[obj.Ixx],etas,"linear");
            Izzs = interp1(old_eta,[obj.Izz],etas,"linear");
            stations = baff.station.Beam.empty;
            for i = 1:length(etas)
                stations(i) = baff.station.Beam(etas(i),"A",As(i),...
                    "Ixx",Ixxs(i),"Izz",Izzs(i));
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
            obj = baff.station.Beam(eta,Ixx=height^3*width/12,Izz=width^3*height/12,...
                A=height*width, Mat = opts.Mat);
        end
    end
end

