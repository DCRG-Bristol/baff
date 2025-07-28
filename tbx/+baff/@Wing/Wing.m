classdef Wing < baff.Beam
    %WING Summary of this class goes here
    %   Detailed explanation goes here
    properties
        AeroStations (1,:) baff.station.Aero;
        ControlSurfaces (1,:) baff.ControlSurface;
    end

    properties(Dependent)
        PlanformArea
        Span
    end
    methods
        function A = get.PlanformArea(obj)
            A = obj.AeroStations.GetNormArea * obj.EtaLength;
        end
        function val = getType(obj)
            val ="Wing";
        end
        function b = get.Span(obj)
            b = abs(obj.AeroStations.Eta(end)-obj.AeroStations.Eta(1)) * obj.EtaLength;
        end
    end
    methods(Sealed=true)   
        function As = PlanformAreas(obj)
            As = length(obj);
            for i = 1;length(obj)
                As(i) = obj(i).AeroStations.GetNormArea * obj(i).EtaLength;
            end
        end
        function bs = Spans(obj)
            bs = length(obj);
            for i = 1;length(obj)
                bs(i) = abs(obj(i).AeroStations(end).Eta-obj(i).AeroStations(1).Eta) * obj.EtaLength;
            end
        end
        function p = GetGlobalWingPos(obj,etas,pChord)
            arguments
                obj baff.Wing
                etas (1,:) double
                pChord (1,:) double
            end
            if length(obj)~=1
                error('Can only inspect one wing element at a time')
            end
            A_g = obj.GetGlobalA;
            O_g = obj.GetGlobalPos(0);

            p = zeros(3,length(etas)*length(pChord));
            NC = length(pChord);
            for i = 1:length(etas)
                b = obj.Stations.GetPos(etas(i))*obj.EtaLength;
                tmp = obj.AeroStations.GetPos(etas(i),pChord);
                tmp = tmp+repmat(b,1,size(tmp,2));
                p(:,((i-1)*(NC)+1):(i*NC)) =A_g'*tmp + O_g;
            end
        end
        function [mac,X] = GetMGC(obj,pChord)
            arguments
                obj
                pChord = 0
            end
            if length(obj)==1
                [mac,eta] = obj.AeroStations.GetMGC;
                X = obj.GetGlobalPos(eta,obj.AeroStations.GetPos(eta,pChord));
            else
                As = [obj.PlanformArea];
                idx = find(cumsum(As)>=sum(As)/2,1);
                As = [0,As];
                target_A = sum(As)/2 - As(idx);
                target = target_A/As(idx+1);
                [mac,eta] = obj(idx).AeroStations.GetMGC(target);
                X = obj(idx).GetGlobalPos(eta,obj(idx).AeroStations.GetPos(eta,pChord));
            end
        end
        function [mac,X] = GetMAC(obj)
            [mac,X] = GetMGC(obj);
        end
    end
    methods
        function val = eq(obj1,obj2)
            if length(obj1)~= length(obj2) || ~isa(obj2,'baff.Wing')
                val = false;
                return
            end
            val = eq@baff.Beam(obj1,obj2);
            for i = 1:length(obj1)
                val = val && obj1(i).AeroStations == obj2(i).AeroStations;
                val = val && obj1(i).ControlSurfaces == obj2(i).ControlSurfaces;
            end
        end
        function obj = Wing(aeroStations,opts,CompOpts)
            arguments
                aeroStations
                opts.BeamStations = [baff.station.Beam(0),baff.station.Beam(1)];
                opts.EtaLength = 1;
                CompOpts.eta = 0
                CompOpts.Offset
                CompOpts.Name = "Wing"
            end
            %WING Construct an instance of this class
            %   Detailed explanation goes here
            CompStruct = namedargs2cell(CompOpts);
            obj = obj@baff.Beam(CompStruct{:});
            obj.Stations = opts.BeamStations;
            obj.AeroStations = aeroStations;
            obj.EtaLength = opts.EtaLength;
        end
        function X = GetWingPos(obj,eta,pChord)
            X = obj.GetPos(eta) + obj.AeroStations.GetPos(eta,pChord);
        end
        function X = GetPos(obj,eta)
            X = obj.Stations.GetPos(eta)*obj.EtaLength;
        end
        function Area = WettedArea(obj)
            Area = zeros(size(obj));      
        end
        function [sweepAngles] = GetSweepAngles(obj,cEta)
            sweepAngles = zeros(1,length(obj)-1);
            aSt = obj.AeroStations;
            for i = 1:aSt.N-1
                A = aSt.StationDir(:,i);
                p1 = aSt.GetPos(aSt.Eta(i),cEta) + obj.Stations.GetPos(aSt.Eta(i))*obj.EtaLength;
                p2 = aSt.GetPos(aSt.Eta(i+1),cEta) + obj.Stations.GetPos(aSt.Eta(i+1))*obj.EtaLength;
                B = p2-p1;
                Z = cross(A,B);
                X = cross(Z,A);
                sweepAngles(i) = acosd(dot(X,B)/(norm(X)*norm(B)));
            end
        end
    end
    methods(Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);

        function obj = UniformWing(length,barHeight,barWidth,Material,Chord,BeamLoc,opts)
            arguments
                length
                barHeight
                barWidth
                Material
                Chord
                BeamLoc
                opts.NAeroStations = 2
                opts.NStations = 2
                opts.etaAeroMin = 0
                opts.etaAeroMax = 1
                opts.etaBeamMax = 1
                opts.LiftCurveSlope = 2*pi;
            end
            % create root stations
            stations = baff.station.Beam.Bar(linspace(0,opts.etaBeamMax,opts.NStations),barHeight,barWidth,Mat=Material);
            aeroStation = baff.station.Aero(0,Chord,BeamLoc,LiftCurveSlope=opts.LiftCurveSlope);
            %create end aero station
            aeroStations = aeroStation.Duplicate(linspace(opts.etaAeroMin,opts.etaAeroMax,opts.NAeroStations));
            %gen wing
            obj = baff.Wing(aeroStations);
            obj.EtaLength = length;
            % add beam station Info
            obj.Stations = stations;
        end
        function wing = FromLETESweep(span,RootChord,etas,LESweep,TESweep,BeamLoc,Material,opts)
            arguments
                span
                RootChord
                etas
                LESweep
                TESweep
                BeamLoc
                Material
                opts.Dihedral = 0;
                opts.ThicknessRatio = 0.12;
                opts.Twist = 0;
            end
            N = length(etas);
            delta = etas(2:end) - etas(1:end-1);
            if isscalar(opts.Dihedral)
                opts.Dihedral = opts.Dihedral*ones(1,N);
            end
            if isscalar(opts.Twist)
                opts.Twist = opts.Twist*ones(1,N);
            end
            if isscalar(opts.ThicknessRatio)
                opts.ThicknessRatio = opts.ThicknessRatio*ones(1,N);
            end
            % make beam stations
            beamStations = baff.station.Beam(etas,Mat=Material);
            %get le points
            le = zeros(3,N);
            for i = 1:N-1
                vec = [delta(i)*span;...
                    -tand(LESweep(i))*delta(i)*span;...
                    tand(opts.Dihedral(i))*delta(i)*span];
                le(:,i+1) = le(:,i) + vec;
            end
            %get te points
            te = zeros(3,N);
            te(:,1) = [0;-RootChord;0];
            for i = 1:N-1
                vec = [delta(i)*span;...
                    -tand(TESweep(i))*delta(i)*span;...
                    tand(opts.Dihedral(i))*delta(i)*span];
                te(:,i+1) = te(:,i) + vec;
            end
            % get spar loc 
            locs = le + (te-le).*BeamLoc;
            beamStations.EtaDir(:,1:end-1) = (locs(:,2:end)-locs(:,1:end-1))./span./repmat(delta,3,1);
            % get chords
            chords = vecnorm(te-le);
            %gen aero stations
            aeroStations = baff.station.Aero(etas,chords(1),BeamLoc);
            aeroStations.Chord = chords;
            aeroStations.ThicknessRatio = opts.ThicknessRatio;
            aeroStations.Twist = opts.Twist;
            aeroStations.Airfoil = baff.Airfoil.NACA(0,0);
            %make wing
            wing = baff.Wing(aeroStations,BeamStations=beamStations,EtaLength=span);
        end
    end
end

