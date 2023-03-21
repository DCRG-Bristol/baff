classdef AeroStation < matlab.mixin.Heterogeneous
    %BEAMSTATION Summary of this class goes here
    %   Detailed explanation goes here

    properties
        eta double = 0;
        Chord double = 1;
        Twist double = 0;
        BeamLoc double = 0.25;
    end
    methods
        function obj = AeroStation(eta,chord,beamLoc,opts)
            arguments
                eta
                chord
                beamLoc
                opts.Twist = 0;
            end
            obj.eta = eta;
            obj.Chord = chord;
            obj.BeamLoc = beamLoc;
            obj.Twist = opts.Twist;
        end
        function out = plus(obj,delta_eta)
            for i = 1:length(delta_eta)
                out(i) = obj;
                out(i).eta = out(i).eta + delta_eta(i);
            end
        end
        function stations = interpolate(obj,etas)
            old_eta = [obj.eta];
            Chords = interp1(old_eta,[obj.Chord],etas,"linear");
            BeamLocs = interp1(old_eta,[obj.BeamLoc],etas,"linear");
            Twists = interp1(old_eta,[obj.Twist],etas,"linear");
            stations = baff.model.AeroStation.empty;
            for i = 1:length(etas)
                stations(i) = baff.model.AeroStation(etas(i),Chords(i),BeamLocs(i),"Twist",Twists(i));
            end
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

