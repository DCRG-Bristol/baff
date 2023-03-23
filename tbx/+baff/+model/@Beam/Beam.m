classdef Beam < baff.model.Element
    %BEAM Summary of this class goes here
    %   Detailed explanation goes here
    properties
        Stations (1,:) baff.model.station.Beam = [baff.model.station.Beam(0),baff.model.station.Beam(1)];
    end
    methods(Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    methods
        function obj = Beam(CompOpts)
            arguments
                CompOpts.eta = 0
                CompOpts.Offset
                CompOpts.Name = "Beam" 
            end
            CompStruct = namedargs2cell(CompOpts);
            obj = obj@baff.model.Element(CompStruct{:});
        end
        function X = GetPos(obj,eta)
            X = obj.Stations.GetPos(eta);
        end
    end
    methods(Static)
        function obj = Bar(length,height,width,Material)
            obj = baff.model.Beam();
            obj.EtaLength = length;
            station = baff.model.BeamStation.Bar(0,height,width,Mat=Material);
            obj.Stations = [station,station+1];
        end
    end
end

