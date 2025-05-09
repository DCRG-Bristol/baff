classdef (Abstract) Base < matlab.mixin.Heterogeneous
    
    properties
        Eta (1,1) double;
        EtaDir (3,1) double = [1;0;0];
        StationDir (3,1) double = [0;1;0];
    end
    
    methods
        function val = ne(obj1,obj2)
            val = ~(obj1.eq(obj2));
        end
        function val = eq(obj1,obj2)
            if length(obj1)~= length(obj2) || ~isa(obj2,'baff.station.Base')
                val = false;
                return
            end
            val = true;
            for i = 1:length(obj1)
                val = val && obj1(i).Eta == obj2(i).Eta;
                val = val && all(obj1(i).EtaDir == obj2(i).EtaDir);
            end
        end
        function out = plus(obj,delta_eta)
            if length(delta_eta) == 1
                delta_eta = repmat(delta_eta,1,length(obj));
            end
            if length(obj) == 1
                out = repmat(obj,1,length(delta_eta));
            elseif length(delta_eta) ~= length(obj)
                error('length of obj must be 1 or equal to length of delta_eta')
            else
                out = obj;
            end
            for i = 1:length(delta_eta)
                out(i).Eta = out(i).Eta + delta_eta(i);
            end
        end
        function out = minus(obj,delta_eta)
            if length(delta_eta) == 1
                delta_eta = repmat(delta_eta,1,length(obj));
            end
            if length(obj) == 1
                out = repmat(obj,1,length(delta_eta));
            elseif length(delta_eta) ~= length(obj)
                error('length of obj must be 1 or equal to length of delta_eta')
            else
                out = obj;
            end
            for i = 1:length(delta_eta)
                out(i).Eta = out(i).Eta - delta_eta(i);
            end
        end
        function out = rdivide(obj,delta_eta)
            if length(obj) == 1
                out = repmat(obj,1,length(delta_eta));
            elseif length(delta_eta) ~= length(obj)
                error('length of obj must be 1 or equal to length of delta_eta')
            else
                out = obj;
            end
            for i = 1:length(delta_eta)
                out(i).Eta = out(i).Eta ./ delta_eta(i);
            end
        end
        function out = Normalise(obj,NormEta)
            arguments
                obj
                NormEta = obj(end).Eta
            end
            out = obj;
            for i = 1:length(obj)
                out(i).Eta = (out(i).Eta - obj(1).Eta) / (NormEta - obj(1).Eta);
            end
        end
        function X = GetPos(obj,eta)
            % check we have an array of sorted stations
            etas = [obj.Eta];
            if ~issorted(etas)
                error('array of stations must be sorted in assending order (of eta)')
            end
            %deal with single length obj
            if isscalar(etas)
                X = obj(1).EtaDir.*(eta-etas(1));
                return
            end
            EtaDirs = [obj.EtaDir];
            delta = [[0;0;0],repmat(etas(2:end)-etas(1:end-1),3,1).*EtaDirs(:,1:end-1)];
            pos = cumsum(delta,2);
            % adjust to be zero at zero eta;
            if etas(1)~=0
                pos = pos-repmat(interp1(etas,pos',0)',1,numel(etas));
            end
            if isscalar(eta)
                idx = find(etas==eta,1);
                if ~isempty(idx)
                    X = pos(:,idx);
                else
                    ii = find(etas>eta,1);
                    delta = (eta-etas(ii-1))/(etas(ii)-etas(ii-1));
                    X = pos(:,ii-1) + (pos(:,ii)-pos(:,ii-1))*delta;
                end
            else
                X = interp1(etas',pos',eta)';
            end
            % deal with extrapolated etas
            idx = eta<etas(1);
            if nnz(idx)>0
                X(:,idx) = obj(1).EtaDir.*(eta(idx)-etas(1)) + repmat(pos(:,1),1,nnz(idx));
            end
            idx = eta>etas(end);
            if nnz(idx)>0
                X(:,idx) = obj(end).EtaDir.*(eta(idx)-etas(end)) + repmat(pos(:,end),1,nnz(idx));
            end
            if any(isnan(X))
                error("unexpected NaN in interpolation of station positions")
            end
        end
        function [lenLocus,kappa] = GetLocus(obj)
            % gets the length of the locus formed by the stations and returns the 
            % normalised positon of the stations along the locus
            etas = [obj.Eta];
            dirs = [obj.EtaDir];
            seg_locus_len = (etas(2:end)-etas(1:end-1)).*vecnorm(dirs(:,1:end-1));
            lenLocus = sum(seg_locus_len);
            kappa = [0,cumsum(seg_locus_len)/lenLocus];
            kappa = round(kappa,12);
        end
    end
    methods (Abstract)
        stations = interpolate(obj,etas);
    end
end

