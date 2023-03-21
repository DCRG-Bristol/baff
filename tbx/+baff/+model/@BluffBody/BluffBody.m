classdef BluffBody < baff.model.Element
    %BEAM Summary of this class goes here
    %   Detailed explanation goes here
    properties
        Stations (1,:) baff.model.BodyStation = [baff.model.BodyStation(0),baff.model.BodyStation(1)];
    end
    methods(Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    methods
%         function out = plus(obj1,obj2)
%             if isa(obj2,'baff.model.BluffBody')
%                 newLength = obj1.EtaLength + obj2.EtaLength;
%                 eta1 = arrayfun(@(x)x.eta*obj1.EtaLength/newLength,obj1.Stations);
%                 eta2 = arrayfun(@(x)x.eta*obj2.EtaLength/newLength,obj2.Stations(2:end));
%                 stations = [obj1.Stations,obj2.Stations(2:end)];
%                 etas = [eta1,eta2+obj1.EtaLength/newLength];
%                 for i = 1:length(stations)
%                     stations(i).eta = etas(1);
%                 end
%                 out = baff.model.BluffBody();
% 
%             else
%                 error('Can not add %s to a bluff body',class(obj2))
%             end
%         end
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
            station = baff.model.BodyStation(0,radius=radius,Mat=opts.Material);
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
            station = baff.model.BodyStation(0,radius=radius,Mat=opts.Material);
            obj.Stations = station + linspace(0,1,opts.NStations);
%             theta = @(eta,a,b)acos(eta)
            rad = @(eta,a,b)b*sin(acos(1-eta));
            for i = 1:length(obj.Stations)
                obj.Stations(i).Radius = rad(obj.Stations(i).eta,len,radius);
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

