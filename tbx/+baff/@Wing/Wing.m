classdef Wing < baff.Beam
    %WING Summary of this class goes here
    %   Detailed explanation goes here
    properties
        AeroStations (1,:) baff.station.Aero;
        ControlSurfaces (1,:) baff.ControlSurface;
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
        function X = GetPos(obj,eta)
            X = obj.Stations.GetPos(eta)*obj.EtaLength;
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
                opts.etaAeroMax = 1
                opts.etaBeamMax = 1
            end
            % create root stations
            station = baff.station.Beam.Bar(0,barHeight,barWidth,Mat=Material);
            aeroStation = baff.station.Aero(0,Chord,BeamLoc);
            %create end aero station
            aeroStations = aeroStation + linspace(0,opts.etaAeroMax,opts.NAeroStations);
            %gen wing
            obj = baff.Wing(aeroStations);
            obj.EtaLength = length;
            % add beam station Info
            obj.Stations = station + linspace(0,opts.etaBeamMax,opts.NStations);
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
            end
            N = length(etas);
            delta = etas(2:end) - etas(1:end-1);
            if length(opts.Dihedral)==1
                opts.Dihedral = opts.Dihedral*ones(1,N);
            end
            if length(opts.ThicknessRatio)==1
                opts.ThicknessRatio = opts.ThicknessRatio*ones(1,N);
            end
            % make beam stations
            station = baff.station.Beam(0,Mat=Material);
            beamStations = station + etas;
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
            vecs = (locs(:,2:end)-locs(:,1:end-1))./span./repmat(delta,3,1);
            for i=1:N-1
                beamStations(i).EtaDir = vecs(:,i);
            end
            % get chords
            chords = vecnorm(te-le);
            %gen aero stations
            aeroStation = baff.station.Aero(0,chords(1),BeamLoc);
            aeroStations = aeroStation + etas;
            for i = 1:length(aeroStations)
                aeroStations(i).Chord = chords(i);
                aeroStations(i).ThicknessRatio = opts.ThicknessRatio(i);
            end
            %make wing
            wing = baff.Wing(aeroStations,"BeamStations",beamStations,"EtaLength",span);
        end
    end
end

