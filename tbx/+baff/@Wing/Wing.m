classdef Wing < baff.Beam
    %WING Summary of this class goes here
    %   Detailed explanation goes here
    properties
        AeroStations (1,:) baff.station.Aero;
        ControlSurfaces (1,:) baff.ControlSurface;
    end
    
    methods
        function obj = Wing(aeroStations,CompOpts)
            arguments
                aeroStations
                CompOpts.eta = 0
                CompOpts.Offset
                CompOpts.Name = "Wing"
            end
            %WING Construct an instance of this class
            %   Detailed explanation goes here
            CompStruct = namedargs2cell(CompOpts);
            obj = obj@baff.Beam(CompStruct{:});
            obj.AeroStations = aeroStations;
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
    end
end

