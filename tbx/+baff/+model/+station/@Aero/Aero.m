classdef Aero < baff.model.station.Base  
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
        function obj = Aero(eta,chord,beamLoc,opts)
            arguments
                eta
                chord
                beamLoc
                opts.Twist = 0;
                opts.EtaDir = [0;1;0];
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
            BeamLocs = interp1(old_eta,[obj.BeamLoc],etas,"linear");
            Twists = interp1(old_eta,[obj.Twist],etas,"linear");
            stations = baff.model.station.Aero.empty;
            for i = 1:length(etas)
                stations(i) = baff.model.station.Aero(etas(i),Chords(i),BeamLocs(i),"Twist",Twists(i));
            end
        end
        function X = GetPos(obj,eta,pChord)
            arguments
                obj baff.model.station.Aero
                eta (1,1) double
                pChord (1,:) double
            end
            etas = [obj.Eta];
            chord = interp1(etas,[obj.Chord],eta,"linear");
            beamLoc = interp1(etas,[obj.BeamLoc],eta,"linear");
            twist = interp1(etas,[obj.Twist],eta,"linear");
            points = repmat([beamLoc;0;0],1,length(pChord))-[pChord;zeros(2,length(pChord))];
            X = baff.util.roty(twist)*points.*chord;
        end
        function draw(obj,opts)
            arguments
                obj
                opts.Origin (3,1) double = [0,0,0];
                opts.A (3,3) double = eye(3);
            end
            le_te = [obj.BeamLoc,obj.BeamLoc-1;0,0;0,0]*obj.Chord;
            points = opts.Origin + opts.A*baff.util.roty(obj.Twist)*le_te;
            p = plot3(points(1,:),points(2,:),points(3,:),'-o');
            p.Color = 'k';
            p.Tag = 'WingSection';
        end
    end
    methods(Static)
    end
end

