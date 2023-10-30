classdef Beam < baff.station.Base
    %BEAMSTATION Creates a beam station
    %   x direction along beam

    properties
        A = 1;        % cross sectional area
        I = eye(3);   % 2nd Moment of Area tensor
        J = 1         % Torsional Constant
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
                val = val && obj1(i).J == obj2(i).J;
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
                opts.J = 1;
                opts.tau = eye(3);
            end
            obj.Eta = eta;
            obj.EtaDir = opts.EtaDir;
            obj.StationDir = opts.StationDir;
            obj.A = opts.A;
            obj.I = opts.I;
            obj.J = opts.J;
            obj.tau = opts.tau;
            obj.Mat = opts.Mat;
        end
        function [EtaCoM,mass] = GetEtaCoM(obj)
            if length(obj)==1
                mass = 0;
                return;
            end
            masses = zeros(1,length(obj)-1);
            etaCoMs = zeros(1,length(obj)-1);
            for i = 1:length(obj)-1
                z = obj(i+1).Eta-obj(i).Eta;
                A1 = obj(i).A;
                A2 = obj(i+1).A;
                if A1==A2
                    etaCoMs(i) = obj(i).Eta + z/2;
                    masses(i) = A1*z*obj(i).Mat.rho*norm(obj(i).EtaDir);
                else
                    z_p = sqrt(A1)*z/(sqrt(A1)-sqrt(A2));
                    vol_p = z_p/3*A1;
                    z_bar = z_p-z;
                    vol_bar = z_bar/3*A2;
                    vol = vol_p-vol_bar;
                    etaCoMs(i) = (vol_p*z_p/4-vol_bar*(z+z_bar/4))/vol + obj(i).Eta;
                    masses(i) = vol*obj(i).Mat.rho*norm(obj(i).EtaDir);
                end
            end
            mass = sum(masses);
            if mass == 0
                EtaCoM = 0;
            else
                EtaCoM = sum(masses.*etaCoMs)/mass;
            end
        end
        function mass = GetEtaMass(obj)
            if length(obj)==1
                mass = 0;
                return;
            end
            mass = zeros(1,length(obj)-1);
            for i = 1:length(obj)-1
                delta = obj(i+1).Eta-obj(i).Eta;
                A1 = obj(i).A;
                A2 = obj(i+1).A;
                vol = delta/3*(A1+A2+sqrt(A1*A2));
                mass(i) = vol*obj(i).Mat.rho*norm(obj(i).EtaDir);
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
            stations = baff.station.Beam.empty;
            for i = 1:length(etas)
                stations(i) = baff.station.Beam(etas(i),"A",As(i));
                stations(i).I = reshape(Is(i,:),3,3);
                stations(i).J = Js(i);
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
            Iyy = height^3*width/12;
            Izz = width^3*height/12;
            Ixx = Iyy + Izz;
            if height>=width
                a = height;
                b = width;
            else
                a = width;
                b = height;
            end
            J = a*b^3*(1/3-0.2085*(b/a)*(1-(b^4)/(12*a^4)));
            I = diag([Ixx,Iyy,Izz]);
            obj = baff.station.Beam(eta, I=I, A=height*width, J=J, Mat=opts.Mat);
        end
    end
end

