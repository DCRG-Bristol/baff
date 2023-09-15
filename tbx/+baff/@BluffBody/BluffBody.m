classdef BluffBody < baff.Element
    %BEAM Summary of this class goes here
    %   Detailed explanation goes here
    properties
        Stations (1,:) baff.station.Body = [baff.station.Body(0),baff.station.Body(1)];
    end
    methods(Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    methods
        function val = Type(obj)
            val ="BluffBody";
        end
    end
    methods
        function val = eq(obj1,obj2)
            if length(obj1)~= length(obj2) || ~isa(obj2,'baff.BluffBody')
                val = false;
                return
            end
            val = eq@baff.Element(obj1,obj2);
            for i = 1:length(obj1)
                val = val && obj1(i).Stations == obj2(i).Stations;
            end
        end
        function out = plus(obj1,obj2)
            if isa(obj2,'baff.BluffBody')
                eta1 = [obj1.Stations.Eta];
                eta1 = eta1 - eta1(1);
                eta2 = [obj2.Stations.Eta];
                eta2 = eta2 - eta2(1);
                len1 = eta1(end)*obj1.EtaLength;
                len2 = eta2(end)*obj2.EtaLength;
                newLength = len1 + len2;
                eta1 = eta1*len1/newLength;
                eta2 = len1/newLength + eta2*len2/newLength;
                eta1(end) = eta1(end) - 0.5e-4;
                eta2(1) = eta2(1) + 0.5e-4;
                stations = [obj1.Stations,obj2.Stations];
                etas = [eta1,eta2];
                for i = 1:length(stations)
                    stations(i).Eta = etas(i);
                end
                out = baff.BluffBody();
                out.Stations = stations;
                out.EtaLength = newLength;
            else
                error('Can not add %s to a bluff body',class(obj2))
            end
        end
    end
    methods
        function obj = BluffBody(opts)
            arguments
                opts.eta = 0
                opts.Offset = [0;0;0];
                opts.Name = "Beam" 
                opts.Stations = [baff.station.Body(0),baff.station.Body(1)];
            end
            obj = obj@baff.Element("eta",opts.eta,"Offset",opts.Offset,"Name",opts.Name);
            obj.Stations = opts.Stations;
        end
        function X = GetPos(obj,eta)
            X = obj.Stations.GetPos(eta)*obj.EtaLength;
        end
        function Area = WettedArea(obj)
            Area = obj.Stations.NormWettedArea()*obj.EtaLength;            
        end
        function Vol = Volume(obj,etaLims)
            arguments
                obj
                etaLims = [0,1]
            end                
            Vol = obj.Stations.NormVolume(etaLims)*obj.EtaLength;
        end
    end
    methods(Static)
        function obj = FromEta(len,eta,radius,opts)
            arguments
                len (1,1) double
                eta (:,1) double
                radius  (:,1) double
                opts.Material = baff.Material.Stiff;
                opts.Density = nan;
                opts.NStations = 10;
            end
            if isnan(opts.Density) && isnan(opts.NStations)
                error('Either Density of NStations must be non zero')
            end
            
            station = baff.station.Body(0,radius=radius(1),Mat=opts.Material);
            stations = station + eta;
            for i = 1:length(stations)
                stations(i).Radius = radius(i);
            end
            delta = eta(2:end)-eta(1:end-1);
            if ~isnan(opts.NStations)
                Ns = round(delta*(opts.NStations-1)); 
            else
                Ns = round(delta*len/opts.Density);
            end
            if Ns == 0
                Ns = 1;
            end
            tmp_etas = [0];
            for i = 1:(length(eta)-1)
                tmp = linspace(eta(i),eta(i+1),Ns(i)+1);
                tmp_etas = [tmp_etas,tmp(2:end)];
            end
            obj = baff.BluffBody("Stations",stations.interpolate(tmp_etas));
            obj.EtaLength = len;
        end

        function obj = Cylinder(len,radius,opts)
            arguments
                len
                radius
                opts.Material = baff.Material.Stiff;
                opts.NStations = 10;
            end
            station = baff.station.Body(0,radius=radius,Mat=opts.Material);
            obj = baff.BluffBody("Stations",station + linspace(0,1,opts.NStations));
            obj.EtaLength = len;
        end

        function obj = SemiSphere(len,radius,opts)
            arguments
                len
                radius
                opts.Material = baff.Material.Stiff;
                opts.NStations = 10;
                opts.Inverted = false;
                opts.EtaFrustrum = 0;
            end
            station = baff.station.Body(0,radius=radius,Mat=opts.Material);
            stations = station + linspace(0,1,opts.NStations);
            
            dFrustrum = 1-opts.EtaFrustrum;
            if ~opts.Inverted
                rad = @(eta,a,b)b*sin(acos(1-(eta*dFrustrum+opts.EtaFrustrum)));
            else
                rad = @(eta,a,b)b*sin(acos(eta*dFrustrum));
            end
            for i = 1:length(stations)
                stations(i).Radius = rad(stations(i).Eta,len,radius);
            end
            obj = baff.BluffBody("Stations",stations);
            obj.EtaLength = len;
        end
        function obj = Parabola(len,radius,opts)
            arguments
                len
                radius
                opts.Material = baff.Material.Stiff;
                opts.NStations = 10;
                opts.Dir = 0;
            end
            station = baff.station.Body(0,radius=radius,Mat=opts.Material);
            stations = station + linspace(0,1,opts.NStations);
            rad= @(eta,a,b)b*sqrt((eta-opts.Dir));
            for i = 1:length(stations)
                stations(i).Radius = rad(stations(i).Eta,len,radius);
            end
            obj = baff.BluffBody("Stations",stations);
            obj.EtaLength = len;
        end
        function obj = Cone(len,radius_start,radius_end,opts)
            arguments
                len
                radius_start
                radius_end
                opts.Material = baff.Material.Stiff;
                opts.NStations = 10;
            end
            optsCell = namedargs2cell(opts);
            obj = baff.BluffBody.Cylinder(len,radius_start,optsCell{:});
            stations = obj.Stations;
            rs = linspace(radius_start,radius_end,opts.NStations);
            for i = 1:length(rs)
                stations(i).Radius = rs(i);
            end
            obj = baff.BluffBody("Stations",stations);
            obj.EtaLength = len;
        end
    end
end

