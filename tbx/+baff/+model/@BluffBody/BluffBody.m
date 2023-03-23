classdef BluffBody < baff.model.Element
    %BEAM Summary of this class goes here
    %   Detailed explanation goes here
    properties
        Stations (1,:) baff.model.station.Body = [baff.model.station.Body(0),baff.model.station.Body(1)];
    end
    methods(Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    methods
        function out = plus(obj1,obj2)
            if isa(obj2,'baff.model.BluffBody')
                eta1 = [obj1.Stations.Eta];
                eta1 = eta1 - eta1(1);
                eta2 = [obj2.Stations.Eta];
                eta2 = eta2 - eta2(1);
                len1 = eta1(end)*obj1.EtaLength;
                len2 = eta2(end)*obj2.EtaLength;
                newLength = len1 + len2;
                eta1 = eta1*len1/newLength;
                eta2 = len1/newLength + eta2*len2/newLength;
                stations = [obj1.Stations,obj2.Stations];
                etas = [eta1,eta2];
                for i = 1:length(stations)
                    stations(i).Eta = etas(i);
                end
                out = baff.model.BluffBody();
                out.Stations = stations;
                out.EtaLength = newLength;
            else
                error('Can not add %s to a bluff body',class(obj2))
            end
        end
    end
    methods
        function obj = BluffBody(CompOpts)
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
        function obj = Cylinder(len,radius,opts)
            arguments
                len
                radius
                opts.Material = baff.model.Material.Stiff;
                opts.NStations = 10;
            end
            obj = baff.model.BluffBody();
            obj.EtaLength = len;
            station = baff.model.station.Body(0,radius=radius,Mat=opts.Material);
            obj.Stations = station + linspace(0,1,opts.NStations);
        end

        function obj = SemiSphere(len,radius,opts)
            arguments
                len
                radius
                opts.Material = baff.model.Material.Stiff;
                opts.NStations = 10;
            end
            obj = baff.model.BluffBody();
            obj.EtaLength = len;
            station = baff.model.station.Body(0,radius=radius,Mat=opts.Material);
            obj.Stations = station + linspace(0,1,opts.NStations);
%             theta = @(eta,a,b)acos(eta)
            rad = @(eta,a,b)b*sin(acos(1-eta));
            for i = 1:length(obj.Stations)
                obj.Stations(i).Radius = rad(obj.Stations(i).Eta,len,radius);
            end
        end
        function obj = Cone(len,radius_start,radius_end,opts)
            arguments
                len
                radius_start
                radius_end
                opts.Material = baff.model.Material.Stiff;
                opts.NStations = 10;
            end
            optsCell = namedargs2cell(opts);
            obj = baff.model.BluffBody.Cylinder(len,radius_start,optsCell{:});
            rs = linspace(radius_start,radius_end,opts.NStations);
            for i = 1:length(rs)
                obj.Stations(i).Radius = rs(i);
            end
        end
    end
end

