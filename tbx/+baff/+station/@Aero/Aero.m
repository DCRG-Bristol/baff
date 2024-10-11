classdef Aero < baff.station.Base  
    %BEAMSTATION Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Chord double = 1;
        Twist double = 0;
        BeamLoc double = 0.25;
        Airfoil baff.Airfoil = baff.Airfoil.NACA_sym;
        ThicknessRatio double = 1;
        LiftCurveSlope double = 2*pi;
    end
    %inertial properties
    properties
        LinearDensity double = 0;               % wings linear density
        LinearInertia (3,3) double = zeros(3);  % spanwise moment of inertia matrix
        MassLoc double = 0.5;                   %location of mass as percentage of chord
    end
    methods (Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    methods
        function val = eq(obj1,obj2)
            if length(obj1)~= length(obj2) || ~isa(obj2,'baff.station.Aero')
                val = false;
                return
            end
            val = eq@baff.station.Base(obj1,obj2);
            for i = 1:length(obj1)
                val = val && obj1(i).Chord == obj2(i).Chord;
                val = val && obj1(i).Twist == obj2(i).Twist;
                val = val && obj1(i).BeamLoc == obj2(i).BeamLoc;
            end
        end
        function val = HasMass(obj)
            val = arrayfun(@(x)x.LinearDensity>0||nnz(x.LinearInertia)>0,obj);
        end
        function obj = Aero(eta,chord,beamLoc,opts)
            arguments
                eta
                chord
                beamLoc
                opts.Twist = 0;
                opts.EtaDir = [1;0;0];
                opts.StationDir = [0;1;0];
                opts.Airfoil = baff.Airfoil.NACA_sym;
                opts.ThicknessRatio = 1;
                opts.LiftCurveSlope = 2*pi;
                opts.LinearDensity = 0;
                opts.MassLoc = 0.5;
                opts.LinearInertia = zeros(3);
            end
            obj.Eta = eta;
            obj.Chord = chord;
            obj.BeamLoc = beamLoc;
            obj.Twist = opts.Twist;
            obj.EtaDir = opts.EtaDir;
            obj.StationDir = opts.StationDir;
            obj.Airfoil = opts.Airfoil;
            obj.ThicknessRatio = opts.ThicknessRatio;
            obj.LiftCurveSlope = opts.LiftCurveSlope;
            obj.LinearInertia = opts.LinearInertia;
            obj.MassLoc = opts.MassLoc;
            obj.LinearDensity = opts.LinearDensity;
        end
        function stations = interpolate(obj,etas)
            old_eta = [obj.Eta];
            Chords = interp1(old_eta,[obj.Chord],etas,"linear");
            EtaDirs = interp1(old_eta,[obj.EtaDir]',etas,"previous")';
            StationDirs = interp1(old_eta,[obj.StationDir]',etas,"previous")';
            BeamLocs = interp1(old_eta,[obj.BeamLoc],etas,"linear");
            Twists = interp1(old_eta,[obj.Twist],etas,"linear");
            Airfoils = interp1(old_eta,1:length(old_eta),etas,"previous");
            ThicknessRatios = interp1(old_eta,[obj.ThicknessRatio],etas,"linear");
            LiftCurveSlopes = interp1(old_eta,[obj.LiftCurveSlope],etas,"linear");
            stations = baff.station.Aero.empty;
            for i = 1:length(etas)
                stations(i) = baff.station.Aero(etas(i),Chords(i),BeamLocs(i),"Twist",Twists(i));
                stations(i).EtaDir = EtaDirs(:,i);
                stations(i).StationDir = StationDirs(:,i);
                stations(i).Airfoil = obj(Airfoils(i)).Airfoil;
                stations(i).ThicknessRatio = ThicknessRatios(i);
                stations(i).LiftCurveSlope = LiftCurveSlopes(i);
            end
        end
        function X = GetPos(obj,eta,pChord)
            arguments
                obj baff.station.Aero
                eta (1,1) double
                pChord (1,:) double
            end
            etas = [obj.Eta];
            stDir = [obj.StationDir]./vecnorm([obj.StationDir]);
            if length(obj) == 1
                stDir = stDir(:,1);
                chord =   [obj.Chord];
                beamLoc = [obj.BeamLoc];
                twist =   [obj.Twist];
                etaDir = obj.EtaDir;
            else
                if abs(sum(stDir-repmat(stDir(:,1),1,size(stDir,2)),"all"))>1e-6
                    warning('This method currently assumes all aerodynamic stations are parrallel')
                end
                stDir = stDir(:,1);
                chord = interp1(etas,[obj.Chord],eta,"linear");
                beamLoc = interp1(etas,[obj.BeamLoc],eta,"linear");
                twist = interp1(etas,[obj.Twist],eta,"linear");
                etaDir = interp1(etas,[obj.EtaDir]',eta,"previous")';
            end
            z = cross(etaDir./norm(etaDir),stDir);
            perp = cross(stDir,z);
            points = repmat(stDir,1,length(pChord)).*+(beamLoc - pChord);
            X = baff.util.Rodrigues(perp,deg2rad(twist))*points.*chord;
        end
        function points = getDrawCoords(obj,opts)
            arguments
                obj
                opts.Origin (3,1) double = [0,0,0];
                opts.A (3,3) double = eye(3);
            end
            stDir = obj.StationDir./vecnorm(obj.StationDir);
            le_te = [stDir*obj.BeamLoc,stDir*(obj.BeamLoc-1)].*obj.Chord;
            z = cross(obj.EtaDir./norm(obj.EtaDir),stDir);
            perp = cross(stDir,z);
            points = opts.Origin + opts.A*baff.util.Rodrigues(perp,deg2rad(obj.Twist))*le_te;
        end
        function p = draw(obj,opts)
            arguments
                obj
                opts.Origin (3,1) double = [0,0,0];
                opts.A (3,3) double = eye(3);
            end
            points = obj.getDrawCoords(Origin=opts.Origin,A=opts.A);
            p = plot3(points(1,:),points(2,:),points(3,:),'-o');
            p.Color = 'k';
            p.Tag = 'WingSection';
        end
        function area = GetNormArea(obj)
            area = sum(obj.GetNormAreas);
        end
        function areas = GetNormAreas(obj)
            if length(obj)<2
                areas = 0;
                return
            end
            areas = zeros(1,length(obj)-1);
            for i = 1:length(obj)-1
                span = (obj(i+1).Eta - obj(i).Eta);
                areas(i) = 0.5*(obj(i).Chord+obj(i+1).Chord)*span;
            end
        end
        function areas = GetNormWettedAreas(obj)
            if length(obj)<2
                areas = 0;
                return
            end
            perimeters = arrayfun(@(x)x.NormPerimeter,[obj.Airfoil]).*[obj.Chord];
            deltaEta = [obj(2:end).Eta]-[obj(1:end-1).Eta];
            areas = 0.5*(perimeters(1:end-1)+perimeters(2:end)).*deltaEta;
        end
        function area = GetNormWettedArea(obj)
            area = sum(obj.GetNormWettedAreas);
        end
        function area = getSubNormArea(obj,x)
            Etas = [obj.Eta];
            area = obj.interpolate([Etas(Etas<x),x]).GetNormArea();
        end
        function c_bar = GetMeanChord(obj)
            c = 0;
            areas = GetNormAreas(obj);
            c_bar = sum(areas)./(obj(end).Eta - obj(1).Eta);
        end
        function [mgc,eta_mgc] = GetMGC(obj,target)
            arguments
                obj
                target = 0.5
            end
            area = obj.GetNormArea();
            etas = [obj.Eta];
            chords = [obj.Chord];
            function a = half_area(x)
                chord_i = interp1(etas,chords,x);
                ei = [etas(etas<x),x];
                ci = [chords(etas<x),chord_i];
                a = trapz(ei,ci); 
            end
            eta_mgc = fminsearch(@(x)(half_area(x)/area-target)^2,target);
            mgc = obj.interpolate(eta_mgc).Chord;
        end
        
        function [mgcs,thicknessRatios] = GetMGCs(obj)
            mgcs = zeros(1,length(obj)-1);
            thicknessRatios = zeros(1,length(obj)-1);
            for i = 1:length(obj)-1
                tr = obj(i+1).Chord/obj(i).Chord;
                mgcs(i) = 2/3*obj(i).Chord*(1+tr+tr^2)/(1+tr);
                thicknessRatios(i) = (obj(i).ThicknessRatio + obj(i+1).ThicknessRatio)/2;
            end
        end
        function vol = GetNormVolume(obj,cEtas,Etas)
            arguments
                obj
                cEtas (1,2) double = [0 1]
                Etas (1,2) double = [nan nan]
            end
            vol = sum(obj.GetNormVolumes(cEtas,Etas));
        end
        function vols = GetNormVolumes(obj,cEtas,Etas)
            arguments
                obj
                cEtas (1,2) double = [0 1]
                Etas (1,2) double = [nan nan]
            end
            if length(obj)<2
                vols = 0;
                return
            end
            if ~isnan(Etas(1))
                idx = [obj.Eta]>Etas(1) & [obj.Eta]<Etas(2);
                obj = obj.interpolate([Etas(1),[obj(idx).Eta],Etas(2)]);
            end
            vols = zeros(1,length(obj)-1);
            A = [obj.Chord].^2.*[obj.ThicknessRatio];
            A = A.*arrayfun(@(x)x.GetNormArea(cEtas),[obj.Airfoil]);
            for i = 1:length(obj)-1
                span = (obj(i+1).Eta - obj(i).Eta);
                vols(i) = span/3*(A(i)+A(i+1)+sqrt(A(i)*A(i+1))); 
            end
        end
    end
    methods(Static)
    end
end

