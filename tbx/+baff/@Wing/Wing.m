classdef Wing < baff.Beam
    %WING class to build Baff wing models
    properties
        AeroStations (1,:) baff.station.Aero; % Aero stations for the wing
        ControlSurfaces (1,:) baff.ControlSurface; % Control surfaces for the wing
    end

    properties(Dependent)
        PlanformArea; % Planform area of the wing
        Span; % Span of the wing
    end
    methods
        function A = get.PlanformArea(obj)
            %PlanformArea returns the planform area of the wing
            A = obj.AeroStations.GetNormArea * obj.EtaLength;
        end
        function val = getType(obj)
            %getType returns the type of the object as a string.
            val ="Wing";
        end
        function b = get.Span(obj)
            %Span returns the span of the wing - assumes EtaDir component in spanwise direction is equal to 1 at each station.
            b = abs(obj.AeroStations.Eta(end)-obj.AeroStations.Eta(1)) * obj.EtaLength;
        end
    end
    methods(Sealed=true)   
        function As = PlanformAreas(obj)
            %PlanformArea returns the planform area of the wing between each aero station
            As = length(obj);
            for i = 1;length(obj)
                As(i) = obj(i).AeroStations.GetNormArea * obj(i).EtaLength;
            end
        end
        function bs = Spans(obj)
            %Span returns the span of the wing between each aero station
            bs = length(obj);
            for i = 1;length(obj)
                bs(i) = abs(obj(i).AeroStations(end).Eta-obj(i).AeroStations(1).Eta) * obj.EtaLength;
            end
        end
        function p = GetGlobalWingPos(obj,etas,pChord)
            %GetGlobalWingPos returns the global position of the wing at given etas and pChord
            %Args:
            %   etas: vector of etas at which to get the position
            %   pChord: normailised chord at which to get the position, where 0 is the leading edge and 1 is the trailing edge
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
            %GetMGC returns the mean geometric chord and its position
            %Args:
            %   pChord: normailised chord at which to return the position, where 0 is the leading edge and 1 is the trailing edge
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
            %GetMAC returns the mean aerodynamic chord and its position
            % this is here for legacy as most people say mean aerodynamic chord, but actually mean the mean geometric chord...
            [mac,X] = GetMGC(obj);
        end
    end
    methods
        function val = eq(obj1,obj2)
            %overloads the == operator to check the equality of two Wing objects.
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
            %WING Construct an instance of this class
            arguments
                aeroStations
                opts.BeamStations = [baff.station.Beam(0),baff.station.Beam(1)];
                opts.EtaLength = 1;
                CompOpts.eta = 0
                CompOpts.Offset
                CompOpts.Name = "Wing"
            end
            CompStruct = namedargs2cell(CompOpts);
            obj = obj@baff.Beam(CompStruct{:});
            obj.Stations = opts.BeamStations;
            obj.AeroStations = aeroStations;
            obj.EtaLength = opts.EtaLength;
        end
        function X = GetWingPos(obj,eta,pChord)
            %GetWingPos returns the position of the wing at a given eta and pChord
            X = obj.GetPos(eta) + obj.AeroStations.GetPos(eta,pChord);
        end
        function X = GetPos(obj,eta)
            %GetPos returns the position of the wing at a given eta along the beam line
            X = obj.Stations.GetPos(eta)*obj.EtaLength;
        end
        function Area = WettedArea(obj)
            %WettedArea returns the wetted area of the wing
            Area = zeros(size(obj));      
        end
        function [sweepAngles] = GetSweepAngles(obj,cEta)
            %GetSweepAngles returns the sweep angle of the wing at each aero station
            %Args:
            %   cEta: the normailised chord at which to calculate the sweep angle

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
            % Static function to create a uniform wing
            %Args:
            %   length: length of the wing
            %   barHeight: height of the beam cross section
            %   barWidth: width of the beam cross section
            %   Material: material of the beam
            %   Chord: chord of the wing
            %   BeamLoc: location of the beam in the chord
            %   opts.NAeroStations: number of aero stations
            %   opts.NStations: number of beam stations
            %   opts.etaAeroMin: minimum eta for aero stations
            %   opts.etaAeroMax: maximum eta for aero stations
            %   opts.etaBeamMax: maximum eta for beam stations
            %   opts.LiftCurveSlope: lift curve slope of the wing
            arguments
                length
                barHeight
                barWidth
                Material
                Chord (1,1) double = 1; % Chord of the wing
                BeamLoc (1,1) double = 0.5; % Location of the beam in the chord
                opts.NAeroStations (1,1) double = 2; % Number of aero stations
                opts.NStations (1,1) double = 2; % Number of beam stations
                opts.etaAeroMin (1,1) double = 0; % Minimum eta for aero stations
                opts.etaAeroMax (1,1) double = 1; % Maximum eta for aero stations
                opts.etaBeamMax (1,1) double = 1; % Maximum eta for beam stations
                opts.LiftCurveSlope (1,1) double = 2*pi; % Lift curve slope of the wing
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
            %FromLETESweep creates a wing from leading and trailing edge sweep angles
            %Args:
            %   span: span of the wing
            %   RootChord: chord at the root of the wing
            %   etas: vector of etas at which to create the wing
            %   LESweep: leading edge sweep angles at each eta
            %   TESweep: trailing edge sweep angles at each eta
            %   BeamLoc: normalised location of the beam along the chord at each eta
            %   Material: material of the wing
            %   opts.Dihedral: dihedral angle at each eta ( or scalar for constant dihedral)
            %   opts.Twist: twist angle at each eta ( or scalar for constant twist)
            %   opts.ThicknessRatio: thickness ratio at each eta ( or scalar for constant thickness ratio) 
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

