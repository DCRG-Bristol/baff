classdef Beam < baff.Element
    %BEAM Summary of this class goes here
    %   Detailed explanation goes here
    properties
        Stations (1,:) baff.station.Beam = [baff.station.Beam(0),baff.station.Beam(1)];
    end
    methods(Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    methods
        function val = eq(obj1,obj2)
            if length(obj1)~= length(obj2) || ~isa(obj2,'baff.Beam')
                val = false;
                return
            end
            val = eq@baff.Element(obj1,obj2);
            for i = 1:length(obj1)
                val = val && obj1(i).Stations == obj2(i).Stations;
            end
        end
        function obj = Beam(CompOpts,opts)
            arguments
                CompOpts.eta = 0
                CompOpts.Offset
                CompOpts.Name = "Beam" 
                opts.Stations = baff.station.Beam.empty;
                opts.EtaLength = 1;
            end
            CompStruct = namedargs2cell(CompOpts);
            obj = obj@baff.Element(CompStruct{:});
            if ~isempty(opts.Stations)
                obj.Stations = opts.Stations;
            end
            obj.EtaLength = opts.EtaLength;
        end
        function X = GetPos(obj,eta)
            X = obj.Stations.GetPos(eta)*obj.EtaLength;
        end
    end
    methods(Static)
        function obj = Bar(length,height,width,Material)
            obj = baff.Beam();
            obj.EtaLength = length;
            station = baff.BeamStation.Bar(0,height,width,Mat=Material);
            obj.Stations = [station,station+1];
        end
    end
end

