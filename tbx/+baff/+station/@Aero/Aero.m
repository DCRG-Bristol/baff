classdef Aero < baff.station.Base  
    %BEAMSTATION Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Chord double = 1;
        Twist double = 0;
        BeamLoc double = 0.25;
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
        function obj = Aero(eta,chord,beamLoc,opts)
            arguments
                eta
                chord
                beamLoc
                opts.Twist = 0;
                opts.EtaDir = [1;0;0];
                opts.StationDir = [0;1;0];
            end
            obj.Eta = eta;
            obj.Chord = chord;
            obj.BeamLoc = beamLoc;
            obj.Twist = opts.Twist;
            obj.EtaDir = opts.EtaDir;
        end
        function stations = interpolate(obj,etas)
            old_eta = [obj.Eta];
            Chords = interp1(old_eta,[obj.Chord],etas,"linear");
            EtaDirs = interp1(old_eta,[obj.EtaDir]',etas,"previous")';
            BeamLocs = interp1(old_eta,[obj.BeamLoc],etas,"linear");
            Twists = interp1(old_eta,[obj.Twist],etas,"linear");
            stations = baff.station.Aero.empty;
            for i = 1:length(etas)
                stations(i) = baff.station.Aero(etas(i),Chords(i),BeamLocs(i),"Twist",Twists(i));
                stations(i).EtaDir = EtaDirs(:,i);
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
            if abs(sum(stDir-repmat(stDir(:,1),1,size(stDir,2)),"all"))>1e-6
                warning('This method currently assumes all aerodynamic stations are parrallel')
            end
            stDir = stDir(:,1);
            chord = interp1(etas,[obj.Chord],eta,"linear");
            beamLoc = interp1(etas,[obj.BeamLoc],eta,"linear");
            twist = interp1(etas,[obj.Twist],eta,"linear");
            points = repmat(stDir,1,length(pChord)).*+(beamLoc - pChord);
            X = baff.util.roty(twist)*points.*chord;
        end
        function p = draw(obj,opts)
            arguments
                obj
                opts.Origin (3,1) double = [0,0,0];
                opts.A (3,3) double = eye(3);
            end
            stDir = obj.StationDir./vecnorm(obj.StationDir);
            le_te = [stDir*obj.BeamLoc,stDir*(obj.BeamLoc-1)].*obj.Chord;
            z = cross(obj.EtaDir./norm(obj.EtaDir),stDir);
            perp = cross(stDir,z);
            points = opts.Origin + opts.A*baff.util.Rodrigues(perp,obj.Twist)*le_te;
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
                areas(i) = 0.5*(obj(i).Chord+obj(i+1).Chord)/span;
            end
        end
    end
    methods(Static)
    end
end

