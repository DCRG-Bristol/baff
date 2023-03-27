classdef Element < matlab.mixin.Heterogeneous & handle
    %COMPONENT Summary of this class goes here
    %   Detailed explanation goes here
    properties
        A (3,3) double = eye(3); % Rotation Matrix
        Offset (3,1) double = [0;0;0]; % Offset of the element in the parent element's coordinate system
        isAbsolute = false; %if true, the element is referenced to the global coordinate system, otherwise it is referenced to the parent element
        Eta (1,1) double = 0; %eta coordinate of the element in the parent element's coordinate system
        EtaLength = 0;      % Length of the element in the eta direction
        
        Parent baff.Element = baff.Element.empty; % Parent element
        Children (:,1) baff.Element = baff.Element.empty; % Children elements
        
        Name string = "";    % Name of the element       
        Index = 0;          % Unique index for each element (for use in HDF5 files to link parents and children)
    end
    methods(Static)
        function obj = FromBaff(filepath,loc)
            error('NotImplemented')
        end
    end
    methods
        function obj = Element(opts)
            arguments
                opts.Offset = [0;0;0];
                opts.eta = 0;
                opts.Name = 'Default Component'
                opts.A = eye(3);
            end
            obj.Eta = opts.eta;
            obj.Offset = opts.Offset;
            obj.A = opts.A;
            obj.Name = opts.Name;
        end
        function obj = add(obj,childObj)
            arguments
                obj
                childObj baff.Element
            end
            childObj.Parent = obj;
            obj.Children(end+1) = childObj;
        end
        function X = GetPos(obj,eta)
            X = [0;0;0];
        end
        function draw(obj,opts)
            arguments
                obj
                opts.Origin (3,1) double = [0,0,0];
                opts.A (3,3) double = eye(3);
            end
            Origin = opts.Origin + opts.A*obj.Offset;
            Rot = opts.A*obj.A;
            for i =  1:length(obj.Children)
                if obj.Children(i).isAbsolute
                    obj.Children(i).draw(Origin=Origin,A=Rot);
                else
                    eta_vector = obj.GetPos(obj.Children(i).Eta);
                    obj.Children(i).draw(Origin=(Origin+Rot*eta_vector),A=Rot);
                end
            end
        end
        function LinkElements(obj,filepath,loc,linker)
            if ~isempty(obj)
                pIdx = h5read(filepath,sprintf('%s/Parent',loc));
                cIdx = h5read(filepath,sprintf('%s/Children',loc));
                cIdx = cIdx(~isnan(cIdx(:,1)),:);
                for i = 1:length(obj)
                    if pIdx(i) > 0
                        obj(i).Parent = linker(i);
                    end
                    for j = 1:size(cIdx,1)
                        if cIdx(j,i)>0
                            obj(i).Children(end+1) = linker(cIdx(j,i));
                        end
                    end
                end
            end
        end
        function BaffToProp(obj,filepath,loc)
            offs = h5read(filepath,sprintf('%s/Offset',loc));
            etas = h5read(filepath,sprintf('%s/Eta',loc));
            As = h5read(filepath,sprintf('%s/A',loc));
            Names = h5read(filepath,sprintf('%s/Name',loc));
            etaLengths = h5read(filepath,sprintf('%s/EtaLength',loc));
            Indexs = h5read(filepath,sprintf('%s/Index',loc));
            for i = 1:length(obj)
                obj(i).Offset = offs(:,i);
                obj(i).Eta = etas(i);
                obj(i).A = reshape(As(:,i),3,3);
                obj(i).Name = Names(i);
                obj(i).EtaLength = etaLengths(i);
                obj(i).Index = Indexs(i);
            end
        end
        function PropToBaff(obj,filepath,loc)
            N = length(obj);
            if N ~= 0
                %fill easy data
                h5write(filepath,sprintf('%s/Offset',loc),[obj.Offset],[1 1],[3 N]);
                h5write(filepath,sprintf('%s/Eta',loc),[obj.Eta],[1 1],[1 N]);
                h5write(filepath,sprintf('%s/A',loc),reshape([obj.A],9,[]),[1 1],[9 N]);
                h5write(filepath,sprintf('%s/Name',loc),[obj.Name],[1 1],[1 N]);
                h5write(filepath,sprintf('%s/EtaLength',loc),[obj.EtaLength],[1 1],[1 N]);
                h5write(filepath,sprintf('%s/Index',loc),[obj.Index],[1 1],[1 N]);
                pIdx = zeros(1,N);
                for i = 1:N
                    if ~isempty(obj(i).Parent)
                        pIdx(i) = obj(i).Parent.Index;
                    end
                end
                h5write(filepath,sprintf('%s/Parent',loc),pIdx,[1 1],[1 N]);
                %deal with children
                maxChildren = max(arrayfun(@(x)length(x.Children),obj));
                if maxChildren == 0
                    h5write(filepath,sprintf('%s/Children',loc),zeros(1,N),[1,1],[1 N]);
                else
                    child_idx = zeros(maxChildren,N);
                    for i = 1:length(obj)
                        nc = length(obj(i).Children);
                        child_idx(1:nc,i) = arrayfun(@(x)x.Index,obj(i).Children);
                    end
                    h5write(filepath,sprintf('%s/Children',loc),child_idx,[1,1],[maxChildren N]);
                end
            end
        end
        function ToBaff(obj,filepath)
        end
    end
    methods(Static)
        function TemplateHdf5(filepath,loc)
            %create place holders
            h5create(filepath,sprintf('%s/Offset',loc),[3 inf],"Chunksize",[3,10]);
            h5create(filepath,sprintf('%s/Eta',loc),[1 inf],"Chunksize",[1,10]);
            h5create(filepath,sprintf('%s/A',loc),[9 inf],"Chunksize",[9,10]);
            h5create(filepath,sprintf('%s/Name',loc),[1 inf],"Chunksize",[1,10],Datatype="string");
            h5create(filepath,sprintf('%s/EtaLength',loc),[1 inf],"Chunksize",[1,10]);
            h5create(filepath,sprintf('%s/Index',loc),[1 inf],"Chunksize",[1,10]);
            h5create(filepath,sprintf('%s/Parent',loc),[1 inf],"Chunksize",[1,10],"Fillvalue",nan);
            h5create(filepath,sprintf('%s/Children',loc),[256 inf],"Chunksize",[256,10],"Fillvalue",nan);

            h5writeatt(filepath,[loc,'/'],'Qty', 0);
        end
    end
end

