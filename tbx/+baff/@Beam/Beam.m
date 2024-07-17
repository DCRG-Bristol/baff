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
        function val = Type(obj)
            val ="Beam";
        end
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
        function x = GetBeamLength(obj)
            x = obj.Stations.GetLocus()*obj.EtaLength;
        end
        function X = GetPos(obj,eta)
            X = obj.Stations.GetPos(eta)*obj.EtaLength;
        end
        function mass = GetElementMass(obj)
            mass = zeros(size(obj));
            for i = 1:length(obj)
                mass(i) = sum(obj(i).Stations.GetEtaMass().*obj(i).EtaLength);
            end
        end
        function [Xs,masses] = GetElementCoM(obj)
            masses = zeros(1,length(obj));
            Xs = zeros(3,length(obj));
            for i = 1:length(obj)
                [EtaCoM,mass] = obj(i).Stations.GetEtaCoM();
                masses(i) = mass.*obj(i).EtaLength;
                % Xs(:,i) = obj(i).GetGlobalPos(EtaCoM);
                Xs(:,i) = obj(i).GetPos(EtaCoM);
            end
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

